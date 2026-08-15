source "https://rubygems.org"

# GitHub Pages builds the site with Jekyll 3.9.x. Pinning to the github-pages
# gem keeps the local build environment identical to the one used for
# deployment, so there are no surprises when the site goes live.
gem "github-pages", group: :jekyll_plugins

# Default theme for Jekyll sites. You may change this to anything you like.
gem "minima"

# The github-pages stack relies on these default gems, which are no longer
# bundled with Ruby >= 3.4.
gem "logger"
gem "csv"

# Ruby >= 3.0 no longer ships WEBrick, which Jekyll needs for `serve`.
gem "webrick", "~> 1.7"