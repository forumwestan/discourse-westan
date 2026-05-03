# frozen_string_literal: true

module Westan
  class AdminController < ::ApplicationController
    requires_plugin Westan::PLUGIN_NAME
    before_action :ensure_logged_in, except: [:hero_cards]
    before_action :ensure_staff, except: [:hero_cards]

    HERO_CARDS_KEY = "critic_hero_cards"
    DEFAULT_HERO_CARDS = [
      {
        id: "critic-hero-1",
        title: "Adicione as avaliações de críticos especialistas",
        subtitle: "",
        background: "linear-gradient(135deg, #f463b4 0%, #ec4899 58%, #f05aa9 100%)",
        heroImage: "",
        ctaLabel: "Como funciona",
        ctaHref: "/critic/recent"
      }
    ].freeze

    def hero_cards
      render json: { cards: stored_hero_cards }
    end

    def update_hero_cards
      cards = params.require(:cards)
      cards = cards.values if cards.is_a?(ActionController::Parameters) || cards.is_a?(Hash)
      raise Discourse::InvalidParameters.new(:cards) unless cards.is_a?(Array)

      normalized = cards.map.with_index { |card, index| normalize_card(card, index) }
      PluginStore.set(Westan::PLUGIN_NAME, HERO_CARDS_KEY, normalized)

      render json: {
        success: true,
        cards: normalized
      }
    end

    private

    def ensure_staff
      raise Discourse::InvalidAccess unless current_user&.staff?
    end

    def stored_hero_cards
      cards = PluginStore.get(Westan::PLUGIN_NAME, HERO_CARDS_KEY)
      cards.is_a?(Array) && cards.present? ? cards : DEFAULT_HERO_CARDS
    end

    def normalize_card(card, index)
      data = card.respond_to?(:to_unsafe_h) ? card.to_unsafe_h : card.to_h

      {
        id: data["id"].presence || data[:id].presence || "critic-hero-#{index + 1}",
        title: data["title"].to_s,
        subtitle: data["subtitle"].to_s,
        background: data["background"].presence || "#000",
        heroImage: data["heroImage"].to_s,
        ctaLabel: data["ctaLabel"].to_s,
        ctaHref: data["ctaHref"].presence || "/critic"
      }
    end
  end
end
