import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";
import AlbumCard from "../../components/westan-critic/album-card";

<template>
<section class="westan-critic-hero">
  <div class="westan-critic-hero__copy">
    <h1>Adicione as avaliações de críticos especialistas</h1>
    <LinkTo @route="westan-critic.recent" class="westan-critic-hero__cta">
      Como funciona →
    </LinkTo>
  </div>
  <div class="westan-critic-hero__art" aria-hidden="true">
    <span>♪</span>
  </div>
</section>

<div class="westan-critic-hero__dots" aria-hidden="true">
  <span></span>
  <strong></strong>
</div>

{{#if this.currentUser}}
  <div class="westan-critic__actions">
    <LinkTo @route="westan-critic.add" class="westan-critic__add-button">
      Adicionar
    </LinkTo>
  </div>
{{/if}}

{{#if @model.upcoming}}
  <section class="westan-critic__section westan-critic__section--feature">
    <h2>Lançamento aguardado</h2>
    <div class="westan-grid westan-grid--critic">
      <AlbumCard @album={{@model.upcoming}} />
    </div>
  </section>
{{/if}}

<section class="westan-critic__section">
  <div class="westan-critic__section-header">
    <h2>Novos lançamentos</h2>
    <LinkTo @route="westan-critic.recent">→ Ver tudo</LinkTo>
  </div>
  {{#if @model.thisWeek.length}}
    <div class="westan-grid westan-grid--critic">
      {{#each @model.thisWeek as |album|}}
        <AlbumCard @album={{album}} />
      {{/each}}
    </div>
  {{else}}
    <div class="westan-empty">Nenhum item ainda.</div>
  {{/if}}
</section>

<section class="westan-critic__section">
  <div class="westan-critic__section-header">
    <h2>Álbuns adicionados recentemente</h2>
    <LinkTo @route="westan-critic.recent">→ Ver tudo</LinkTo>
  </div>
  <div class="westan-grid westan-grid--critic">
    {{#each @model.recentAlbums as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>

<section class="westan-critic__section">
  <div class="westan-critic__section-header">
    <h2>Faixas adicionadas recentemente</h2>
    <LinkTo @route="westan-critic.recent">→ Ver tudo</LinkTo>
  </div>
  <div class="westan-grid westan-grid--critic">
    {{#each @model.recentSingles as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>
</template>
