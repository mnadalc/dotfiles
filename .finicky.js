// https://github.com/johnste/finicky/wiki/Configuration
module.exports = {
  // default profile and browser if the URL doesn't match any rules
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Profile 5", // TODO: Change to the correct profile. https://github.com/johnste/finicky/wiki/Configuration#2-you-can-define-more-options-with-a-browser-object
  },
  // App settings
  options: {
    hideIcon: false,
    checkForUpdate: true,
  },
  // Handlers are matchers
  handlers: [
    {
      match: [
        finicky.matchDomains(/192\.168\.1\.1/),
        finicky.matchDomains(/192\.168\.0\.1/),
        finicky.matchDomains(/192\.168\..*/),
        finicky.matchDomains(/.*nas.local\..*/),
        finicky.matchDomains(/youtube.com/),
        finicky.matchDomains(/mediavida.com/),
        finicky.matchDomains(/forocoches.com/),
        finicky.matchDomains(/reddit.com/),
        finicky.matchDomains(/instagram.com/),
        finicky.matchDomains(/tiktok.com/),
        finicky.matchDomains(/twitter.com/),
        finicky.matchDomains(/x.com/),
        finicky.matchDomains(/linkedin.com/),
        finicky.matchDomains(/patreon.com/),
        finicky.matchDomains(/twitch.tv/),
        finicky.matchDomains(/discord.com/),
        finicky.matchDomains(/amazon.com/),
        finicky.matchDomains(/apple.com/),
        finicky.matchDomains(/spotify.com/),
        finicky.matchDomains(/frontendmasters.com/),
        finicky.matchDomains(/obsidian.md/),
      ],
      browser: "app.zen-browser.zen",
    },
    {
      match: [
        finicky.matchDomains(/localhost/),
        finicky.matchDomains(/.*commercetools\..*/),
        finicky.matchDomains(/.*frontastic\..*/),
        finicky.matchDomains(/.*\.leapsome\..*/),
        finicky.matchDomains(/.*\.rydoo.com\..*/),
      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 5", // TODO: Change to the correct profile. https://github.com/johnste/finicky/wiki/Configuration#2-you-can-define-more-options-with-a-browser-object
      },
    },
    /* Open any links from Telegram in Zen Browser */
    {
      match: ({ opener }) => opener.bundleId === "ru.keepcoder.Telegram",
      browser: "app.zen-browser.zen",
    },
    /* Open any links from WhatsApp in Zen Browser */
    {
      match: ({ opener }) => opener.bundleId === "net.whatsapp.WhatsApp",
      browser: "app.zen-browser.zen",
    },
    /* Open any links from Alfred 5 in Zen Browser */
    {
      match: ({ opener }) =>
        opener.bundleId === "com.runningwithcrayons.Alfred",
      browser: "app.zen-browser.zen",
    },
    /* Open any links from Obsidian in Zen Browser */
    {
      match: ({ opener }) => opener.bundleId === "md.obsidian",
      browser: "app.zen-browser.zen",
    },
  ],
};
