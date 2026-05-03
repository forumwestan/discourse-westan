import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export default class ScoreMeter extends Component {
  get score() {
    return Number(this.args.score || 0);
  }

  get hasScore() {
    return this.score > 0;
  }

  get style() {
    return htmlSafe(`--westan-score-width: ${Math.max(0, Math.min(this.score, 100))}%`);
  }

  get toneClass() {
    if (this.score >= 70) {
      return "is-positive";
    }

    if (this.score >= 50) {
      return "is-mixed";
    }

    return "is-negative";
  }

  get compactClass() {
    return this.args.compact ? "is-compact" : "";
  }

  <template>
    {{#if this.hasScore}}
      <div
        class="westan-score-meter {{this.toneClass}} {{this.compactClass}}"
        style={{this.style}}
      >
        <div class="westan-score-meter__top">
          <span class="westan-score-meter__label">
            {{@label}}{{#if @count}} ({{@count}}){{/if}}
          </span>
          <span class="westan-score-meter__value">{{this.score}}</span>
        </div>
        <div class="westan-score-meter__track">
          <div class="westan-score-meter__bar"></div>
        </div>
      </div>
    {{/if}}
  </template>
}
