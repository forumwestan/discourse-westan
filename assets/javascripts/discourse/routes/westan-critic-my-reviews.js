import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticMyReviewsRoute extends DiscourseRoute {
  beforeModel(transition) {
    if (!this.currentUser) {
      transition.abort();
      this.router.replaceWith("login");
    }
  }

  async model() {
    const res = await ajax("/westan/critic/reviews", {
      data: { user_id: this.currentUser.id, kind: "user" },
    });
    return { reviews: res.reviews || [] };
  }
}
