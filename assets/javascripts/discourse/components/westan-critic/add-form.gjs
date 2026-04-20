import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";

export default class AddForm extends Component {
  @tracked query = "";
  @tracked results = [];
  @tracked loading = false;
  @tracked type = "album";

  @action
  updateQuery(event) {
    this.query = event.target.value;
  }

  @action
  async search() {
    if (!this.query.trim()) return;
    this.loading = true;
    try {
      const res = await ajax("/westan/deezer/search-album", {
        data: { q: this.query },
      });
      this.results = res?.data || [];
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loading = false;
    }
  }

  @action
  async addRelease(deezerAlbum) {
    try {
      await ajax("/westan/critic/albums", {
        type: "POST",
        data: {
          title: deezerAlbum.title,
          artist: deezerAlbum.artist?.name,
          cover_url: deezerAlbum.cover_xl || deezerAlbum.cover_big,
          type: this.type,
          release_date: deezerAlbum.release_date,
        },
      });
      this.args.onAdded?.();
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    <div class="westan-add-form">
      <div class="westan-add-form__controls">
        <select value={{this.type}} {{on "change" (fn (mut this.type) (get "target.value"))}}>
          <option value="album">Album</option>
          <option value="single">Single</option>
        </select>
        <input
          type="search"
          placeholder={{i18n "westan.critic.add.search_placeholder"}}
          value={{this.query}}
          {{on "input" this.updateQuery}}
        />
        <DButton @action={{this.search}} @disabled={{this.loading}} @label="search.searching" />
      </div>
      <ul class="westan-add-form__results">
        {{#each this.results as |album|}}
          <li>
            {{#if album.cover_medium}}
              <img src={{album.cover_medium}} alt={{album.title}} />
            {{/if}}
            <div>
              <strong>{{album.title}}</strong>
              <div>{{album.artist.name}}</div>
            </div>
            <DButton @action={{fn this.addRelease album}} @icon="plus" />
          </li>
        {{/each}}
      </ul>
    </div>
  </template>
}
