# frozen_string_literal: true

module Westan
  class CriticReviewsController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME

    before_action :ensure_logged_in, only: [:create, :update, :destroy, :vote]

    PAGE_SIZE = 10

    def index
      scope = CriticReview.all
      scope = scope.where(album_id: params[:album_id]) if params[:album_id].present?

      case params[:kind]
      when "press" then scope = scope.press
      when "user" then scope = scope.users
      end

      scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?

      page = [(params[:page] || 1).to_i, 1].max
      scope = scope.order(created_at: :desc).offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)

      render_serialized(scope, CriticReviewSerializer, root: "reviews")
    end

    def create
      attrs = review_params
      attrs[:user_id] = current_user.id unless attrs[:is_critic] == "true" || attrs[:is_critic] == true

      review = CriticReview.new(attrs)
      if review.save
        render_serialized(review, CriticReviewSerializer, root: "review")
      else
        render_json_error(review)
      end
    end

    def update
      review = CriticReview.find(params[:id])
      raise Discourse::InvalidAccess unless review.editable_by?(current_user)

      if review.update(review_params)
        render_serialized(review, CriticReviewSerializer, root: "review")
      else
        render_json_error(review)
      end
    end

    def destroy
      review = CriticReview.find(params[:id])
      raise Discourse::InvalidAccess unless review.editable_by?(current_user)
      review.destroy!
      render json: success_json
    end

    def vote
      review = CriticReview.find(params[:id])
      requested_vote = params[:vote].to_s
      raise Discourse::InvalidParameters.new(:vote) unless CriticReviewVote::VOTES.include?(requested_vote)

      existing = CriticReviewVote.find_by(review_id: review.id, user_id: current_user.id)
      if existing&.vote == requested_vote
        existing.destroy!
        my_vote = nil
      elsif existing
        existing.update!(vote: requested_vote)
        my_vote = requested_vote
      else
        CriticReviewVote.create!(review_id: review.id, user_id: current_user.id, vote: requested_vote)
        my_vote = requested_vote
      end

      render json: {
        likes_count: review.votes.where(vote: "like").count,
        dislikes_count: review.votes.where(vote: "dislike").count,
        my_vote: my_vote
      }
    end

    private

    def review_params
      params.permit(:album_id, :score, :body, :is_critic,
                    :critic_outlet, :critic_name, :review_url,
                    :needs_correction)
    end
  end
end
