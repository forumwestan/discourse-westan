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
        isLoggedIn: Boolean(this.currentUser),
      };
    }
    let res = {};
    let lastfmError = null;
    try {
      res = await ajax(`/westan/lastfm/user.gettopartists`, {
        data: { user: lastfmUsername, period: "7day", limit: 50 },
      });
    } catch (error) {
      lastfmError = error;
    }

    return {
      hasLastfm: true,
      artists: res?.topartists?.artist || [],
      lastfmError,
    };
  }
}
