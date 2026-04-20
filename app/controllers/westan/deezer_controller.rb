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
      render json: response.body, status: response.code.to_i
    end
  end
end
