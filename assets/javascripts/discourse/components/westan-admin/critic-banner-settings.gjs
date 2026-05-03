import Component from "@glimmer/component";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import { on } from "@ember/modifier";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "truth-helpers";

const DEFAULT_CARD = {
  title: "Adicione as avaliações de críticos especialistas",
  subtitle: "",
  background: "linear-gradient(135deg, #f463b4 0%, #ec4899 58%, #f05aa9 100%)",
  heroImage: "",
  ctaLabel: "Como funciona",
  ctaHref: "/critic/recent",
};

function cloneCards(cards) {
  return (cards || []).map((card, index) => ({
    id: card.id || `critic-hero-${index + 1}`,
    title: card.title || "",
    subtitle: card.subtitle || "",
    background: card.background || "#000",
    heroImage: card.heroImage || "",
    ctaLabel: card.ctaLabel || "",
    ctaHref: card.ctaHref || "/critic",
  }));
}

export default class CriticBannerSettings extends Component {
  @tracked cards = cloneCards(this.args.cards);
  @tracked activeIndex = 0;
  @tracked saving = false;

  get activeCard() {
    return this.cards[this.activeIndex] || this.cards[0] || DEFAULT_CARD;
  }

  get activeBannerNumber() {
    return this.activeIndex + 1;
  }

  get cardsWithLabels() {
    return this.cards.map((card, index) => ({
      ...card,
      label: `Banner ${index + 1}`,
      tabClass: index === this.activeIndex ? "is-active" : "",
      index,
    }));
  }

  get previewStyle() {
    return htmlSafe(`background: ${this.activeCard.background || "#000"}`);
  }

  @action
  select(index) {
    this.activeIndex = index;
  }

  @action
  addCard() {
    this.cards = [
      ...this.cards,
      {
        ...DEFAULT_CARD,
        id: `critic-hero-${Date.now()}`,
        title: `Banner ${this.cards.length + 1}`,
      },
    ];
    this.activeIndex = this.cards.length - 1;
  }

  @action
  removeCard() {
    if (this.cards.length <= 1) {
      return;
    }

    this.cards = this.cards.filter((_, index) => index !== this.activeIndex);
    this.activeIndex = Math.max(0, this.activeIndex - 1);
  }

  @action
  updateField(field, event) {
    const value = event.target.value;
    this.cards = this.cards.map((card, index) => {
      if (index !== this.activeIndex) {
        return card;
      }

      return { ...card, [field]: value };
    });
  }

  @action
  async save() {
    this.saving = true;

    try {
      const result = await ajax("/westan/admin/critic-hero-cards", {
        type: "PATCH",
        data: { cards: this.cards },
      });

      this.cards = cloneCards(result.cards);
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  <template>
    <section class="westan-admin-banners">
      <header class="westan-admin-banners__header">
        <div>
          <h1>Westan Critic banners</h1>
          <p>Configure os hero cards da home sem editar JSON.</p>
        </div>

        <button type="button" class="westan-admin-banners__add" {{on "click" this.addCard}}>
          + Adicionar
        </button>
      </header>

      <div class="westan-admin-banners__tabs">
        {{#each this.cardsWithLabels as |card|}}
          <button
            type="button"
            class={{card.tabClass}}
            {{on "click" (fn this.select card.index)}}
          >
            {{card.label}}
          </button>
        {{/each}}
      </div>

      <div class="westan-admin-banners__panel">
        <div class="westan-admin-banners__panel-header">
          <div>
            <strong>Banner {{this.activeBannerNumber}}</strong>
            <span>{{this.cards.length}} banners configurados</span>
          </div>

          <button
            type="button"
            class="westan-admin-banners__remove"
            disabled={{eq this.cards.length 1}}
            {{on "click" this.removeCard}}
          >
            Remover
          </button>
        </div>

        <div class="westan-admin-banners__preview" style={{this.previewStyle}}>
          <div>
            <strong>{{this.activeCard.title}}</strong>
            {{#if this.activeCard.subtitle}}
              <span>{{this.activeCard.subtitle}}</span>
            {{/if}}
            {{#if this.activeCard.ctaLabel}}
              <em>{{this.activeCard.ctaLabel}} →</em>
            {{/if}}
          </div>
          {{#if this.activeCard.heroImage}}
            <img src={{this.activeCard.heroImage}} alt="" />
          {{else}}
            <b>★</b>
          {{/if}}
        </div>

        <label>
          Texto principal
          <input value={{this.activeCard.title}} {{on "input" (fn this.updateField "title")}} />
        </label>

        <label>
          Subtexto
          <input value={{this.activeCard.subtitle}} placeholder="Texto secundário (opcional)" {{on "input" (fn this.updateField "subtitle")}} />
        </label>

        <label>
          Background CSS
          <input value={{this.activeCard.background}} placeholder="#000 ou linear-gradient(...)" {{on "input" (fn this.updateField "background")}} />
        </label>

        <label>
          Imagem hero (URL)
          <input value={{this.activeCard.heroImage}} placeholder="https://..." {{on "input" (fn this.updateField "heroImage")}} />
        </label>

        <div class="westan-admin-banners__grid">
          <label>
            Botão CTA - label
            <input value={{this.activeCard.ctaLabel}} {{on "input" (fn this.updateField "ctaLabel")}} />
          </label>

          <label>
            Botão CTA - link
            <input value={{this.activeCard.ctaHref}} {{on "input" (fn this.updateField "ctaHref")}} />
          </label>
        </div>

        <div class="westan-admin-banners__footer">
          <a href="/admin/site_settings/category/plugins?filter=westan">Voltar às configurações</a>
          <button type="button" disabled={{this.saving}} {{on "click" this.save}}>
            {{if this.saving "Salvando..." "Salvar"}}
          </button>
        </div>
      </div>
    </section>
  </template>
}
