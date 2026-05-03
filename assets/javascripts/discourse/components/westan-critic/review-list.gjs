import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import ReviewItem from "./review-item";

const FILTERS = [
  { key: "all", label: "Todas" },
  { key: "positive", label: "Positivas (70+)" },
  { key: "mixed", label: "Mistas (50–69)" },
  { key: "negative", label: "Negativas (< 50)" },
];

export default class ReviewList extends Component {
  @tracked filter = "all";
  @tracked filterOpen = false;

  get filters() {
    return FILTERS;
  }

  get activeFilterLabel() {
    return FILTERS.find((item) => item.key === this.filter)?.label || "Todas";
  }

  get filteredReviews() {
    const reviews = this.args.reviews || [];

    switch (this.filter) {
      case "positive":
        return reviews.filter((review) => review.score >= 70);
      case "mixed":
        return reviews.filter((review) => review.score >= 50 && review.score < 70);
      case "negative":
        return reviews.filter((review) => review.score < 50);
      default:
        return reviews;
    }
  }

  @action
  toggleFilter() {
    this.filterOpen = !this.filterOpen;
  }

  @action
  selectFilter(filter) {
    this.filter = filter;
    this.filterOpen = false;
  }

  <template>
    <div class="westan-album-page__reviews-header">
      <h2>{{@title}}</h2>
      <div class="westan-review-filter">
        <button
          type="button"
          class="westan-album-page__filter-button"
          {{on "click" this.toggleFilter}}
        >
          ⚚ {{this.activeFilterLabel}}
        </button>

        {{#if this.filterOpen}}
          <div class="westan-review-filter__menu">
            {{#each this.filters as |filter|}}
              <button type="button" {{on "click" (fn this.selectFilter filter.key)}}>
                <span>{{filter.label}}</span>
                {{#if (eq this.filter filter.key)}}<strong>✓</strong>{{/if}}
              </button>
            {{/each}}
          </div>
        {{/if}}
      </div>
    </div>

    {{#if this.filteredReviews.length}}
      <ul class="westan-review-list">
        {{#each this.filteredReviews as |review|}}
          <ReviewItem @review={{review}} />
        {{/each}}
      </ul>
    {{else}}
      <div class="westan-empty">{{@emptyText}}</div>
    {{/if}}
  </template>
}
