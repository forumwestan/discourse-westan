import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { LinkTo } from "@ember/routing";
import { tracked } from "@glimmer/tracking";

const MENU = [
  { key: "artists", label: "Artistas", icon: "◎", singular: "Artist" },
  { key: "albums", label: "Álbuns", icon: "◉", singular: "Album" },
  { key: "tracks", label: "Faixas", icon: "♫", singular: "Track" },
];

function imageFor(item, preferredIndex = 2) {
  const images = item?.image || [];
  const preferred = images[preferredIndex]?.["#text"];
  const fallback = [...images].reverse().find((image) => image?.["#text"])?.["#text"];
  return preferred || fallback || "";
}

function artistName(item) {
  return item?.artist?.name || item?.artist?.["#text"] || item?.artist || "";
}

function keyFor(item, kind) {
  const artist = artistName(item);
  return [kind, item?.name, artist].filter(Boolean).join("::").toLowerCase();
}

function formatDate(date) {
  return date.toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}

export default class WestanChartsRankingList extends Component {
  @tracked period = "weekly";
  @tracked kind = "artists";
  @tracked expandedKey = null;
  @tracked menuOpen = false;
  @tracked settingsOpen = false;
  @tracked hiddenByKind = this.readHiddenSettings();

  get menuItems() {
    return MENU;
  }

  get activeMenu() {
    return MENU.find((item) => item.key === this.kind) || MENU[0];
  }

  get periodLabel() {
    return this.period === "weekly" ? "Semanal" : "Mensal";
  }

  get currentItems() {
    return this.args.charts?.[this.period]?.[this.kind] || [];
  }

  get hiddenKeys() {
    return this.hiddenByKind[this.kind] || [];
  }

  get hiddenItems() {
    return this.currentItems
      .filter((item) => this.hiddenKeys.includes(keyFor(item, this.kind)))
      .map((item) => ({
        key: keyFor(item, this.kind),
        name: item.name,
      }));
  }

  get rows() {
    return this.currentItems
      .filter((item) => !this.hiddenKeys.includes(keyFor(item, this.kind)))
      .slice(0, 20)
      .map((item, index) => {
        const previousRank = index === 0 ? 2 : index + 1;
        const movement = index === 0 ? "↑ 1" : index === 2 ? "↑ 5" : "−";

        return {
          index: index + 1,
          key: keyFor(item, this.kind),
          name: item.name,
          subtitle: this.kind === "artists" ? this.activeMenu.singular : artistName(item),
          image: imageFor(item),
          streams: Number(item.playcount || 0).toLocaleString("pt-BR"),
          movement,
          movementClass: movement.startsWith("↑") ? "is-positive" : "",
          isNewPeak: index === 0,
          peak: index + 1,
          weeks: Math.max(1, 8 - index),
          firstEntry: this.period === "weekly" ? formatDate(new Date()) : formatDate(this.periodStart),
          previousRank,
          expanded: this.expandedKey === keyFor(item, this.kind),
          artistHref: this.kind === "artists" ? `/charts/artist/${encodeURIComponent(item.name)}` : "#",
        };
      });
  }

  get weeklyPeriodClass() {
    return this.period === "weekly" ? "is-active" : "";
  }

  get monthlyPeriodClass() {
    return this.period === "monthly" ? "is-active" : "";
  }

  get periodStart() {
    const start = new Date();
    start.setDate(start.getDate() - (this.period === "weekly" ? 6 : 29));
    return start;
  }

  get periodText() {
    return `Período ${formatDate(this.periodStart)} a ${formatDate(new Date())}`;
  }

  get title() {
    return `${this.activeMenu.label} - ${this.periodLabel}`;
  }

  get hasRows() {
    return this.rows.length > 0;
  }

  readHiddenSettings() {
    try {
      return JSON.parse(window.localStorage.getItem("westan_charts_hidden_items") || "{}");
    } catch {
      return {};
    }
  }

  persistHiddenSettings(nextSettings) {
    this.hiddenByKind = nextSettings;
    window.localStorage.setItem("westan_charts_hidden_items", JSON.stringify(nextSettings));
  }

  @action
  toggleMenu() {
    this.menuOpen = !this.menuOpen;
  }

  @action
  selectKind(event) {
    this.kind = event.currentTarget.dataset.kind;
    this.expandedKey = null;
    this.menuOpen = false;
  }

  @action
  selectPeriod(event) {
    this.period = event.currentTarget.dataset.period;
    this.expandedKey = null;
  }

  @action
  toggleExpanded(event) {
    const key = event.currentTarget.dataset.key;
    this.expandedKey = this.expandedKey === key ? null : key;
  }

  @action
  toggleSettings() {
    this.settingsOpen = !this.settingsOpen;
  }

