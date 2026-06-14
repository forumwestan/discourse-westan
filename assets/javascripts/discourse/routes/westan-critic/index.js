import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanCriticIndexRoute extends DiscourseRoute {
  async model() {
    const today = new Date();
    const weekStart = new Date(today);
    const day = weekStart.getDay();
    const daysSinceMonday = day === 0 ? 6 : day - 1;
    weekStart.setDate(weekStart.getDate() - daysSinceMonday);

    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 6);

    const releasedSince = weekStart.toISOString().slice(0, 10);
    const releasedUntil = weekEnd.toISOString().slice(0, 10);

    const [thisWeek, recentAlbums, recentSingles, upcoming] = await Promise.all([
      ajax("/westan/critic/albums", {
        data: {
          released_since: releasedSince,
          released_until: releasedUntil,
          include_upcoming: "true",
          limit: 20,
        },
      }),
      ajax("/westan/critic/albums", {
        data: { type: "album", reviewed: "true", order: "reviewed", limit: 20 },
      }),
      ajax("/westan/critic/albums", {
        data: { type: "single", reviewed: "true", order: "reviewed", limit: 20 },
      }),
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
