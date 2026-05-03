import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class WestanChartsRecentRoute extends DiscourseRoute {
  async model() {
    const lastfmUsername =
      this.currentUser?.westan_lastfm_username ||
      this.currentUser?.custom_fields?.lastfm_username;
    if (!lastfmUsername) {
      return {
        hasLastfm: false,
        profileUrl: this.currentUser
          ? `/u/${this.currentUser.username}/preferences/profile`
          : "/login",
        isLoggedIn: Boolean(this.currentUser),
      };
    }
    const res = await ajax(`/westan/lastfm/user.getrecenttracks`, {
      data: { user: lastfmUsername, limit: 50 },
    });
    return {
      hasLastfm: true,
      tracks: res?.recenttracks?.track || [],
    };
  }
}
