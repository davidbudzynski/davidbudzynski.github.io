# David Budzynski's Blog

This is the source code of my personal blog [https://davidbudzynski.github.io/](https://davidbudzynski.github.io/).
It's a simple Jekyll-powered site, that I deploy on GitHub pages.

Feel free to send PRs addressing typos, bad grammar, visual glitches, etc.

## License

Site code and fenced code examples in posts are [GPLv3 or later](LICENSE.md).
Post prose and images are © David Budzyński, all rights reserved — ask before
sharing. See [LICENSE.md](LICENSE.md) for details.

To run the site locally, you need to have Ruby installed (macOS and Linux are
both supported). Then run the following commands:

```bash
bundle install
bundle exec jekyll serve --open-url --livereload --drafts
```

The first `bundle install` sets up the project. Gems are installed into
`vendor/bundle/` (see `.bundle/config`), so no `sudo` is needed, and the
directory is git-ignored.

The `Gemfile` uses the [`github-pages`
gem](https://github.com/github/pages-gem), which pins the same Jekyll version
that GitHub Pages uses in production. This keeps the local build output
identical to the deployed site.

To update all gems within the project, run (assuming you have Bundler
installed):

```bash
bundle update
```
