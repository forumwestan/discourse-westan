# frozen_string_literal: true

module Westan
  class CriticAlbumSerializer < ::ApplicationSerializer
    attributes :id, :slug, :title, :artist, :cover_url, :type,
               :release_date, :is_upcoming, :spotify_url,
               :avg_user_score, :avg_critic_score,
               :user_review_count, :critic_review_count,
               :created_at

    def avg_user_score
      object.avg_user_score
    end

    def avg_critic_score
      object.avg_critic_score
    end

    def user_review_count
      object.user_reviews.count
    end

    def critic_review_count
      object.critic_reviews.count
    end
  end
end
