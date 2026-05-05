import { LinkTo } from "@ember/routing";

<template>
  <div class="westan-charts westan-charts-artist-page">
    <nav class="westan-charts-nav">
      <LinkTo @route="westan-charts" class="westan-charts-nav__pill">Resumo</LinkTo>
      <LinkTo @route="westan-charts.recent" class="westan-charts-nav__pill">Meus charts</LinkTo>
      <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill">Meus streaming</LinkTo>
    </nav>

    <section class="westan-charts-artist-hero" style={{@model.heroStyle}}>
      <div class="westan-charts-artist-hero__main">
        <span>Artista</span>
        <h1>{{@model.artistName}}</h1>
        <p>{{@model.listeners}} ouvintes</p>
      </div>

      {{#if @model.heroAlbum}}
        <aside class="westan-charts-artist-hero__card">
          <span>Lançamento popular</span>
          <div>
            {{#if @model.heroAlbum.image}}
              <img src={{@model.heroAlbum.image}} alt="" />
            {{else}}
              <span class="westan-charts-artwork-placeholder"></span>
            {{/if}}
            <div>
              <strong>{{@model.heroAlbum.title}}</strong>
              <p>{{@model.heroAlbum.artist}}</p>
              <em>{{@model.heroAlbum.plays}} plays</em>
            </div>
          </div>
        </aside>
      {{/if}}
    </section>

    <section class="westan-charts-artist-rankings">
      <div>
        <h2>Top Álbuns</h2>
        <div class="westan-charts-rankings__toggle">
          <span>Meus dados</span>
          <span>Geral</span>
        </div>
        {{#each @model.albums as |album|}}
          <div class="westan-charts-ranking-row">
            <b>{{album.index}}</b>
            {{#if album.image}}
              <img src={{album.image}} alt="" />
            {{else}}
              <span class="westan-charts-artwork-placeholder"></span>
            {{/if}}
            <div>
              <strong>{{album.name}}</strong>
              <span>{{@model.artistName}}</span>
              <em>{{album.plays}} plays</em>
            </div>
          </div>
        {{/each}}
      </div>

      <div>
        <h2>Top Músicas</h2>
        <div class="westan-charts-rankings__toggle">
          <span>Meus dados</span>
          <span>Geral</span>
        </div>
        {{#each @model.tracks as |track|}}
          <div class="westan-charts-ranking-row">
            <b>{{track.index}}</b>
            {{#if track.image}}
              <img src={{track.image}} alt="" />
            {{else}}
              <span class="westan-charts-artwork-placeholder"></span>
            {{/if}}
            <div>
              <strong>{{track.name}}</strong>
              <span>{{track.artist}}</span>
              <em>{{track.plays}} plays</em>
            </div>
          </div>
        {{/each}}
      </div>
    </section>
  </div>
</template>
