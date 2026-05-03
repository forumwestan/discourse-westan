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
  @tracked authenticating = false;

  constructor() {
    super(...arguments);

    if (this.args.token) {
      window.setTimeout(() => this.finishLastfmAuth(this.args.token), 0);
    }
  }

  @action
  updateUsername(event) {
    this.username = event.target.value;
  }

  @action
  async connectWithLastfm() {
    this.authenticating = true;

    try {
      const callbackUrl = `${window.location.origin}/charts/connect`;
      const result = await ajax("/westan/lastfm/auth-url", {
        data: { callback_url: callbackUrl },
      });

      window.location.href = result.auth_url;
    } catch (e) {
      this.authenticating = false;
      popupAjaxError(e);
    }
  }

  async finishLastfmAuth(token) {
    if (this.authenticating) {
      return;
    }

    this.authenticating = true;
    try {
      const result = await ajax("/westan/lastfm/session", {
        type: "POST",
        data: { token },
      });

      this.updateCurrentUser(result.lastfm_username);
      this.router.transitionTo("westan-charts");
    } catch (e) {
      popupAjaxError(e);
      this.router.transitionTo("westan-charts.connect");
    } finally {
      this.authenticating = false;
    }
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

      this.updateCurrentUser(result.lastfm_username);

      this.router.transitionTo("westan-charts");
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  updateCurrentUser(savedUsername) {
    this.currentUser?.set?.("westan_lastfm_username", savedUsername);
    if (this.currentUser) {
      this.currentUser.custom_fields = this.currentUser.custom_fields || {};
      this.currentUser.custom_fields.lastfm_username = savedUsername;
    }
  }

  <template>
    {{#if this.authenticating}}
      <div class="westan-lastfm-form westan-lastfm-form--status">
        {{i18n "westan.charts.finishing_lastfm"}}
      </div>
    {{else}}
      <button
        type="button"
        class="westan-lastfm-auth-button"
        disabled={{this.authenticating}}
        {{on "click" this.connectWithLastfm}}
      >
        {{i18n "westan.charts.authorize_lastfm"}}
      </button>

      <div class="westan-lastfm-divider">
        {{i18n "westan.charts.or_connect_manually"}}
      </div>

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
    {{/if}}
  </template>
}
