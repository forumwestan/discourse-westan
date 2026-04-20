# discourse-westan

Plugin Discourse que porta três features do app React **forum2** para o Discourse:

- **Westan Charts** — integração Last.fm (top artists/albums/tracks, recent, artist detail)
- **Westan Critic** — catálogo de álbuns/singles com reviews de usuários e imprensa
- **Side menu (hamburger)** — menu lateral com atalhos rápidos, widgets de Charts/Critic e itens customizáveis via settings

Tópicos, notificações, perfil, mensagens e moderação continuam 100% padrão do Discourse — o plugin não mexe nessas áreas.

---

## Instalação

1. Coloque este diretório em `plugins/discourse-westan` dentro do seu Discourse.
2. `./launcher rebuild app` (ou reinicie o container dev).
3. As migrações criam `westan_critic_albums` e `westan_critic_reviews`.

## Configuração

Em **Admin → Settings → Plugins**:

| Setting | Descrição |
|---|---|
| `westan_enabled` | liga/desliga tudo |
| `westan_charts_enabled` | habilita `/charts` |
| `westan_lastfm_api_key` | **obrigatório** para Charts — <https://www.last.fm/api/account/create> |
| `westan_critic_enabled` | habilita `/critic` |
| `westan_critic_editor_group` | grupo que pode adicionar álbuns sem cota diária (default: `staff`) |
| `westan_critic_daily_quota` | quota diária para usuários comuns (default: 10) |
| `westan_deezer_api_base` | endpoint da API de busca Deezer (público, sem key) |
| `westan_side_menu_enabled` | renderiza o menu hambúrguer |
| `westan_side_menu_items_json` | JSON `[{"id","label","path","icon","visible"}]` para itens extras |

### Last.fm por usuário

O plugin usa o campo custom `lastfm_username` do usuário para buscar charts. Pra popular:

```ruby
user.custom_fields["lastfm_username"] = "seunick"
user.save_custom_fields
```

Você pode expor esse campo via `discourse-profile-field` ou adicioná-lo como user custom field em Admin → Users → Custom Fields.

## Rotas públicas

- `/charts`, `/charts/recent`, `/charts/artist/:name`
- `/critic`, `/critic/releases`, `/critic/recent`
- `/critic/album/:slug`, `/critic/single/:slug`
- `/critic/my-reviews` (logado)
- `/critic/album/:slug/review`, `/critic/single/:slug/review` (logado)
- `/critic/add` (logado, com cota)

## Endpoints internos

```
GET    /westan/critic/albums
GET    /westan/critic/albums/:slug
POST   /westan/critic/albums
PATCH  /westan/critic/albums/:id
DELETE /westan/critic/albums/:id

GET    /westan/critic/reviews
POST   /westan/critic/reviews
PATCH  /westan/critic/reviews/:id
DELETE /westan/critic/reviews/:id

GET    /westan/lastfm/:method      # proxy p/ ws.audioscrobbler.com (whitelist)
GET    /westan/deezer/search-album # proxy p/ api.deezer.com
```

## Limitações / próximos passos

O que foi portado é **o núcleo funcional** das features. Faltam, comparado ao forum2 original:

- **Story export** (download de imagem gerada em canvas) — veja `src/lib/chartStoryExport.ts` no forum2.
- **Hero cards editáveis** em `/critic` (admin) — você pode usar o settings JSON ou um custom theme component.
- **Streaming expenses** do Charts — era localStorage-only, pode ser portado como user custom field.
- **Votos (like/dislike)** em reviews — no forum2 são locais; se quiser persistir, adicione tabela `westan_critic_review_votes`.
- **Avatares rich** nas review items — atualmente usa avatar_template do Discourse (já ok).
- **Skin visual** — os SCSS aqui são funcionais mas não replicam pixel-a-pixel o forum2. Combine com o tema [Tema-Westan](../Tema-Westan) para a identidade visual.

## Estrutura

```
plugin.rb                          # carrega tudo
lib/westan/engine.rb              # Rails Engine
config/settings.yml               # Admin settings
config/locales/client.en.yml      # I18n
db/migrate/                       # Schema
app/models/westan/                # ActiveRecord models
app/controllers/westan/           # JSON APIs
app/serializers/westan/           # JSON shapes
assets/javascripts/discourse/
  ├── westan-route-map.js         # Registra /charts e /critic
  ├── api-initializers/westan.js  # Links no sidebar nativo
  ├── routes/                     # Ember routes
  ├── templates/                  # Ember templates (hbs)
  ├── components/                 # Glimmer components (gjs)
  └── connectors/                 # Plugin outlets (hamburger)
assets/stylesheets/westan/        # SCSS
```
