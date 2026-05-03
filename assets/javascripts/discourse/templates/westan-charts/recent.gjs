import { i18n } from "discourse-i18n";

<template>
<div class="westan-charts">
  <header class="westan-charts__header">
    <h1 class="westan-title">{{i18n "westan.charts.recent_tracks"}}</h1>
  </header>

  {{#unless @model.hasLastfm}}
    <div class="westan-empty">{{i18n "westan.charts.no_lastfm"}}</div>
  {{else}}
    <ol class="westan-list">
      {{#each @model.tracks as |track|}}
        <li>
          <span class="westan-list__title">{{track.name}}</span>
          <span class="westan-list__meta">{{track.artist.#text}}</span>
        </li>
      {{/each}}
    </ol>
  {{/unless}}
</div>
</template>
