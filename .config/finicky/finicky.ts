// https://github.com/johnste/finicky/wiki/Configuration-(v4)
import type { FinickyConfig, OpenUrlOptions } from "/Applications/Finicky.app/Contents/Resources/finicky.d.ts";

export default {
	// default profile and browser if the URL doesn't match any rules
	defaultBrowser: {
		name: "Google Chrome",
		profile: "Profile 5", // TODO: Change to the correct profile. https://github.com/johnste/finicky/wiki/Configuration#2-you-can-define-more-options-with-a-browser-object
	},
	// App settings
	options: {
		checkForUpdates: true,
	},
	// Handlers are matchers
	handlers: [
		{
			match: [
				/192\.168\.1\.1/,
				/192\.168\.0\.1/,
				/192\.168\..*/,
				/.*nas.local\..*/,
				/youtube.com/,
				/mediavida.com/,
				/forocoches.com/,
				/reddit.com/,
				/instagram.com/,
				/tiktok.com/,
				/twitter.com/,
				/x.com/,
				/linkedin.com/,
				/patreon.com/,
				/twitch.tv/,
				/discord.com/,
				/amazon.com/,
				/apple.com/,
				/spotify.com/,
				/frontendmasters.com/,
				/obsidian.md/,
			],
			browser: "app.zen-browser.zen",
		},
		{
			match: [
				/localhost/,
				/.*commercetools\..*/,
				/.*frontastic\..*/,
				/.*\.leapsome\..*/,
				/.*\.rydoo.com\..*/,
				/atlassian.net/,
				/jira.atlassian.com/,
				/commercetools.atlassian.net/,
				/figma.com/,
				/meet.google.com/,
				/docs.google.com/,
				/drive.google.com/,
				/calendar.google.com/,
				/keep.google.com/,
			],
			browser: {
				name: "Google Chrome",
				profile: "Profile 5", // TODO: Change to the correct profile. https://github.com/johnste/finicky/wiki/Configuration#2-you-can-define-more-options-with-a-browser-object
			},
		},
		/* Open any links from Telegram in Zen Browser */
		{
			match: (url: URL, options: OpenUrlOptions) => options.opener?.bundleId === "ru.keepcoder.Telegram",
			browser: "app.zen-browser.zen",
		},
		/* Open any links from WhatsApp in Zen Browser */
		{
			match: (url: URL, options: OpenUrlOptions) => options.opener?.bundleId === "net.whatsapp.WhatsApp",
			browser: "app.zen-browser.zen",
		},
		/* Open any links from Alfred 5 in Zen Browser */
		{
			match: (url: URL, options: OpenUrlOptions) => options.opener?.bundleId === "com.runningwithcrayons.Alfred",
			browser: "app.zen-browser.zen",
		},
		/* Open any links from Obsidian in Zen Browser */
		{
			match: (url: URL, options: OpenUrlOptions) => options.opener?.bundleId === "md.obsidian",
			browser: "app.zen-browser.zen",
		},
		// {
		//   match: ({ opener }) => opener.bundleId === "com.tinyspeck.slackmacgap",
		//   browser: "app.zen-browser.zen",
		// },
		/* Github */
		{
			match: (url: URL) =>
				url.host === "github.com" &&
				(!url.pathname.toLowerCase().includes("frontasticgmbh") ||
					!url.pathname.toLowerCase().includes("commercetools")),
			browser: "app.zen-browser.zen",
		},
	],
} satisfies FinickyConfig;
