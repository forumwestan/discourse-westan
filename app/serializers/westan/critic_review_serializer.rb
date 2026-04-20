# frozen_string_literal: true

module Westan
  class CriticReviewSerializer < ::ApplicationSerializer
    attributes :id, :album_id, :user_id, :score, :body,
               :is_critic, :critic_outlet, :critic_name, :review_url,
               :needs_correction, :created_at,
               :username, :display_name, :avatar_template

    def username
      object.user&.username
    end

    def display_name
      object.user&.name
    end

    def avatar_template
      object.user&.avatar_template
    end
  end
end
