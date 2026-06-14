import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticRecentRoute extends DiscourseRoute {
  async model() {
    const res = await ajax("/westan/critic/albums", {
      data: { reviewed: "true", order: "reviewed", limit: 60 },
    });
    return { albums: res.albums || [] };
  }
}
