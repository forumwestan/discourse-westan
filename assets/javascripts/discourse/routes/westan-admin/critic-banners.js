import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanAdminCriticBannersRoute extends DiscourseRoute {
  beforeModel(transition) {
    if (!this.currentUser?.staff) {
      transition.abort();
      this.router.replaceWith("discovery.latest");
    }
  }

  async model() {
    const result = await ajax("/westan/critic/hero-cards");
    return {
      cards: result.cards || [],
    };
  }
}
