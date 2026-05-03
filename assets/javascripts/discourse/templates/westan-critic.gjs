import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";

<template>
<div class="westan-shell westan-critic-shell">
  <nav class="westan-critic__nav">
    <LinkTo @route="westan-critic.index" class="westan-critic__nav-link">{{i18n "westan.critic.nav.home"}}</LinkTo>
    {{#if this.currentUser}}
      <LinkTo @route="westan-critic.my-reviews" class="westan-critic__nav-link">{{i18n "westan.critic.nav.my_reviews"}}</LinkTo>
    {{/if}}
    <LinkTo @route="westan-critic.releases" class="westan-critic__nav-link">{{i18n "westan.critic.nav.releases"}}</LinkTo>
    <LinkTo @route="westan-critic.recent" class="westan-critic__nav-link">{{i18n "westan.critic.nav.recent"}}</LinkTo>
  </nav>
  {{outlet}}
</div>
</template>
