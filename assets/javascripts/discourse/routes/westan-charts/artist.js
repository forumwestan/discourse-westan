import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanChartsArtistRoute extends DiscourseRoute {
  async model(params) {
    const lastfmUsername =
      this.currentUser?.westan_lastfm_username ||
      this.currentUser?.custom_fields?.lastfm_username;
    const [info, albums, tracks] = await Promise.all([
      ajax(`/westan/lastfm/artist.getinfo`, {
        data: { artist: params.artist_name, username: lastfmUsername },
      }),
      ajax(`/westan/lastfm/artist.gettopalbums`, {
        data: { artist: params.artist_name, limit: 20 },
      }),
      ajax(`/westan/lastfm/artist.gettoptracks`, {
        data: { artist: params.artist_name, limit: 20 },
      }),
    ]);
    return {
      artistName: params.artist_name,
      info: info?.artist,
      albums: albums?.topalbums?.album || [],
      tracks: tracks?.toptracks?.track || [],
    };
  }
}
