import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import ScoreMeter from "./score-meter";

export default class MyReviewRow extends Component {
  get routeName() {
    return this.args.review?.album_type === "single"
      ? "westan-critic.single"
      : "westan-critic.album";
  }

  get title() {
    return this.args.review?.album_title || "Westan Critic";
  }

  get artist() {
    return this.args.review?.album_artist || "";
  }

  get slug() {
    return this.args.review?.album_slug;
  }

  <template>
    <li>
      <LinkTo @route={{this.routeName}} @model={{this.slug}} class="westan-my-review-row">
        <div class="westan-my-review-row__cover">
          {{#if @review.album_cover_url}}
            <img src={{@review.album_cover_url}} alt={{this.title}} />
          {{else}}
            <span>{{this.title}}</span>
          {{/if}}
        </div>

        <div class="westan-my-review-row__body">
          <strong>{{this.title}}</strong>
          <span>{{this.artist}}</span>
          <ScoreMeter @label="usuários" @score={{@review.score}} @compact={{true}} />
        </div>
      </LinkTo>
    </li>
  </template>
}
