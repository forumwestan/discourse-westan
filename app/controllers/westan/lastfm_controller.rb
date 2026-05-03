# frozen_string_literal: true

require "net/http"
require "json"

module Westan
  class LastfmController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME
    before_action :ensure_logged_in, only: [:update_username]

    ALLOWED_METHODS = %w[
      user.gettopartists
      user.gettopalbums
      user.gettoptracks
      user.getrecenttracks
      user.getweeklychartlist
      user.getweeklyalbumchart
      user.getweeklyartistchart
      user.getweeklytrackchart
      artist.getinfo
      artist.gettopalbums
      artist.gettoptracks
    ].freeze

    def proxy
      method = lastfm_method
      unless ALLOWED_METHODS.include?(method)
        return render json: {
          error: "method not allowed",
          method: method,
          allowed_methods: ALLOWED_METHODS
        }, status: 400
      end

      api_key = SiteSetting.westan_lastfm_api_key
      if api_key.blank?
        return render json: { error: "Last.fm API key not configured" }, status: 503
      end

      query = request.query_parameters.except("method").merge(
        method: method,
        api_key: api_key,
        format: "json"
      )

      uri = URI("https://ws.audioscrobbler.com/2.0/?#{query.to_query}")
      response = Net::HTTP.get_response(uri)

      render json: response.body, status: response.code.to_i
    end

    def update_username
      username = params[:username].to_s.strip
      if username.blank?
        return render json: { error: I18n.t("westan.charts.lastfm_username_required") }, status: 422
      end

      current_user.custom_fields["lastfm_username"] = username
      current_user.save_custom_fields

      render json: {
        success: true,
        lastfm_username: username
      }
    end

    private

    def lastfm_method
      method = params[:method].to_s
      format = params[:format].to_s

      if format.present? && !method.include?(".")
        method = "#{method}.#{format}"
      end

      method.downcase
    end
  end
end
