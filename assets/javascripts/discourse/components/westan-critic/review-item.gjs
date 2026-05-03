import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class ReviewItem extends Component {
  @service currentUser;
  @service router;

  @tracked isDeleted = false;
  @tracked likesCount = Number(this.args.review.likes_count || 0);
  @tracked dislikesCount = Number(this.args.review.dislikes_count || 0);
  @tracked myVote = this.args.review.my_vote || null;

  get displayName() {
    return this.args.review.display_name || this.args.review.username || "Usuário";
  }

  get byline() {
    if (this.args.review.is_critic) {
      return this.args.review.critic_outlet || "Veículo";
    }

    return this.displayName;
  }

  get avatarUrl() {
    const template = this.args.review.avatar_template;

    if (template) {
      return template.replace("{size}", "96");
    }

    return null;
  }

  get initial() {
    return this.displayName.charAt(0).toUpperCase();
  }

  get dateLabel() {
    if (!this.args.review.created_at) {
      return "";
    }

    return new Date(this.args.review.created_at).toLocaleDateString("pt-BR");
  }

  get scoreToneClass() {
    const score = Number(this.args.review.score || 0);

    if (score >= 70) {
      return "is-positive";
    }

    if (score >= 50) {
      return "is-mixed";
    }

    return "is-negative";
  }

  get canDelete() {
    return this.args.review.editable_by_current_user;
  }

  @action
  async vote(vote) {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }

    try {
      const result = await ajax(`/westan/critic/reviews/${this.args.review.id}/vote`, {
        type: "POST",
        data: { vote },
      });
      this.likesCount = result.likes_count;
      this.dislikesCount = result.dislikes_count;
      this.myVote = result.my_vote;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async deleteReview() {
    if (!this.canDelete) {
      return;
    }

    try {
      await ajax(`/westan/critic/reviews/${this.args.review.id}`, {
        type: "DELETE",
      });
      this.isDeleted = true;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    {{#unless this.isDeleted}}
      <li class="westan-review-item">
        <div class="westan-review-item__person">
          {{#unless @review.is_critic}}
            {{#if this.avatarUrl}}
              <img
                src={{this.avatarUrl}}
                alt={{this.displayName}}
                class="westan-review-item__avatar"
              />
            {{else}}
              <span class="westan-review-item__avatar westan-review-item__avatar--fallback">
                {{this.initial}}
              </span>
            {{/if}}
          {{/unless}}
          <div>
            <div class="westan-review-item__meta">{{this.byline}}</div>
            {{#if this.dateLabel}}
              <div class="westan-review-item__date">{{this.dateLabel}}</div>
            {{/if}}
          </div>
        </div>

        {{#if @review.body}}
          <p class="westan-review-item__body">{{@review.body}}</p>
        {{/if}}

        <div class="westan-review-item__score {{this.scoreToneClass}}">{{@review.score}}</div>

        <div class="westan-review-item__tools">
          {{#if this.canDelete}}
            <button
              type="button"
              class="westan-review-item__delete"
              aria-label="Excluir avaliação"
              {{on "click" this.deleteReview}}
            >
              ×
            </button>
          {{/if}}

          {{#if @review.review_url}}
            <a
              href={{@review.review_url}}
              target="_blank"
              rel="noopener"
              class="westan-review-item__link"
            >
              Ler
            </a>
          {{/if}}

          <div class="westan-review-item__votes">
            <button
              type="button"
              class={{if (eq this.myVote "like") "is-active"}}
              aria-label="Curtir avaliação"
              {{on "click" (fn this.vote "like")}}
            >
              ♧ {{#if this.likesCount}}<span>{{this.likesCount}}</span>{{/if}}
            </button>
            <button
              type="button"
              class={{if (eq this.myVote "dislike") "is-active is-dislike" "is-dislike"}}
              aria-label="Não curtir avaliação"
              {{on "click" (fn this.vote "dislike")}}
            >
              ♤ {{#if this.dislikesCount}}<span>{{this.dislikesCount}}</span>{{/if}}
            </button>
          </div>
        </div>
      </li>
    {{/unless}}
  </template>
}
