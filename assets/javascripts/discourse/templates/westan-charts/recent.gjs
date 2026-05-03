import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";
import RankingList from "../../components/westan-charts/ranking-list";

<template>
<div class="westan-charts">
  {{#unless @model.hasLastfm}}
    <header class="westan-charts__header">
      <h1 class="westan-title">{{i18n "westan.charts.recent_tracks"}}</h1>
    </header>

    <div class="westan-empty westan-charts-connect">
      <p>{{i18n "westan.charts.no_lastfm"}}</p>
      {{#if @model.isLoggedIn}}
        <LinkTo @route="westan-charts.connect" class="westan-charts-connect__button">
          {{i18n "westan.charts.connect_lastfm"}}
        </LinkTo>
      {{else}}
        <a href="/login" class="westan-charts-connect__button">
          {{i18n "westan.charts.sign_in_to_connect"}}
        </a>
      {{/if}}
    </div>
  {{else}}
    {{#if @model.lastfmError}}
      <div class="westan-empty westan-charts-connect">
        <p>{{i18n "westan.charts.lastfm_error"}}</p>
        <LinkTo @route="westan-charts.connect" class="westan-charts-connect__button">
          {{i18n "westan.charts.edit_lastfm"}}
        </LinkTo>
      </div>
    {{/if}}

    <RankingList @charts={{@model.charts}} />
  {{/unless}}
</div>
</template>
