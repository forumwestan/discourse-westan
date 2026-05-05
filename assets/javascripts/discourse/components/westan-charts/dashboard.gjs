import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import { LinkTo } from "@ember/routing";

function imageFor(item, preferredIndex = 3) {
  const images = item?.image || [];
  const preferred = images[preferredIndex]?.["#text"];
  const fallback = [...images].reverse().find((image) => image?.["#text"])?.["#text"];
  return preferred || fallback || "";
}

function artistName(item) {
  return item?.artist?.name || item?.artist?.["#text"] || item?.artist || "";
}

export default class WestanChartsDashboard extends Component {
  get artists() {
    return this.args.artists || [];
  }

  get albums() {
    return this.args.albums || [];
  }

  get tracks() {
    return this.args.tracks || [];
  }

  get recentTracks() {
    return this.args.recentTracks || [];
  }

  get topArtist() {
    return this.artists[0] || {};
  }

  get topAlbum() {
    return this.albums[0] || {};
  }

  get topTrack() {
    return this.tracks[0] || {};
  }

  get heroImage() {
    return imageFor(this.topArtist) || imageFor(this.topAlbum) || imageFor(this.topTrack);
  }

  get heroStyle() {
    if (!this.heroImage) {
      return htmlSafe("");
    }

    return htmlSafe(`background-image: linear-gradient(90deg, rgba(6, 16, 40, 0.86), rgba(6, 16, 40, 0.24)), url("${this.heroImage}")`);
  }

  get topArtistPlays() {
    return Number(this.topArtist.playcount || 0).toLocaleString("pt-BR");
  }

  get topArtistName() {
    return this.topArtist.name || "Seu artista";
  }

  get albumFeatureImage() {
    return imageFor(this.topAlbum, 2);
  }

  get topAlbumTitle() {
    return this.topAlbum.name || "Sem álbum";
  }

  get topAlbumArtist() {
    return artistName(this.topAlbum) || "Last.fm";
  }

  get topTrackArtist() {
    return artistName(this.topTrack) || "Last.fm";
  }

  get topTrackTitle() {
    return this.topTrack.name || "Sem música";
  }

  get trackFeatureImage() {
    return imageFor(this.topTrack, 2) || imageFor(this.topTrack, 1) || this.albumFeatureImage;
  }

  get recentRows() {
    return this.recentTracks.slice(0, 3).map((track) => ({
      title: track.name,
      artist: artistName(track),
      image: imageFor(track, 1),
    }));
  }

  get hasRecentRows() {
    return this.recentRows.length > 0;
  }

  <template>
    <nav class="westan-charts-nav">
      <LinkTo @route="westan-charts" class="westan-charts-nav__pill is-active">Resumo</LinkTo>
      <LinkTo @route="westan-charts.recent" class="westan-charts-nav__pill">Meus charts</LinkTo>
      <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill">Meus streaming</LinkTo>
    </nav>

    <section class="westan-charts-summary">
      <div class="westan-charts-summary__hero" style={{this.heroStyle}}>
        <div>
          <span>Artista da semana</span>
          <h1>{{this.topArtistName}}</h1>
          <p>{{this.topArtistPlays}} streams</p>
        </div>
      </div>

      <div class="westan-charts-summary__features">
        <div class="westan-charts-feature">
          {{#if this.albumFeatureImage}}
            <img src={{this.albumFeatureImage}} alt="" />
          {{else}}
            <span class="westan-charts-feature__placeholder"></span>
          {{/if}}
          <div>
            <span>Álbum da semana</span>
            <strong>{{this.topAlbumTitle}}</strong>
            <p>{{this.topAlbumArtist}}</p>
            <LinkTo @route="westan-charts.recent" class="westan-charts-feature__link">Ver ranking completo ›</LinkTo>
          </div>
        </div>

        <div class="westan-charts-feature">
          {{#if this.trackFeatureImage}}
            <img src={{this.trackFeatureImage}} alt="" />
          {{else}}
            <span class="westan-charts-feature__placeholder"></span>
          {{/if}}
          <div>
            <span>Música da semana</span>
            <strong>{{this.topTrackTitle}}</strong>
            <p>{{this.topTrackArtist}}</p>
            <LinkTo @route="westan-charts.recent" class="westan-charts-feature__link">Ver ranking completo ›</LinkTo>
          </div>
        </div>
      </div>
    </section>

    <section class="westan-charts-panels">
      <div class="westan-charts-now">
        <div class="westan-charts-panel-title">
          <h2>O que eu estou ouvindo</h2>
          <LinkTo @route="westan-charts.recent">Ver mais</LinkTo>
        </div>

        {{#if this.hasRecentRows}}
          {{#each this.recentRows as |track|}}
            <div class="westan-charts-now__row">
              {{#if track.image}}
                <img src={{track.image}} alt="" />
              {{/if}}
              <div>
                <strong>{{track.title}}</strong>
                <span>{{track.artist}}</span>
              </div>
            </div>
          {{/each}}
        {{else}}
          <div class="westan-charts-now__empty">Nenhuma música recente.</div>
        {{/if}}
      </div>

      <div class="westan-charts-spending">
        <h2>Meus gastos mensais</h2>
        <p>Adicione suas plataformas para acompanhar quanto você já gastou com streaming ao longo do ano.</p>
        <button type="button">Inserir gastos</button>
      </div>
    </section>
  </template>
}
