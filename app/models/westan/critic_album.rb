# frozen_string_literal: true

module Westan
  class CriticAlbum < ActiveRecord::Base
    self.table_name = "westan_critic_albums"

    TYPES = %w[album single].freeze

    has_many :reviews,
             class_name: "Westan::CriticReview",
             foreign_key: :album_id,
             dependent: :destroy

    belongs_to :created_by,
               class_name: "::User",
               foreign_key: :created_by_id,
               optional: true

    validates :title, presence: true
    validates :artist, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :type, inclusion: { in: TYPES }

    before_validation :ensure_slug

    scope :albums,  -> { where(type: "album") }
    scope :singles, -> { where(type: "single") }
    scope :released, -> { where(is_upcoming: false) }
    scope :upcoming, -> { where(is_upcoming: true) }

    def user_reviews
      reviews.where(is_critic: false)
    end

    def critic_reviews
      reviews.where(is_critic: true)
    end

    def avg_user_score
      user_reviews.average(:score)&.to_f&.round(1)
    end

    def avg_critic_score
      critic_reviews.average(:score)&.to_f&.round(1)
    end

    private

    def ensure_slug
      return if slug.present?
      base = "#{artist} #{title}".parameterize
      candidate = base
      i = 1
      while self.class.where(slug: candidate).where.not(id: id).exists?
        i += 1
        candidate = "#{base}-#{i}"
      end
      self.slug = candidate
    end
  end
end
