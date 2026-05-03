import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticReleasesRoute extends DiscourseRoute {
  async model() {
    const res = await ajax("/westan/critic/albums", { data: { limit: 200 } });
    const albums = (res.albums || []).slice().sort(
      (a, b) => (b.avg_user_score || 0) - (a.avg_user_score || 0)
    );
    return { albums };
  }
}
