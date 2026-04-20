# frozen_string_literal: true

# name: discourse-westan
# about: Westan features for Discourse — Charts (Last.fm) and Critic (albums/reviews) + hamburger side menu
# meta_topic_id: 0
# version: 0.1.0
# authors: Westan
# url: https://github.com/westan/discourse-westan
# required_version: 3.2.0

enabled_site_setting :westan_enabled

register_asset "stylesheets/westan/common.scss"
register_asset "stylesheets/westan/charts.scss"
register_asset "stylesheets/westan/critic.scss"
register_asset "stylesheets/westan/side-menu.scss"

register_svg_icon "star"
register_svg_icon "chart-line"
register_svg_icon "bars"
register_svg_icon "music"
register_svg_icon "pen-to-square"

module ::Westan
  PLUGIN_NAME = "discourse-westan"
end

require_relative "lib/westan/engine"

after_initialize do
  require_relative "app/models/westan/critic_album"
  require_relative "app/models/westan/critic_review"
  require_relative "app/serializers/westan/critic_album_serializer"
  require_relative "app/serializers/westan/critic_review_serializer"
  require_relative "app/controllers/westan/critic_albums_controller"
  require_relative "app/controllers/westan/critic_reviews_controller"
  require_relative "app/controllers/westan/lastfm_controller"
  require_relative "app/controllers/westan/deezer_controller"

  Discourse::Application.routes.append do
    mount ::Westan::Engine, at: "/westan"
  end

  Westan::Engine.routes.draw do
    # Critic
    get    "/critic/albums"                  => "critic_albums#index"
    get    "/critic/albums/:slug"            => "critic_albums#show"
    post   "/critic/albums"                  => "critic_albums#create"
    patch  "/critic/albums/:id"              => "critic_albums#update"
    delete "/critic/albums/:id"              => "critic_albums#destroy"

    get    "/critic/reviews"                 => "critic_reviews#index"
    post   "/critic/reviews"                 => "critic_reviews#create"
    patch  "/critic/reviews/:id"             => "critic_reviews#update"
    delete "/critic/reviews/:id"             => "critic_reviews#destroy"

    # Proxies to external APIs
    get    "/lastfm/:method"                 => "lastfm#proxy"
    get    "/deezer/search-album"            => "deezer#search_album"
  end

  # Extend User with Westan-specific capabilities
  add_to_class(:user, :westan_can_add_critic_album?) do
    return true if staff? || groups.where(name: SiteSetting.westan_critic_editor_group).exists?
    today = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    count = ::Westan::CriticAlbum.where(created_by_id: id, created_at: today).count
    count < SiteSetting.westan_critic_daily_quota
  end

  add_to_serializer(:current_user, :westan_is_critic_editor) do
    object.staff? ||
      object.groups.where(name: SiteSetting.westan_critic_editor_group).exists?
  end
end
