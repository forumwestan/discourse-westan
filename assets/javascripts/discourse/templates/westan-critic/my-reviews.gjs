import { i18n } from "discourse-i18n";
import ReviewItem from "../../components/westan-critic/review-item";

<template>
<section class="westan-critic__section">
  <h1 class="westan-title">{{i18n "westan.critic.nav.my_reviews"}}</h1>
  {{#if @model.reviews.length}}
    <ul class="westan-review-list">
      {{#each @model.reviews as |review|}}
        <ReviewItem @review={{review}} />
      {{/each}}
    </ul>
  {{else}}
    <div class="westan-empty">{{i18n "westan.critic.album.no_reviews"}}</div>
  {{/if}}
</section>
</template>
