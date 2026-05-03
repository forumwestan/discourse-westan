import { i18n } from "discourse-i18n";
import { LinkTo } from "@ember/routing";
import LastfmConnectForm from "../../components/westan-charts/lastfm-connect-form";

<template>
<div class="westan-charts westan-charts-connect-page">
  <LinkTo @route="westan-charts" class="westan-charts-connect-page__back">
    ‹ {{i18n "westan.charts.title"}}
  </LinkTo>

  <header class="westan-charts__header">
    <h1 class="westan-title">{{i18n "westan.charts.connect_lastfm"}}</h1>
    <p>{{i18n "westan.charts.connect_lastfm_description"}}</p>
  </header>

  <LastfmConnectForm @username={{@model.username}} @token={{@model.token}} />
</div>
</template>
