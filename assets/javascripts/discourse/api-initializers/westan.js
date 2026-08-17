import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.8.0", (api) => {
  // Show a Westan Critic link inside the hamburger menu (native Discourse one)
  api.addCommunitySectionLink?.({
    name: "westan-critic",
    route: "westan-critic",
    title: "Westan Critic",
    text: "Westan Critic",
    icon: "star",
  });
});
