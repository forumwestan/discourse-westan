import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { LinkTo } from "@ember/routing";
import { i18n } from "discourse-i18n";
import dIcon from "discourse/helpers/d-icon";

export default class WestanSideMenu extends Component {
  @service currentUser;
  @service siteSettings;
  @service router;

  @tracked isOpen = false;

  get extraItems() {
    try {
      return JSON.parse(this.siteSettings.westan_side_menu_items_json || "[]");
    } catch {
      return [];
    }
  }

  get canSeeAdmin() {
    return this.currentUser?.admin;
  }

  get canSeeMod() {
    return this.currentUser?.admin || this.currentUser?.moderator;
  }

  @action
  toggle() {
    this.isOpen = !this.isOpen;
    document.body.classList.toggle("westan-side-menu-open", this.isOpen);
  }

  @action
  close() {
    this.isOpen = false;
    document.body.classList.remove("westan-side-menu-open");
  }

  <template>
    <button
      type="button"
      class="westan-hamburger"
      aria-label={{i18n "westan.side_menu.open"}}
      {{on "click" this.toggle}}
    >
      {{dIcon "bars"}}
    </button>

    {{#if this.isOpen}}
      <div class="westan-side-menu__backdrop" {{on "click" this.close}}></div>
      <aside class="westan-side-menu" aria-label="Westan menu">
        <header class="westan-side-menu__header">
          {{#if this.currentUser}}
            <LinkTo @route="user" @model={{this.currentUser.username}} class="westan-side-menu__avatar">
              <img src={{this.currentUser.avatar_template}} alt={{this.currentUser.username}} />
            </LinkTo>
          {{/if}}
          <button type="button" class="westan-side-menu__close" {{on "click" this.close}} aria-label={{i18n "westan.side_menu.close"}}>
            ×
          </button>
        </header>

        <nav class="westan-side-menu__body">
          {{#if this.currentUser}}
            <div class="westan-side-menu__quick">
              {{#if this.canSeeAdmin}}
                <LinkTo @route="admin" {{on "click" this.close}}>{{i18n "westan.side_menu.admin_panel"}}</LinkTo>
              {{/if}}
              {{#if this.canSeeMod}}
                <LinkTo @route="review" {{on "click" this.close}}>{{i18n "westan.side_menu.moderation_panel"}}</LinkTo>
              {{/if}}
            </div>
          {{/if}}

          {{#if this.siteSettings.westan_charts_enabled}}
            <LinkTo @route="westan-charts" class="westan-side-menu__link westan-side-menu__link--widget" {{on "click" this.close}}>
              <span class="westan-side-menu__link-icon">♪</span>
              Westan Charts
            </LinkTo>
          {{/if}}

          {{#if this.siteSettings.westan_critic_enabled}}
            <LinkTo @route="westan-critic" class="westan-side-menu__link westan-side-menu__link--widget" {{on "click" this.close}}>
              <span class="westan-side-menu__link-icon">★</span>
              Westan Critic
            </LinkTo>
          {{/if}}

          {{#each this.extraItems as |item|}}
            {{#if item.visible}}
              <a href={{item.path}} class="westan-side-menu__link" {{on "click" this.close}}>
                {{#if item.icon}}<span class="westan-side-menu__link-icon">{{item.icon}}</span>{{/if}}
                {{item.label}}
              </a>
            {{/if}}
          {{/each}}

          {{#unless this.currentUser}}
            <LinkTo @route="login" class="btn btn-primary westan-side-menu__login" {{on "click" this.close}}>
              {{i18n "westan.side_menu.login"}}
            </LinkTo>
          {{/unless}}
        </nav>
      </aside>
    {{/if}}
  </template>
}
