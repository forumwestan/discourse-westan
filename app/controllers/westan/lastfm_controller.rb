# frozen_string_literal: true

require "net/http"
require "json"
require "digest/md5"

module Westan
  class LastfmController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME
    before_action :ensure_logged_in, only: [:auth_url, :create_session, :update_username]

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

    def auth_url
      api_key = SiteSetting.westan_lastfm_api_key
      if api_key.blank?
        return render json: { error: "Last.fm API key not configured" }, status: 503
      end

      callback_url = params[:callback_url].presence || "#{Discourse.base_url}/charts/connect"
      url = "https://www.last.fm/api/auth/?#{{
        api_key: api_key,
        cb: callback_url
      }.to_query}"

      render json: { auth_url: url }
    end

    def create_session
      token = params[:token].to_s.strip
      if token.blank?
        return render json: { error: "Last.fm token is required" }, status: 422
      end

      api_key = SiteSetting.westan_lastfm_api_key
      shared_secret = SiteSetting.westan_lastfm_shared_secret
      if api_key.blank? || shared_secret.blank?
        return render json: { error: "Last.fm API key or shared secret not configured" }, status: 503
      end

      query = {
        method: "auth.getSession",
        api_key: api_key,
        token: token
      }
      query[:api_sig] = api_signature(query, shared_secret)
      query[:format] = "json"

      uri = URI("https://ws.audioscrobbler.com/2.0/?#{query.to_query}")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body) rescue {}

      if !response.is_a?(Net::HTTPSuccess) || data["error"].present?
        return render json: {
          error: data["message"].presence || "Last.fm authorization failed",
          lastfm_error: data["error"]
        }, status: 422
      end

      session = data["session"] || {}
      username = session["name"].to_s
      session_key = session["key"].to_s

      if username.blank? || session_key.blank?
        return render json: { error: "Invalid Last.fm session response" }, status: 422
      end

      current_user.custom_fields["lastfm_username"] = username
      current_user.custom_fields["lastfm_session_key"] = session_key
      current_user.save_custom_fields

      render json: {
        success: true,
        lastfm_username: username
      }
    end

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

    def api_signature(params, shared_secret)
      signature_base = params
        .reject { |key, _| %i[format callback].include?(key.to_sym) }
        .sort_by { |key, _| key.to_s }
        .map { |key, value| "#{key}#{value}" }
        .join

      Digest::MD5.hexdigest("#{signature_base}#{shared_secret}")
    end
  end
end
