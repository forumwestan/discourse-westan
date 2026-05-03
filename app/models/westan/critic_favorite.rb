# frozen_string_literal: true

module Westan
  class CriticFavorite < ActiveRecord::Base
    self.table_name = "westan_critic_favorites"

    belongs_to :album,
               class_name: "Westan::CriticAlbum",
               foreign_key: :album_id

    belongs_to :user,
               class_name: "::User",
               foreign_key: :user_id

    validates :album_id, uniqueness: { scope: :user_id }
  end
end
