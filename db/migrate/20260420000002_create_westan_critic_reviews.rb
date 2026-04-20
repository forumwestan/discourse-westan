# frozen_string_literal: true

class CreateWestanCriticReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :westan_critic_reviews do |t|
      t.references :album, null: false, foreign_key: { to_table: :westan_critic_albums }
      t.integer :user_id
      t.integer :score, null: false
      t.text    :body
      t.boolean :is_critic,        null: false, default: false
      t.string  :critic_outlet
      t.string  :critic_name
      t.string  :review_url
      t.boolean :needs_correction, null: false, default: false
      t.timestamps
    end

    add_index :westan_critic_reviews, :user_id
    add_index :westan_critic_reviews, :is_critic
    # Ensure a user can only leave one non-press review per album
    add_index :westan_critic_reviews,
              [:album_id, :user_id],
              unique: true,
              where: "is_critic = false",
              name: "idx_westan_critic_reviews_unique_user_album"
  end
end
