import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

async function lastfmAjax(path, data) {
  try {
    return await ajax(path, { data });
  } catch (error) {
    return { westan_error: error };
  }
}

export default class WestanChartsIndexRoute extends DiscourseRoute {
  async model() {
    const user = this.currentUser;
    const lastfmUsername =
      user?.westan_lastfm_username || user?.custom_fields?.lastfm_username;
    if (!lastfmUsername) {
      return {
        hasLastfm: false,
        isLoggedIn: Boolean(user),
      };
    }

    const [artists, albums, tracks] = await Promise.all([
      lastfmAjax(`/westan/lastfm/user.gettopartists`, {
        user: lastfmUsername,
        period: "1month",
        limit: 20,
      }),
      lastfmAjax(`/westan/lastfm/user.gettopalbums`, {
        user: lastfmUsername,
        period: "1month",
        limit: 20,
      }),
      lastfmAjax(`/westan/lastfm/user.gettoptracks`, {
        user: lastfmUsername,
        period: "1month",
        limit: 20,
      }),
    ]);

    return {
      hasLastfm: true,
      username: lastfmUsername,
      artists: artists?.topartists?.artist || [],
      albums: albums?.topalbums?.album || [],
      tracks: tracks?.toptracks?.track || [],
      lastfmError: artists?.westan_error || albums?.westan_error || tracks?.westan_error,
    };
  }
}
