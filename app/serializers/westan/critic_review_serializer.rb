# frozen_string_literal: true

module Westan
  class CriticReviewSerializer < ::ApplicationSerializer
    attributes :id, :album_id, :user_id, :score, :body,
               :is_critic, :critic_outlet, :critic_name, :review_url,
               :needs_correction, :created_at,
               :username, :display_name, :avatar_template,
               :likes_count, :dislikes_count, :my_vote,
               :editable_by_current_user

    def username
      object.user&.username
    end

    def display_name
      object.user&.name
    end

    def avatar_template
      object.user&.avatar_template
    end

    def likes_count
      object.votes.where(vote: "like").count
    end

    def dislikes_count
      object.votes.where(vote: "dislike").count
    end

    def my_vote
      user_id = scope&.user&.id
      return nil unless user_id
      object.votes.find_by(user_id: user_id)&.vote
    end

    def editable_by_current_user
      object.editable_by?(scope&.user)
    end
  end
end
