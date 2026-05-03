import { i18n } from "discourse-i18n";

<template>
<div class="westan-charts">
  <header class="westan-charts__header">
    <h1 class="westan-title">{{@model.artistName}}</h1>
  </header>

  <section class="westan-charts__section">
    <h2>{{i18n "westan.charts.top_albums"}}</h2>
    <div class="westan-grid">
      {{#each @model.albums as |album|}}
        <div class="westan-card">
          {{#if album.image.[2].#text}}
            <img src={{album.image.[2].#text}} alt={{album.name}} />
          {{/if}}
          <div class="westan-card__title">{{album.name}}</div>
        </div>
      {{/each}}
    </div>
  </section>

  <section class="westan-charts__section">
    <h2>{{i18n "westan.charts.top_tracks"}}</h2>
    <ol class="westan-list">
      {{#each @model.tracks as |track|}}
        <li>
          <span class="westan-list__title">{{track.name}}</span>
        </li>
      {{/each}}
    </ol>
  </section>
</div>
</template>
