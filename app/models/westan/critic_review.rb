# frozen_string_literal: true

module Westan
  class CriticReview < ActiveRecord::Base
    self.table_name = "westan_critic_reviews"

    belongs_to :album,
               class_name: "Westan::CriticAlbum",
               foreign_key: :album_id

    belongs_to :user,
               class_name: "::User",
               foreign_key: :user_id,
               optional: true

    validates :score, presence: true,
                      numericality: { only_integer: true, in: 0..100 }

    validate :press_or_user_consistency

    scope :press, -> { where(is_critic: true) }
    scope :users, -> { where(is_critic: false) }

    def editable_by?(actor)
      return false unless actor
      return true if actor.staff?
      user_id == actor.id
    end

    private

    def press_or_user_consistency
      if is_critic
        errors.add(:critic_name, "required for press reviews") if critic_name.blank? && critic_outlet.blank?
      else
        errors.add(:user_id, "required for user reviews") if user_id.blank?
      end
    end
  end
end
