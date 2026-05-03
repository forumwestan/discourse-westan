# frozen_string_literal: true

class CreateWestanCriticEngagements < ActiveRecord::Migration[7.0]
  def change
    create_table :westan_critic_favorites do |t|
      t.references :album, null: false, foreign_key: { to_table: :westan_critic_albums }
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :westan_critic_favorites,
              [:album_id, :user_id],
              unique: true,
              name: "idx_westan_critic_favorites_unique_album_user"
    add_index :westan_critic_favorites, :user_id

    create_table :westan_critic_review_votes do |t|
      t.references :review, null: false, foreign_key: { to_table: :westan_critic_reviews }
      t.integer :user_id, null: false
      t.string :vote, null: false
      t.timestamps
    end

    add_index :westan_critic_review_votes,
              [:review_id, :user_id],
              unique: true,
              name: "idx_westan_critic_votes_unique_review_user"
    add_index :westan_critic_review_votes, :user_id
  end
end
