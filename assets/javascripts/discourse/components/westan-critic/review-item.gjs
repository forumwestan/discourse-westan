import Component from "@glimmer/component";

export default class ReviewItem extends Component {
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

  <template>
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
    </li>
  </template>
}
