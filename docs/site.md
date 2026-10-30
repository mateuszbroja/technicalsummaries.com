# Summary site

Add Markdown summaries under [content/docs/](../content/docs). Hugo configuration lives in [hugo.toml](../hugo.toml).

[hugo-book/](../themes/hugo-book) is a Git submodule pinned to release `v0.15.0`, which requires Hugo 0.158.0 or newer. To update it, check out a newer release tag in the submodule, build the site locally and commit the new submodule pointer.

Netlify builds the site with the Hugo version set in [netlify.toml](../netlify.toml). Raise `HUGO_VERSION` there when the theme requires it.

The site is published at [technicalsummaries.com][site] and [bookssummary.netlify.app][netlify].

[site]: https://technicalsummaries.com/
[netlify]: https://bookssummary.netlify.app/
