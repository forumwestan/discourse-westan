import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import { ajax } from "discourse/lib/ajax";

const DEFAULT_CARDS = [
  {
    id: "critic-hero-1",
    title: "Adicione as avaliações de críticos especialistas",
    subtitle: "",
    background: "linear-gradient(135deg, #f463b4 0%, #ec4899 58%, #f05aa9 100%)",
    heroImage: "",
    ctaLabel: "Como funciona",
    ctaHref: "/critic/recent",
  },
];

export default class HeroSlider extends Component {
  @tracked activeIndex = 0;
  @tracked loadedCards = null;

  constructor() {
    super(...arguments);
    window.setTimeout(() => this.loadCards(), 0);
  }

  get cards() {
    return this.loadedCards?.length ? this.loadedCards : DEFAULT_CARDS;
  }

  get activeCard() {
    return this.cards[this.activeIndex] || this.cards[0];
  }

  get activeStyle() {
    return htmlSafe(`background: ${this.activeCard.background || DEFAULT_CARDS[0].background}`);
  }

  @action
  select(index) {
    this.activeIndex = index;
  }

  async loadCards() {
    try {
      const result = await ajax("/westan/critic/hero-cards");
      this.loadedCards = Array.isArray(result.cards) ? result.cards : DEFAULT_CARDS;
    } catch {
      this.loadedCards = DEFAULT_CARDS;
    }
  }

  <template>
    <section class="westan-critic-hero" style={{this.activeStyle}}>
      <div class="westan-critic-hero__copy">
        <div>
          <h1>{{this.activeCard.title}}</h1>
          {{#if this.activeCard.subtitle}}
            <p>{{this.activeCard.subtitle}}</p>
          {{/if}}
        </div>

        {{#if this.activeCard.ctaLabel}}
          <a href={{this.activeCard.ctaHref}} class="westan-critic-hero__cta">
            {{this.activeCard.ctaLabel}} →
          </a>
        {{/if}}
      </div>

      {{#if this.activeCard.heroImage}}
        <img
          src={{this.activeCard.heroImage}}
          alt=""
          aria-hidden="true"
          class="westan-critic-hero__image"
        />
      {{else}}
        <div class="westan-critic-hero__art" aria-hidden="true">
          <span>♪</span>
        </div>
      {{/if}}
    </section>

    <div class="westan-critic-hero__dots">
      {{#each this.cards as |card index|}}
        <button
          type="button"
          class={{if (eq this.activeIndex index) "is-active"}}
          aria-label={{card.title}}
          {{on "click" (fn this.select index)}}
        ></button>
      {{/each}}
    </div>
  </template>
}