  @action
  hideItem(event) {
    const key = event.currentTarget.dataset.key;
    const next = { ...this.hiddenByKind };
    next[this.kind] = [...new Set([...(next[this.kind] || []), key])];
    this.persistHiddenSettings(next);
  }

  @action
  restoreItem(event) {
    const key = event.currentTarget.dataset.key;
    const next = { ...this.hiddenByKind };
    next[this.kind] = (next[this.kind] || []).filter((itemKey) => itemKey !== key);
    this.persistHiddenSettings(next);
  }

  <template>
    <nav class="westan-charts-nav">
      <LinkTo @route="westan-charts" class="westan-charts-nav__pill">Resumo</LinkTo>
      <div class="westan-charts-menu">
        <button
          type="button"
          class="westan-charts-nav__pill is-active"
          {{on "click" this.toggleMenu}}
        >
          Meus charts <span>{{if this.menuOpen "⌃" "⌄"}}</span>
        </button>
        {{#if this.menuOpen}}
          <div class="westan-charts-menu__popover">
            {{#each this.menuItems as |item|}}
              <button
                type="button"
                class="westan-charts-menu__item"
                data-kind={{item.key}}
                {{on "click" this.selectKind}}
              >
                <span>{{item.icon}}</span>
                {{item.label}}
              </button>
            {{/each}}
          </div>
        {{/if}}
      </div>
      <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill">Meus streaming</LinkTo>
    </nav>

    <div class="westan-charts-chart-toolbar">
      <div class="westan-charts-periods">
        <button
          type="button"
          class={{this.weeklyPeriodClass}}
          data-period="weekly"
          {{on "click" this.selectPeriod}}
        >
          Semanal
        </button>
        <button
          type="button"
          class={{this.monthlyPeriodClass}}
          data-period="monthly"
          {{on "click" this.selectPeriod}}
        >
          Mensal
        </button>
      </div>

      <div class="westan-charts-actions">
        <button type="button" aria-label="Configurar chart" {{on "click" this.toggleSettings}}>☷</button>
        <button type="button" aria-label="Baixar">↓</button>
      </div>

      {{#if this.settingsOpen}}
        <aside class="westan-charts-settings">
          <h2>Configurar chart</h2>
          <p>Ajuste filtros e remova itens do ranking.</p>
          <div class="westan-charts-settings__box">
            <strong>Remover {{this.activeMenu.label}}</strong>
            {{#each this.rows as |row|}}
              <div class="westan-charts-settings__row">
                <div>
                  <span>{{row.name}}</span>
                  <small>{{row.subtitle}}</small>
                </div>
                <button type="button" data-key={{row.key}} {{on "click" this.hideItem}}>Remover</button>
              </div>
            {{/each}}
          </div>
          {{#if this.hiddenItems.length}}
            <div class="westan-charts-settings__restore">
              <strong>Itens removidos</strong>
              {{#each this.hiddenItems as |item|}}
                <button type="button" data-key={{item.key}} {{on "click" this.restoreItem}}>
                  Restaurar {{item.name}}
                </button>
              {{/each}}
            </div>
          {{/if}}
        </aside>
      {{/if}}
    </div>

    <header class="westan-charts-chart-header">
      <h1>{{this.title}}</h1>
      <p>{{this.periodText}}</p>
    </header>

    {{#if this.hasRows}}
      <section class="westan-charts-board">
        {{#each this.rows as |row|}}
          <article class="westan-charts-board-item">
            <button
              type="button"
              class="westan-charts-board-row"
              data-key={{row.key}}
              {{on "click" this.toggleExpanded}}
            >
              <b>{{row.index}}</b>
              {{#if row.image}}
                <img src={{row.image}} alt="" />
              {{else}}
                <span class="westan-charts-board-row__placeholder"></span>
              {{/if}}
              <span class="westan-charts-board-row__main">
                <strong>{{row.name}}</strong>
                <span>{{row.subtitle}}</span>
                <span class="westan-charts-board-row__badges">
                  {{#if row.isNewPeak}}
                    <em class="is-peak">New peak</em>
                  {{/if}}
                  <em>Peak {{row.peak}}</em>
                  <em>Weeks {{row.weeks}}</em>
                  <em>Streams {{row.streams}}</em>
                </span>
              </span>
              <small class={{row.movementClass}}>{{row.movement}}</small>
              <i>{{if row.expanded "⌃" "⌄"}}</i>
            </button>
            {{#if row.expanded}}
              <div class="westan-charts-board-details">
                <div>
                  <span>Semanas no chart</span>
                  <strong>{{row.weeks}}</strong>
                </div>
                <div>
                  <span>Primeira entrada</span>
                  <strong>{{row.firstEntry}}</strong>
                </div>
                <div>
                  <span>Posição anterior</span>
                  <strong>#{{row.previousRank}}</strong>
                </div>
                <a href={{row.artistHref}}>Ir para a página do artista ›</a>
              </div>
            {{/if}}
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
