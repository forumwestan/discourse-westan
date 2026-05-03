import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";

<template>
<div class="westan-charts">
  <header class="westan-charts__header">
    <h1 class="westan-title">{{i18n "westan.charts.title"}}</h1>
  </header>

  {{#unless @model.hasLastfm}}
    <div class="westan-empty westan-charts-connect">
      <p>{{i18n "westan.charts.no_lastfm"}}</p>
      <a href={{@model.profileUrl}} class="westan-charts-connect__button">
        {{#if @model.isLoggedIn}}
          {{i18n "westan.charts.connect_lastfm"}}
        {{else}}
          {{i18n "westan.charts.sign_in_to_connect"}}
        {{/if}}
      </a>
    </div>
  {{else}}
    <section class="westan-charts__section">
      <h2>{{i18n "westan.charts.top_artists"}}</h2>
      <div class="westan-grid">
        {{#each @model.artists as |artist|}}
          <LinkTo
            @route="westan-charts.artist"
            @model={{artist.name}}
            class="westan-card"
          >
            <div class="westan-card__title">{{artist.name}}</div>
            <div class="westan-card__meta">{{artist.playcount}} plays</div>
          </LinkTo>
        {{/each}}
      </div>
    </section>

    <section class="westan-charts__section">
      <h2>{{i18n "westan.charts.top_albums"}}</h2>
      <div class="westan-grid">
        {{#each @model.albums as |album|}}
          <div class="westan-card">
            {{#if album.image.[2].#text}}
              <img src={{album.image.[2].#text}} alt={{album.name}} />
            {{/if}}
            <div class="westan-card__title">{{album.name}}</div>
            <div class="westan-card__meta">{{album.artist.name}} · {{album.playcount}}</div>
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
            <span class="westan-list__meta">{{track.artist.name}} · {{track.playcount}}</span>
          </li>
        {{/each}}
      </ol>
    </section>
  {{/unless}}
</div>
</template>
