import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { LinkTo } from "@ember/routing";
import { eq, or } from "truth-helpers";
import { i18n } from "discourse-i18n";

export default class AddForm extends Component {
  @service router;

  @tracked query = "";
  @tracked results = [];
  @tracked loading = false;
  @tracked errorMessage = "";
  @tracked addingId = null;

  get displayResults() {
    return this.results.map((album) => ({
      ...album,
      _westanType: this.resultType(album),
      _releaseDate: this.releaseDate(album),
    }));
  }

  @action
  updateQuery(event) {
    this.query = event.target.value;
  }

  resultType(album) {
    return album.westan_type || (album.record_type === "single" ? "single" : "album");
  }

  releaseDate(album) {
    return album.release_date || album.releaseDate || "";
  }

  @action
  async search(event) {
    event?.preventDefault();
    if (!this.query.trim()) return;
    this.loading = true;
    this.errorMessage = "";
    try {
      const res = await ajax("/westan/deezer/search-album", {
        data: { q: this.query },
      });
      this.results = res?.data || [];
    } catch (e) {
      this.errorMessage = "Não foi possível buscar no Deezer agora.";
    } finally {
      this.loading = false;
    }
  }

  @action
  async addRelease(deezerAlbum) {
    if (deezerAlbum.westan_existing) {
      this.errorMessage = "Este item já foi adicionado ao Westan Critic.";
      const route = this.resultType(deezerAlbum) === "single" ? "westan-critic.single" : "westan-critic.album";
      if (deezerAlbum.westan_existing_slug) {
        this.router.transitionTo(route, deezerAlbum.westan_existing_slug);
      }
      return;
    }

    this.addingId = deezerAlbum.id;
    this.errorMessage = "";
    try {
      const response = await ajax("/westan/critic/albums", {
        type: "POST",
        data: {
          title: deezerAlbum.title,
          artist: deezerAlbum.artist?.name,
          cover_url: deezerAlbum.cover_xl || deezerAlbum.cover_big,
          type: this.resultType(deezerAlbum),
          release_date: deezerAlbum.release_date,
        },
      });

      const album = response.album;
      const route = album.type === "single" ? "westan-critic.single-review" : "westan-critic.album-review";
      this.router.transitionTo(route, album.slug);
    } catch (e) {
      const response = e.jqXHR?.responseJSON || e.responseJSON;
      this.errorMessage = response?.error || "Não foi possível adicionar este item.";

      if (response?.album?.slug) {
        const route = response.album.type === "single" ? "westan-critic.single" : "westan-critic.album";
        this.router.transitionTo(route, response.album.slug);
      }
    } finally {
      this.addingId = null;
    }
  }

  <template>
    <div class="westan-add-form">
      <LinkTo @route="westan-critic.index" class="westan-add-form__back">‹ Westan Critic</LinkTo>
      <h1 class="westan-add-form__title">{{i18n "westan.critic.add.title"}}</h1>

      <form class="westan-add-form__search" {{on "submit" this.search}}>
        <input
          type="search"
          placeholder={{i18n "westan.critic.add.search_placeholder"}}
          value={{this.query}}
          {{on "input" this.updateQuery}}
        />
        <button type="submit" disabled={{this.loading}} aria-label="Buscar">⌕</button>
      </form>

      {{#if this.errorMessage}}
        <div class="westan-add-form__error">{{this.errorMessage}}</div>
      {{/if}}

      {{#if this.loading}}
        <div class="westan-add-form__empty">Buscando...</div>
      {{else}}
        {{#if this.displayResults.length}}
          <ul class="westan-add-form__results">
            {{#each this.displayResults as |album|}}
              <li>
                <div class="westan-add-form__cover">
                  {{#if album.cover_medium}}
                    <img src={{album.cover_medium}} alt={{album.title}} />
                  {{/if}}
                </div>
                <div class="westan-add-form__result-body">
                  <strong>{{album.title}}</strong>
                  <span>{{album.artist.name}}</span>
                  <div class="westan-add-form__meta">
                    <em>{{if (eq album._westanType "single") "Single" "Álbum"}}</em>
                    {{#if album._releaseDate}}<small>{{album._releaseDate}}</small>{{/if}}
                    {{#if album.westan_existing}}
                      <b>ⓘ Já adicionado</b>
                    {{/if}}
                  </div>
                </div>
                <button
                  type="button"
                  class="westan-add-form__add-button"
                  disabled={{or album.westan_existing (eq this.addingId album.id)}}
                  {{on "click" (fn this.addRelease album)}}
                >
                  +
                </button>
              </li>
            {{/each}}
          </ul>
        {{else}}
          <div class="westan-add-form__empty">Digite para buscar álbuns na biblioteca.</div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
