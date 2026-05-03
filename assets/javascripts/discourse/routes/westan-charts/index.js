import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanChartsIndexRoute extends DiscourseRoute {
  async model() {
    const user = this.currentUser;
    const lastfmUsername =
      user?.westan_lastfm_username || user?.custom_fields?.lastfm_username;
    if (!lastfmUsername) {
      return {
        hasLastfm: false,
        profileUrl: user ? `/u/${user.username}/preferences/profile` : "/login",
        isLoggedIn: Boolean(user),
      };
    }

    const [artists, albums, tracks] = await Promise.all([
      ajax(`/westan/lastfm/user.gettopartists`, {
        data: { user: lastfmUsername, period: "1month", limit: 20 },
      }),
      ajax(`/westan/lastfm/user.gettopalbums`, {
        data: { user: lastfmUsername, period: "1month", limit: 20 },
      }),
      ajax(`/westan/lastfm/user.gettoptracks`, {
        data: { user: lastfmUsername, period: "1month", limit: 20 },
      }),
    ]);

    return {
      hasLastfm: true,
      username: lastfmUsername,
      artists: artists?.topartists?.artist || [],
      albums: albums?.topalbums?.album || [],
      tracks: tracks?.toptracks?.track || [],
    };
  }
}
