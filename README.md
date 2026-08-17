# discourse-westan

Plugin Discourse do Fórum Westan para o **Westan Critic**:

- **Westan Critic** — catálogo de álbuns/singles com reviews de usuários e imprensa
- **Side menu (hamburger)** — menu lateral com atalho para o Critic e itens customizáveis via settings

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
| `westan_critic_enabled` | habilita `/critic` |
| `westan_critic_editor_group` | grupo que pode adicionar álbuns sem cota diária (default: `staff`) |
| `westan_critic_daily_quota` | quota diária para usuários comuns (default: 10) |
| `westan_deezer_api_base` | endpoint da API de busca Deezer (público, sem key) |
| `westan_side_menu_enabled` | renderiza o menu hambúrguer |
| `westan_side_menu_items_json` | JSON `[{"id","label","path","icon","visible"}]` para itens extras |

## Rotas públicas

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

GET    /westan/deezer/search-album # proxy p/ api.deezer.com
```

## Limitações / próximos passos

O que foi portado é **o núcleo funcional** do Westan Critic. Faltam, comparado ao forum2 original:

- **Hero cards editáveis** em `/critic` (admin) — você pode usar o settings JSON ou um custom theme component.
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
  ├── westan-route-map.js         # Registra /critic
  ├── api-initializers/westan.js  # Links no sidebar nativo
  ├── routes/                     # Ember routes
  ├── templates/                  # Ember templates (hbs)
  ├── components/                 # Glimmer components (gjs)
  └── connectors/                 # Plugin outlets (hamburger)
assets/stylesheets/westan/        # SCSS
```
