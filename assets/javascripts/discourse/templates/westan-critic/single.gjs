import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";
import ScoreMeter from "../../components/westan-critic/score-meter";
import AlbumActions from "../../components/westan-critic/album-actions";
import ReviewList from "../../components/westan-critic/review-list";

<template>
<article class="westan-album-page">
  <LinkTo @route="westan-critic.index" class="westan-album-page__back">‹ Voltar</LinkTo>

  <header class="westan-album-page__hero">
    <div class="westan-album-page__cover-wrap">
      {{#if @model.album.cover_url}}
        <img src={{@model.album.cover_url}} alt={{@model.album.title}} class="westan-album-page__cover" />
      {{else}}
        <span>{{@model.album.title}}</span>
      {{/if}}
    </div>

    <div class="westan-album-page__meta">
      <h1 class="westan-title">{{@model.album.title}}</h1>
      <p class="westan-album-page__artist">{{@model.album.artist}}</p>
      <div class="westan-album-page__scores">
        <ScoreMeter
          @label="Usuários"
          @score={{@model.album.avg_user_score}}
          @count={{@model.album.user_review_count}}
        />
        <ScoreMeter
          @label="Críticos"
          @score={{@model.album.avg_critic_score}}
          @count={{@model.album.critic_review_count}}
        />
      </div>
      <AlbumActions
        @album={{@model.album}}
        @userReviews={{@model.userReviews}}
      />
    </div>
  </header>

  <section class="westan-album-page__reviews">
    <ReviewList
      @title="Avaliações"
      @reviews={{@model.userReviews}}
      @emptyText={{i18n "westan.critic.album.no_reviews"}}
    />
  </section>
</article>
</template>
