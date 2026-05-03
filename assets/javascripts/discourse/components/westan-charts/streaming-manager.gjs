import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { LinkTo } from "@ember/routing";
import { tracked } from "@glimmer/tracking";

const STORAGE_KEY = "westan_streaming_expenses_v1";
const SERVICES = [
  {
    name: "Spotify",
    monthly: "29,90",
    logo: "https://olbdvzxqkuqtouihqdyk.supabase.co/storage/v1/object/public/forum-assets/branding-charts-page/spotify.svg",
  },
  {
    name: "Apple Music",
    monthly: "21,90",
    logo: "https://olbdvzxqkuqtouihqdyk.supabase.co/storage/v1/object/public/forum-assets/branding-charts-page/applemusic.svg",
  },
  {
    name: "YouTube Music",
    monthly: "24,90",
    logo: "https://olbdvzxqkuqtouihqdyk.supabase.co/storage/v1/object/public/forum-assets/branding-charts-page/youtube.svg",
  },
  {
    name: "Deezer",
    monthly: "24,90",
    logo: "https://olbdvzxqkuqtouihqdyk.supabase.co/storage/v1/object/public/forum-assets/branding-charts-page/deezer.jpeg",
  },
  {
    name: "Tidal",
    monthly: "34,90",
    logo: "https://olbdvzxqkuqtouihqdyk.supabase.co/storage/v1/object/public/forum-assets/branding-charts-page/tidal.jpg",
  },
];

const MONTHS = ["JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"];

function parseCurrency(value) {
  return Number(String(value || "0").replace(/\./g, "").replace(",", "."));
}

function formatCurrency(value) {
  return value.toLocaleString("pt-BR", {
    style: "currency",
    currency: "BRL",
    minimumFractionDigits: 2,
  });
}

export default class WestanChartsStreamingManager extends Component {
  @tracked entries = this.readEntries();
  @tracked modalOpen = false;
  @tracked platform = SERVICES[0].name;
  @tracked monthlyValue = SERVICES[0].monthly;

  get services() {
    return SERVICES;
  }

  get months() {
    return MONTHS;
  }

  get hasEntries() {
    return this.entries.length > 0;
  }

  get cards() {
    return this.entries.map((entry) => {
      const monthly = parseCurrency(entry.monthlyValue);
      const spent = monthly * (new Date().getMonth() + 1);
      const service = SERVICES.find((item) => item.name === entry.platform) || SERVICES[0];

      return {
        ...entry,
        logo: service.logo,
        monthlyFormatted: formatCurrency(monthly),
        spentFormatted: formatCurrency(spent),
      };
    });
  }

  readEntries() {
    try {
      return JSON.parse(window.localStorage.getItem(STORAGE_KEY) || "[]");
    } catch {
      return [];
    }
  }

  persist(entries) {
    this.entries = entries;
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  @action
  openModal() {
    this.modalOpen = true;
  }

  @action
  closeModal() {
    this.modalOpen = false;
  }

  @action
  updatePlatform(event) {
    this.platform = event.target.value;
    const service = SERVICES.find((item) => item.name === this.platform);
    this.monthlyValue = service?.monthly || this.monthlyValue;
  }

  @action
  updateMonthlyValue(event) {
    this.monthlyValue = event.target.value;
  }

  @action
  save(event) {
    event.preventDefault();
    const next = [
      ...this.entries.filter((entry) => entry.platform !== this.platform),
      {
        platform: this.platform,
        monthlyValue: this.monthlyValue,
      },
    ];
    this.persist(next);
    this.modalOpen = false;
  }

  @action
  remove(event) {
    const platform = event.currentTarget.dataset.platform;
    this.persist(this.entries.filter((entry) => entry.platform !== platform));
  }

  <template>
    <nav class="westan-charts-nav">
      <LinkTo @route="westan-charts" class="westan-charts-nav__pill">Resumo</LinkTo>
      <LinkTo @route="westan-charts.recent" class="westan-charts-nav__pill">Meus charts</LinkTo>
      <LinkTo @route="westan-charts.streaming" class="westan-charts-nav__pill is-active">Meus streaming</LinkTo>
    </nav>

    {{#if this.hasEntries}}
      <header class="westan-streaming-header">
        <h1>Meus streamings</h1>
        <p>Acompanhe seu consumo ao longo do ano e descubra seus gastos com plataformas de streamings</p>
      </header>

      <section class="westan-streaming-cards">
        {{#each this.cards as |card|}}
          <article class="westan-streaming-card">
            <header>
              <img src={{card.logo}} alt="" />
              <h2>{{card.platform}}</h2>
            </header>
            <p>Dados estimados de 01/01/2026 a 31/12/2026</p>
            <div class="westan-streaming-card__actions">
              <button type="button" {{on "click" this.openModal}}>Editar</button>
              <button type="button" data-platform={{card.platform}} {{on "click" this.remove}}>Remover</button>
            </div>
            <div class="westan-streaming-months">
              {{#each this.months as |month|}}
                <span>{{month}}</span>
              {{/each}}
            </div>
            <div class="westan-streaming-card__totals">
              <div>
                <span>Você já gastou</span>
                <strong>{{card.spentFormatted}}</strong>
              </div>
              <div>
                <span>Valor mensal</span>
                <strong>{{card.monthlyFormatted}}</strong>
              </div>
            </div>
          </article>
        {{/each}}
      </section>

      <div class="westan-streaming-add-more">
        <button type="button" {{on "click" this.openModal}}>Adicione mais</button>
      </div>
    {{else}}
      <section class="westan-charts-streaming__hero">
        <h1>Adicione aqui seus gastos em streamings</h1>
        <button type="button" {{on "click" this.openModal}}>Adicionar agora</button>
      </section>
    {{/if}}

    {{#if this.modalOpen}}
      <div class="westan-streaming-modal">
        <button type="button" class="westan-streaming-modal__backdrop" {{on "click" this.closeModal}}></button>
        <form class="westan-streaming-modal__dialog" {{on "submit" this.save}}>
          <button type="button" class="westan-streaming-modal__close" {{on "click" this.closeModal}}>×</button>
          <h2>Adicionar streaming</h2>
          <p>Insira o valor mensal da sua assinatura.</p>
          <label>
            <span>Plataforma</span>
            <select value={{this.platform}} {{on "change" this.updatePlatform}}>
              {{#each this.services as |service|}}
                <option value={{service.name}}>{{service.name}}</option>
              {{/each}}
            </select>
          </label>
          <label>
            <span>Valor mensal</span>
            <input type="text" value={{this.monthlyValue}} {{on "input" this.updateMonthlyValue}} />
          </label>
          <div class="westan-streaming-modal__actions">
            <button type="button" {{on "click" this.closeModal}}>Cancelar</button>
            <button type="submit">Salvar</button>
          </div>
        </form>
      </div>
    {{/if}}
  </template>
}
