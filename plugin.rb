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
  require_relative "app/models/westan/critic_favorite"
  require_relative "app/models/westan/critic_review_vote"
  require_relative "app/serializers/westan/critic_album_serializer"
  require_relative "app/serializers/westan/critic_review_serializer"
  require_relative "app/controllers/westan/critic_albums_controller"
  require_relative "app/controllers/westan/critic_reviews_controller"
  require_relative "app/controllers/westan/lastfm_controller"
  require_relative "app/controllers/westan/deezer_controller"

  Westan::Engine.routes.draw do
    # Critic
    get    "/critic/albums"                  => "critic_albums#index"
    get    "/critic/albums/:slug"            => "critic_albums#show"
    post   "/critic/albums"                  => "critic_albums#create"
    patch  "/critic/albums/:id"              => "critic_albums#update"
    delete "/critic/albums/:id"              => "critic_albums#destroy"
    post   "/critic/albums/:id/favorite"     => "critic_albums#toggle_favorite"

    get    "/critic/reviews"                 => "critic_reviews#index"
    post   "/critic/reviews"                 => "critic_reviews#create"
    patch  "/critic/reviews/:id"             => "critic_reviews#update"
    delete "/critic/reviews/:id"             => "critic_reviews#destroy"
    post   "/critic/reviews/:id/vote"        => "critic_reviews#vote"

    # Proxies to external APIs
    get    "/lastfm/:method"                 => "lastfm#proxy"
    get    "/deezer/search-album"            => "deezer#search_album"
  end

  Discourse::Application.routes.prepend do
    # Register direct Discourse routes so the JSON APIs are not swallowed by the
    # app fallback route before the mounted engine gets a chance to answer.
    get    "/westan/critic/albums"           => "westan/critic_albums#index"
    get    "/westan/critic/albums/:slug"     => "westan/critic_albums#show"
    post   "/westan/critic/albums"           => "westan/critic_albums#create"
    patch  "/westan/critic/albums/:id"       => "westan/critic_albums#update"
    delete "/westan/critic/albums/:id"       => "westan/critic_albums#destroy"
    post   "/westan/critic/albums/:id/favorite" => "westan/critic_albums#toggle_favorite"

    get    "/westan/critic/reviews"          => "westan/critic_reviews#index"
    post   "/westan/critic/reviews"          => "westan/critic_reviews#create"
    patch  "/westan/critic/reviews/:id"      => "westan/critic_reviews#update"
    delete "/westan/critic/reviews/:id"      => "westan/critic_reviews#destroy"
    post   "/westan/critic/reviews/:id/vote" => "westan/critic_reviews#vote"

    get    "/westan/lastfm/:method"          => "westan/lastfm#proxy"
    get    "/westan/deezer/search-album"     => "westan/deezer#search_album"
  end

  User.register_custom_field_type("lastfm_username", :text)
  register_editable_user_custom_field :lastfm_username
  DiscoursePluginRegistry.serialized_current_user_fields << "lastfm_username"

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

  add_to_serializer(:current_user, :westan_lastfm_username) do
    object.custom_fields["lastfm_username"]
  end
end
