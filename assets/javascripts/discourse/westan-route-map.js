export default function () {
  this.route("westan-admin", { path: "/admin/plugins/westan" }, function () {
    this.route("critic-banners", { path: "/critic-banners" });
  });

  this.route("westan-charts", { path: "/charts" }, function () {
    this.route("recent", { path: "/recent" });
    this.route("streaming", { path: "/streaming" });
    this.route("connect", { path: "/connect" });
    this.route("artist", { path: "/artist/:artist_name" });
  });

  this.route("westan-critic", { path: "/critic" }, function () {
    this.route("releases", { path: "/releases" });
    this.route("recent", { path: "/recent" });
    this.route("my-reviews", { path: "/my-reviews" });
    this.route("add", { path: "/add" });
    this.route("album", { path: "/album/:slug" });
    this.route("album-review", { path: "/album/:slug/review" });
    this.route("single", { path: "/single/:slug" });
    this.route("single-review", { path: "/single/:slug/review" });
  });
}
