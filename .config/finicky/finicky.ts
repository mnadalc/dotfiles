// https://github.com/johnste/finicky/wiki/Configuration-(v4)
import type { FinickyConfig, OpenUrlOptions } from "/Applications/Finicky.app/Contents/Resources/finicky.d.ts";

export default {
	// default profile and browser if the URL doesn't match any rules
	defaultBrowser: "Google Chrome:Miguel Angel",
	// App settings
	options: {
		checkForUpdates: true,
	},
	// Handlers are matchers
	// Order is important, the first match is used
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
				/aihero.dev/,
			],
			browser: "Google Chrome:Miguel Angel",
		},
		{
			match: [
				/localhost/,
				/.*\.leapsome\..*/,
				/.*\.rydoo.com\..*/,
				/atlassian.net/,
				/jira.atlassian.com/,
				/figma.com/,
				/meet.google.com/,
				/docs.google.com/,
				/drive.google.com/,
				/calendar.google.com/,
				/keep.google.com/,
				/linear.app/,
				/linear.app\/celebrate/,
				/claude.ai/,
				/github.com\/kartenmacherei/,
				/shop-frontend-.*\.celebrate\.company/,
				/.*\.celebrate\.company/,
				/argocd\..*/,
				/rosemood\./,
				/kartenmacherei\./,
				/notebooklm.google.com/,
			],
			browser: "Google Chrome:extern.celebrate.company",
		},
		{
			match: [/realizon.app.personio.com/],
			browser: "Google Chrome:realizon.eu",
		},
		{
			match: [/github.com/],
			browser: "Google Chrome:Miguel Angel",
		},
		// {
		// 	match: (url: URL, options: OpenUrlOptions) => options.opener?.bundleId === "com.tinyspeck.slackmacgap",
		// 	browser: "app.zen-browser.zen",
		// },
	],
} satisfies FinickyConfig;
