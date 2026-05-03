import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import ScoreMeter from "./score-meter";

export default class AlbumCard extends Component {
  get routeName() {
    return this.args.album?.type === "single"
      ? "westan-critic.single"
      : "westan-critic.album";
  }

  <template>
    <LinkTo @route={{this.routeName}} @model={{@album.slug}} class="westan-card westan-album-card">
      <div class="westan-album-card__cover">
        {{#if @album.cover_url}}
          <img src={{@album.cover_url}} alt={{@album.title}} />
        {{else}}
          <span>{{@album.title}}</span>
        {{/if}}
      </div>
      <div class="westan-card__title">{{@album.title}}</div>
      <div class="westan-card__meta">{{@album.artist}}</div>
      <ScoreMeter @label="usuários" @score={{@album.avg_user_score}} @compact={{true}} />
      <ScoreMeter @label="crítica" @score={{@album.avg_critic_score}} @compact={{true}} />
    </LinkTo>
  </template>
}
