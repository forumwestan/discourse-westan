import { i18n } from "discourse-i18n";
import AlbumCard from "../../components/westan-critic/album-card";

<template>
<section class="westan-critic__section">
  <h1 class="westan-title">{{i18n "westan.critic.title"}}</h1>
</section>

{{#if @model.upcoming}}
  <section class="westan-critic__section">
    <h2>Upcoming</h2>
    <AlbumCard @album={{@model.upcoming}} />
  </section>
{{/if}}

<section class="westan-critic__section">
  <h2>This week</h2>
  <div class="westan-grid">
    {{#each @model.thisWeek as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>

<section class="westan-critic__section">
  <h2>Recent albums</h2>
  <div class="westan-grid">
    {{#each @model.recentAlbums as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>

<section class="westan-critic__section">
  <h2>Recent singles</h2>
  <div class="westan-grid">
    {{#each @model.recentSingles as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>
</template>
