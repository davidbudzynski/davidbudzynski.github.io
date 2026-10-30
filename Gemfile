source "https://rubygems.org"

# Deployed with a custom GitHub Actions workflow (.github/workflows/pages.yml),
# not the legacy branch-based Pages build. This allows Jekyll 4 + current
# plugins instead of the pinned github-pages gem set.
gem "jekyll", "~> 4.4.1"

# Current theme release (2.5.2 is latest; see _config.yml re: `skin`).
gem "minima", "~> 2.5.2"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-redirect-from", "~> 0.16"
end

# Ruby >= 3.0 no longer ships WEBrick, which Jekyll needs for `serve`.
gem "webrick", "~> 1.9"
