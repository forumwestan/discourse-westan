import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import { fn } from "@ember/helper";
import { i18n } from "discourse-i18n";
import { on } from "@ember/modifier";

export default class ReviewForm extends Component {
  @tracked score = this.args.existing?.score ?? 70;
  @tracked body = this.args.existing?.body ?? "";
  @tracked saving = false;

  @action
  updateScore(event) {
    this.score = parseInt(event.target.value, 10);
  }

  @action
  updateBody(event) {
    this.body = event.target.value;
  }

  @action
  async submit() {
    this.saving = true;
    try {
      const payload = {
        album_id: this.args.album.id,
        score: this.score,
        body: this.body,
        is_critic: false,
      };

      if (this.args.existing?.id) {
        await ajax(`/westan/critic/reviews/${this.args.existing.id}`, {
          type: "PATCH",
          data: payload,
        });
      } else {
        await ajax(`/westan/critic/reviews`, { type: "POST", data: payload });
      }

      this.args.onSaved?.();
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  <template>
    <form class="westan-review-form" {{on "submit" (fn this.submit)}}>
      <label>
        {{i18n "westan.critic.review.score_label"}}
        <input type="number" min="0" max="100" value={{this.score}} {{on "input" this.updateScore}} />
      </label>
      <label>
        {{i18n "westan.critic.review.body_label"}}
        <textarea rows="8" {{on "input" this.updateBody}}>{{this.body}}</textarea>
      </label>
      <DButton
        @action={{this.submit}}
        @translatedLabel={{i18n "westan.critic.review.save"}}
        @disabled={{this.saving}}
        class="btn-primary"
      />
    </form>
  </template>
}
