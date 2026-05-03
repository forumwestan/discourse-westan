import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";

function imageFor(item, preferredIndex = 2) {
  const images = item?.image || [];
  const preferred = images[preferredIndex]?.["#text"];
  const fallback = [...images].reverse().find((image) => image?.["#text"])?.["#text"];
  return preferred || fallback || "";
}

function formatDate(date) {
  return date.toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}

export default class WestanChartsRankingList extends Component {
  get rows() {
    return (this.args.items || []).slice(0, 20).map((item, index) => ({
      index: index + 1,
      name: item.name,
      image: imageFor(item),
      streams: Number(item.playcount || 0).toLocaleString("pt-BR"),
      movement: index === 2 ? "↑ 5" : index === 3 ? "↑ 11" : "−",
      movementClass: index === 2 || index === 3 ? "is-positive" : "",
      isNewPeak: index === 2,
      peak: index + 1,
      weeks: Math.max(1, 8 - index),
    }));
  }

  get periodLabel() {
    const end = new Date();
    const start = new Date();
    start.setDate(end.getDate() - 6);
    return `Período ${formatDate(start)} a ${formatDate(end)}`;
  }

  get hasRows() {
    return this.rows.length > 0;
  }

  <template>
    <nav class="westan-charts-nav">
      <LinkTo @route="westan-charts" class="westan-charts-nav__pill">Resumo</LinkTo>
      <LinkTo @route="westan-charts.recent" class="westan-charts-nav__pill is-active">Meus charts</LinkTo>
      <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill">Meus streaming</LinkTo>
    </nav>

    <div class="westan-charts-chart-toolbar">
      <div class="westan-charts-periods">
        <span class="is-active">Semanal</span>
        <span>Mensal</span>
      </div>

      <div class="westan-charts-actions">
        <button type="button" aria-label="Filtros">⌘</button>
        <button type="button" aria-label="Baixar">↓</button>
      </div>
    </div>

    <header class="westan-charts-chart-header">
      <h1>Artistas - Semanal</h1>
      <p>{{this.periodLabel}}</p>
    </header>

    {{#if this.hasRows}}
      <section class="westan-charts-board">
        {{#each this.rows as |row|}}
          <article class="westan-charts-board-row">
            <b>{{row.index}}</b>
            {{#if row.image}}
              <img src={{row.image}} alt="" />
            {{else}}
              <span class="westan-charts-board-row__placeholder"></span>
            {{/if}}
            <div class="westan-charts-board-row__main">
              <strong>{{row.name}}</strong>
              <span>Artist</span>
              <div>
                {{#if row.isNewPeak}}
                  <em class="is-peak">New peak</em>
                {{/if}}
                <em>Peak {{row.peak}}</em>
                <em>Weeks {{row.weeks}}</em>
                <em>Streams {{row.streams}}</em>
              </div>
            </div>
            <small class={{row.movementClass}}>{{row.movement}}</small>
          </article>
        {{/each}}
      </section>
    {{else}}
      <div class="westan-empty westan-charts-connect">
        <p>Nenhum dado de chart disponível ainda.</p>
      </div>
    {{/if}}
  </template>
}
