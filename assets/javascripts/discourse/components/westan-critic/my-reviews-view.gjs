import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { tracked } from "@glimmer/tracking";
import MyReviewRow from "./my-review-row";

export default class MyReviewsView extends Component {
  @tracked tab = "album";

  get reviews() {
    return this.args.reviews || [];
  }

  get albumReviews() {
    return this.reviews.filter((review) => review.album_type !== "single");
  }

  get singleReviews() {
    return this.reviews.filter((review) => review.album_type === "single");
  }

  get activeReviews() {
    return this.tab === "single" ? this.singleReviews : this.albumReviews;
  }

  get albumTabClass() {
    return this.tab === "album" ? "is-active" : "";
  }

  get singleTabClass() {
    return this.tab === "single" ? "is-active" : "";
  }

  get totalLabel() {
    return this.tab === "single"
      ? "Total de singles avaliados"
      : "Total de álbuns avaliados";
  }

  @action
  setTab(tab) {
    this.tab = tab;
  }

  <template>
    <section class="westan-critic__section westan-my-reviews">
      <h1 class="westan-title">Oi, {{@username}}</h1>

      <div class="westan-my-reviews__switch" role="tablist" aria-label="Tipo de avaliação">
        <button
          type="button"
          class={{this.albumTabClass}}
          {{on "click" (fn this.setTab "album")}}
        >
          Álbuns
        </button>
        <button
          type="button"
          class={{this.singleTabClass}}
          {{on "click" (fn this.setTab "single")}}
        >
          Singles
        </button>
      </div>

      <div class="westan-my-reviews__total">
        <span>{{this.totalLabel}}</span>
        <strong>{{this.activeReviews.length}}</strong>
      </div>

      {{#if this.activeReviews.length}}
        <ul class="westan-my-reviews__list">
          {{#each this.activeReviews as |review|}}
            <MyReviewRow @review={{review}} />
          {{/each}}
        </ul>
      {{else}}
        <div class="westan-empty">Nenhuma avaliação ainda.</div>
      {{/if}}
    </section>
  </template>
}
