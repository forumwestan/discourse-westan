import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

async function lastfmAjax(path, data) {
  try {
    return await ajax(path, { data });
  } catch (error) {
    return { westan_error: error };
  }
}

export default class WestanChartsRecentRoute extends DiscourseRoute {
  async model() {
    const lastfmUsername =
      this.currentUser?.westan_lastfm_username ||
      this.currentUser?.custom_fields?.lastfm_username;
    if (!lastfmUsername) {
      return {
        hasLastfm: false,
        isLoggedIn: Boolean(this.currentUser),
      };
    }

    const [weeklyArtists, monthlyArtists, weeklyAlbums, monthlyAlbums, weeklyTracks, monthlyTracks] =
      await Promise.all([
        lastfmAjax(`/westan/lastfm/user.gettopartists`, {
          user: lastfmUsername,
          period: "7day",
          limit: 50,
        }),
        lastfmAjax(`/westan/lastfm/user.gettopartists`, {
          user: lastfmUsername,
          period: "1month",
          limit: 50,
        }),
        lastfmAjax(`/westan/lastfm/user.gettopalbums`, {
          user: lastfmUsername,
          period: "7day",
          limit: 50,
        }),
        lastfmAjax(`/westan/lastfm/user.gettopalbums`, {
          user: lastfmUsername,
          period: "1month",
          limit: 50,
        }),
        lastfmAjax(`/westan/lastfm/user.gettoptracks`, {
          user: lastfmUsername,
          period: "7day",
          limit: 50,
        }),
        lastfmAjax(`/westan/lastfm/user.gettoptracks`, {
          user: lastfmUsername,
          period: "1month",
          limit: 50,
        }),
      ]);

    return {
      hasLastfm: true,
      charts: {
        weekly: {
          artists: weeklyArtists?.topartists?.artist || [],
          albums: weeklyAlbums?.topalbums?.album || [],
          tracks: weeklyTracks?.toptracks?.track || [],
        },
        monthly: {
          artists: monthlyArtists?.topartists?.artist || [],
          albums: monthlyAlbums?.topalbums?.album || [],
          tracks: monthlyTracks?.toptracks?.track || [],
        },
      },
      lastfmError:
        weeklyArtists?.westan_error ||
        monthlyArtists?.westan_error ||
        weeklyAlbums?.westan_error ||
        monthlyAlbums?.westan_error ||
        weeklyTracks?.westan_error ||
        monthlyTracks?.westan_error,
    };
  }
}
