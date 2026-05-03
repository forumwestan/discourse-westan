# frozen_string_literal: true

module Westan
  class CriticAlbumsController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME

    before_action :ensure_logged_in, only: [:create, :update, :destroy, :toggle_favorite]

    def index
      scope = CriticAlbum.all
      scope = scope.where(type: params[:type]) if params[:type].present?
      scope = scope.released unless params[:include_upcoming] == "true"
      scope = scope.upcoming if params[:upcoming] == "true"

      if params[:released_since].present?
        scope = scope.where("release_date >= ?", params[:released_since])
      end

      order = params[:order] == "created" ? { created_at: :desc } : { release_date: :desc }
      scope = scope.order(order).limit((params[:limit] || 50).to_i)

      render_serialized(scope, CriticAlbumSerializer, root: "albums")
    end

    def show
      album = CriticAlbum.find_by!(slug: params[:slug])
      render_serialized(album, CriticAlbumSerializer, root: "album")
    end

    def create
      unless current_user.westan_can_add_critic_album?
        return render json: { error: I18n.t("westan.critic.add.quota_reached") }, status: 429
      end

      album = CriticAlbum.new(album_params.merge(created_by_id: current_user.id))
      if album.save
        render_serialized(album, CriticAlbumSerializer, root: "album")
      else
        render_json_error(album)
      end
    end

    def update
      album = CriticAlbum.find(params[:id])
      guardian_check!(album)
      if album.update(album_params)
        render_serialized(album, CriticAlbumSerializer, root: "album")
      else
        render_json_error(album)
      end
    end

    def destroy
      album = CriticAlbum.find(params[:id])
      guardian_check!(album)
      album.destroy!
      render json: success_json
    end

    def toggle_favorite
      album = CriticAlbum.find(params[:id])
      favorite = CriticFavorite.find_by(album_id: album.id, user_id: current_user.id)

      if favorite
        favorite.destroy!
        favorited = false
      else
        CriticFavorite.create!(album_id: album.id, user_id: current_user.id)
        favorited = true
      end

      render json: {
        favorited: favorited,
        favorite_count: album.favorites.count
      }
    end

    private

    def album_params
      params.permit(:title, :artist, :cover_url, :type, :release_date,
                    :is_upcoming, :spotify_url, :slug)
    end

    def guardian_check!(album)
      return if current_user.staff?
      return if album.created_by_id == current_user.id
      raise Discourse::InvalidAccess
    end
  end
end
