# frozen_string_literal: true

module Westan
  class CriticReviewVote < ActiveRecord::Base
    self.table_name = "westan_critic_review_votes"

    VOTES = %w[like dislike].freeze

    belongs_to :review,
               class_name: "Westan::CriticReview",
               foreign_key: :review_id

    belongs_to :user,
               class_name: "::User",
               foreign_key: :user_id

    validates :vote, inclusion: { in: VOTES }
    validates :review_id, uniqueness: { scope: :user_id }
  end
end
