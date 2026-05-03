import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticAlbumRoute extends DiscourseRoute {
  async model(params) {
    const { album } = await ajax(`/westan/critic/albums/${params.slug}`);
    const [userRes, pressRes] = await Promise.all([
      ajax("/westan/critic/reviews", { data: { album_id: album.id, kind: "user", page: 1 } }),
      ajax("/westan/critic/reviews", { data: { album_id: album.id, kind: "press", page: 1 } }),
    ]);
    return {
      album,
      userReviews: userRes.reviews || [],
      pressReviews: pressRes.reviews || [],
    };
  }
}
