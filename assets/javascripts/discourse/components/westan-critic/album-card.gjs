import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";

export default class AlbumCard extends Component {
  get routeName() {
    return this.args.album?.type === "single"
      ? "westan-critic.single"
      : "westan-critic.album";
  }

  <template>
    <LinkTo @route={{this.routeName}} @model={{@album.slug}} class="westan-card westan-album-card">
      {{#if @album.cover_url}}
        <img src={{@album.cover_url}} alt={{@album.title}} />
      {{/if}}
      <div class="westan-card__title">{{@album.title}}</div>
      <div class="westan-card__meta">{{@album.artist}}</div>
      {{#if @album.avg_user_score}}
        <div class="westan-score westan-score--user">{{@album.avg_user_score}}</div>
      {{/if}}
      {{#if @album.avg_critic_score}}
        <div class="westan-score westan-score--critic">{{@album.avg_critic_score}}</div>
      {{/if}}
    </LinkTo>
  </template>
}
