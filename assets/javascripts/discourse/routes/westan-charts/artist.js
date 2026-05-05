import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { htmlSafe } from "@ember/template";

function imageFor(item, preferredIndex = 3) {
  const images = item?.image || [];
  const preferred = images[preferredIndex]?.["#text"];
  const fallback = [...images].reverse().find((image) => image?.["#text"])?.["#text"];
  return preferred || fallback || "";
}

function artistName(item) {
  return item?.artist?.name || item?.artist?.["#text"] || item?.artist || "";
}

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
    const topAlbums = albums?.topalbums?.album || [];
    const topTracks = tracks?.toptracks?.track || [];
    const heroImage = imageFor(info?.artist) || imageFor(topAlbums[0]) || imageFor(topTracks[0]);

    return {
      artistName: params.artist_name,
      info: info?.artist,
      listeners: Number(info?.artist?.stats?.listeners || 0).toLocaleString("pt-BR"),
      heroImage,
      heroStyle: heroImage
        ? htmlSafe(`background-image: linear-gradient(90deg, rgba(7, 9, 15, 0.82), rgba(7, 9, 15, 0.12)), url("${heroImage}")`)
        : htmlSafe(""),
      heroAlbum: topAlbums[0]
        ? {
            title: topAlbums[0].name,
            artist: params.artist_name,
            plays: Number(topAlbums[0].playcount || 0).toLocaleString("pt-BR"),
            image: imageFor(topAlbums[0]),
          }
        : null,
      albums: topAlbums.map((album, index) => ({
        index: index + 1,
        name: album.name,
        image: imageFor(album),
        plays: album.playcount,
      })),
      tracks: topTracks.map((track, index) => ({
        index: index + 1,
        name: track.name,
        artist: artistName(track) || params.artist_name,
        image: imageFor(track) || imageFor(topAlbums[index]) || imageFor(topAlbums[0]),
        plays: track.playcount,
      })),
    };
  }
}
