import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";
export default class AddForm extends Component {
  @tracked query = "";
  @tracked results = [];
  @tracked loading = false;
  @tracked type = "album";

  @action
  updateType(event) {
    this.type = event.target.value;
  }

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
        <select {{on "change" this.updateType}}>
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
