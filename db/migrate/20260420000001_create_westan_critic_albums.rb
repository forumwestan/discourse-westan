# frozen_string_literal: true

class CreateWestanCriticAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :westan_critic_albums do |t|
      t.string  :slug,         null: false
      t.string  :title,        null: false
      t.string  :artist,       null: false
      t.string  :cover_url
      t.string  :type,         null: false, default: "album" # 'album' | 'single'
      t.date    :release_date
      t.boolean :is_upcoming,  null: false, default: false
      t.string  :spotify_url
      t.integer :created_by_id
      t.timestamps
    end

    add_index :westan_critic_albums, :slug, unique: true
    add_index :westan_critic_albums, :type
    add_index :westan_critic_albums, :is_upcoming
    add_index :westan_critic_albums, :release_date
    add_index :westan_critic_albums, :created_by_id
  end
end
