import { i18n } from "discourse-i18n";
import AlbumCard from "../../components/westan-critic/album-card";

<template>
<section class="westan-critic__section">
  <h1 class="westan-title">{{i18n "westan.critic.nav.releases"}}</h1>
  <div class="westan-grid">
    {{#each @model.albums as |album|}}
      <AlbumCard @album={{album}} />
    {{/each}}
  </div>
</section>
</template>
