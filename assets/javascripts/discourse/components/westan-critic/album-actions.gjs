import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { LinkTo } from "@ember/routing";
import { on } from "@ember/modifier";

export default class AlbumActions extends Component {
  @service currentUser;
  @service router;

  @tracked favorited = Boolean(this.args.album.favorited_by_current_user);
  @tracked exporting = false;

  get reviewRoute() {
    return this.args.album.type === "single"
      ? "westan-critic.single-review"
      : "westan-critic.album-review";
  }

  get reviewLabel() {
    return this.args.album.type === "single" ? "☆ Avaliar single" : "☆ Avaliar álbum";
  }

  get userReview() {
    if (!this.currentUser) {
      return null;
    }

    return (this.args.userReviews || []).find(
      (review) => review.user_id === this.currentUser.id
    );
  }

  @action
  async toggleFavorite() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }

    try {
      const result = await ajax(`/westan/critic/albums/${this.args.album.id}/favorite`, {
        type: "POST",
      });
      this.favorited = result.favorited;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async downloadReviewImage() {
    if (!this.userReview || this.exporting) {
      return;
    }

    this.exporting = true;

    try {
      const canvas = document.createElement("canvas");
      canvas.width = 1080;
      canvas.height = 1920;
      const ctx = canvas.getContext("2d");
      const album = this.args.album;
      const review = this.userReview;

      ctx.fillStyle = "#0b0f19";
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
      gradient.addColorStop(0, "#9333ea");
      gradient.addColorStop(0.52, "#ec4899");
      gradient.addColorStop(1, "#22c55e");
      ctx.globalAlpha = 0.28;
      ctx.fillStyle = gradient;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.globalAlpha = 1;

      await this.drawCover(ctx, album.cover_url);

      ctx.fillStyle = "#ffffff";
      ctx.font = "900 74px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
      this.wrapText(ctx, album.title, 90, 1060, 900, 82, 3);

      ctx.fillStyle = "rgba(255,255,255,0.72)";
      ctx.font = "700 42px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
      this.wrapText(ctx, album.artist, 90, 1275, 900, 50, 2);

      ctx.fillStyle = this.scoreColor(review.score);
      ctx.font = "950 150px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
      ctx.fillText(String(review.score), 90, 1480);

      ctx.fillStyle = "rgba(255,255,255,0.86)";
      ctx.font = "600 42px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
      this.wrapText(ctx, review.body || "Minha avaliação no Westan Critic", 90, 1580, 900, 54, 4);

      ctx.fillStyle = "rgba(255,255,255,0.58)";
      ctx.font = "800 34px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
      ctx.fillText("westan.com.br/critic", 90, 1810);

      const link = document.createElement("a");
      link.download = `westan-critic-${album.slug || album.id}.png`;
      link.href = canvas.toDataURL("image/png");
      link.click();
    } catch (e) {
      // Canvas export can fail when a remote cover blocks CORS. Keep the page alive.
      // eslint-disable-next-line no-console
      console.error(e);
    } finally {
      this.exporting = false;
    }
  }

  async drawCover(ctx, url) {
    if (!url) {
      this.drawFallbackCover(ctx);
      return;
    }

    try {
      const image = await new Promise((resolve, reject) => {
        const img = new Image();
        img.crossOrigin = "anonymous";
        img.onload = () => resolve(img);
        img.onerror = reject;
        img.src = url;
      });

      const size = 820;
      const x = 130;
      const y = 120;
      ctx.save();
      this.roundedRect(ctx, x, y, size, size, 42);
      ctx.clip();
      ctx.drawImage(image, x, y, size, size);
      ctx.restore();
    } catch {
      this.drawFallbackCover(ctx);
    }
  }

  drawFallbackCover(ctx) {
    ctx.fillStyle = "#9333ea";
    this.roundedRect(ctx, 130, 120, 820, 820, 42);
    ctx.fill();
  }

  roundedRect(ctx, x, y, width, height, radius) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }

  wrapText(ctx, text, x, y, maxWidth, lineHeight, maxLines) {
    const words = String(text || "").split(/\s+/);
    let line = "";
    let lines = 0;

    for (const word of words) {
      const testLine = line ? `${line} ${word}` : word;
      if (ctx.measureText(testLine).width > maxWidth && line) {
        ctx.fillText(line, x, y + lines * lineHeight);
        line = word;
        lines += 1;
        if (lines >= maxLines) {
          return;
        }
      } else {
        line = testLine;
      }
    }

    if (line && lines < maxLines) {
      ctx.fillText(line, x, y + lines * lineHeight);
    }
  }

  scoreColor(score) {
    if (score >= 70) {
      return "#35c759";
    }

    if (score >= 50) {
      return "#f59e0b";
    }

    return "#ff2d55";
  }

  <template>
    <div class="westan-album-page__buttons">
      <LinkTo
        @route={{this.reviewRoute}}
        @model={{@album.slug}}
        class="westan-album-page__review-button"
      >
        {{this.reviewLabel}}
      </LinkTo>

      <button
        type="button"
        class={{if
          this.favorited
          "westan-album-page__favorite-button is-active"
          "westan-album-page__favorite-button"
        }}
        aria-label="Favoritar"
        {{on "click" this.toggleFavorite}}
      >
        ♡
      </button>

      {{#if this.userReview}}
        <button
          type="button"
          class="westan-album-page__download-button"
          aria-label="Baixar imagem da avaliação"
          disabled={{this.exporting}}
          {{on "click" this.downloadReviewImage}}
        >
          ⤓
        </button>
      {{/if}}
    </div>
  </template>
}
