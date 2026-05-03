import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class LastfmConnectForm extends Component {
  @service currentUser;
  @service router;

  @tracked username = this.args.username || "";
  @tracked saving = false;

  @action
  updateUsername(event) {
    this.username = event.target.value;
  }

  @action
  async submit(event) {
    event.preventDefault();

    this.saving = true;
    try {
      const result = await ajax("/westan/lastfm/username", {
        type: "PATCH",
        data: { username: this.username.trim() },
      });

      const savedUsername = result.lastfm_username;
      this.currentUser?.set?.("westan_lastfm_username", savedUsername);
      if (this.currentUser) {
        this.currentUser.custom_fields = this.currentUser.custom_fields || {};
        this.currentUser.custom_fields.lastfm_username = savedUsername;
      }

      this.router.transitionTo("westan-charts");
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  <template>
    <form class="westan-lastfm-form" {{on "submit" this.submit}}>
      <label>
        <span>{{i18n "westan.charts.lastfm_username"}}</span>
        <input
          type="text"
          value={{this.username}}
          placeholder={{i18n "westan.charts.lastfm_username_placeholder"}}
          {{on "input" this.updateUsername}}
        />
      </label>

      <button type="submit" disabled={{this.saving}}>
        {{i18n "westan.charts.save_lastfm"}}
      </button>
    </form>
  </template>
}
