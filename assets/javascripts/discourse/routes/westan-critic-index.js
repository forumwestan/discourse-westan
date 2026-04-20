import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticIndexRoute extends DiscourseRoute {
  async model() {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const releasedSince = sevenDaysAgo.toISOString().slice(0, 10);

    const [thisWeek, recentAlbums, recentSingles, upcoming] = await Promise.all([
      ajax("/westan/critic/albums", { data: { released_since: releasedSince, limit: 20 } }),
      ajax("/westan/critic/albums", { data: { type: "album", limit: 20 } }),
      ajax("/westan/critic/albums", { data: { type: "single", limit: 20 } }),
      ajax("/westan/critic/albums", { data: { upcoming: "true", include_upcoming: "true", limit: 1 } }),
    ]);

    return {
      thisWeek: thisWeek.albums || [],
      recentAlbums: recentAlbums.albums || [],
      recentSingles: recentSingles.albums || [],
      upcoming: (upcoming.albums || [])[0],
    };
  }
}
