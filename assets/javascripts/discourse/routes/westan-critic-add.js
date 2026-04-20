import DiscourseRoute from "discourse/routes/discourse";

export default class WestanCriticAddRoute extends DiscourseRoute {
  beforeModel(transition) {
    if (!this.currentUser) {
      transition.abort();
      this.router.replaceWith("login");
    }
  }
}
