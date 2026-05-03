import DiscourseRoute from "discourse/routes/discourse";

export default class WestanChartsConnectRoute extends DiscourseRoute {
  beforeModel(transition) {
    if (!this.currentUser) {
      transition.abort();
      this.router.replaceWith("login");
    }
  }

  model() {
    return {
      username:
        this.currentUser?.westan_lastfm_username ||
        this.currentUser?.custom_fields?.lastfm_username ||
        "",
    };
  }
}
