import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticAlbumReviewRoute extends DiscourseRoute {
  beforeModel(transition) {
    if (!this.currentUser) {
      transition.abort();
      this.router.replaceWith("login");
    }
  }

  async model(params) {
    const { album } = await ajax(`/westan/critic/albums/${params.slug}`);
    const { reviews } = await ajax("/westan/critic/reviews", {
      data: { album_id: album.id, user_id: this.currentUser.id, kind: "user" },
    });
    return { album, existing: reviews?.[0] };
  }
}
