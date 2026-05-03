import { LinkTo } from "@ember/routing";

<template>
<div class="westan-charts westan-charts-streaming">
  <nav class="westan-charts-nav">
    <LinkTo @route="westan-charts" class="westan-charts-nav__pill">Resumo</LinkTo>
    <LinkTo @route="westan-charts.recent" class="westan-charts-nav__pill">Meus charts</LinkTo>
    <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill is-active">Meus streaming</LinkTo>
  </nav>

  <section class="westan-charts-streaming__hero">
    <h1>Adicione aqui seus gastos em streamings</h1>
    <button type="button">Adicionar agora</button>
  </section>
</div>
</template>
