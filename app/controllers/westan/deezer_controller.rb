# frozen_string_literal: true

require "net/http"
require "json"

module Westan
  class DeezerController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME

    before_action :ensure_logged_in

    def search_album
      q = params[:q].to_s.strip
      return render json: { data: [] } if q.empty?

      base = SiteSetting.westan_deezer_api_base.presence || "https://api.deezer.com"
      uri = URI("#{base}/search/album?q=#{CGI.escape(q)}&limit=25")

      response = Net::HTTP.get_response(uri)
      return render json: response.body, status: response.code.to_i unless response.is_a?(Net::HTTPSuccess)

      payload = JSON.parse(response.body)
      requested_type = params[:type].to_s == "single" ? "single" : "album"
      data = Array(payload["data"]).map do |item|
        artist = item.dig("artist", "name").to_s
        title = item["title"].to_s
        item_type = item["record_type"].to_s == "single" ? "single" : requested_type
        existing = CriticAlbum.where("lower(title) = ? AND lower(artist) = ? AND type = ?",
                                     title.downcase, artist.downcase, item_type).first
        item.merge(
          "westan_type" => item_type,
          "westan_existing" => existing.present?,
          "westan_existing_slug" => existing&.slug
        )
      end

      render json: payload.merge("data" => data)
    end
  end
end
