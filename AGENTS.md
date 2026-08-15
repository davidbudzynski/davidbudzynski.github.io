# AGENTS.md

Personal blog built with Jekyll (minima theme), deployed to GitHub Pages.

## Local development

- `bundle install` — first-time setup (gems go to `vendor/bundle/`, git-ignored).
- `bundle exec jekyll serve --open-url --livereload --drafts` — serve locally, including drafts.

## Writing posts

- Published posts: `_posts/YYYY-MM-DD-slug.md` with front matter:
  ```yaml
  layout : post
  title  : "Title"
  date   : YYYY-MM-DD HH:MM
  tags   : [Tag1, Tag2]
  ```
- Drafts: `_drafts/slug.md` (no date). Publish by moving into `_posts/` and adding a `date`.
- Markdown with `##` headings and reference-style links (`[text][1]` + `[1]: url`).
- Tags render as links to `/tags/#<slug>` and are normalized to lowercase.

## Git workflow

- Default branch is `master`.
- Use conventional commits: `type(scope): description` — repo also uses custom
  `content(...)` and `polish(...)` types alongside `feat`/`fix`/`docs`/`chore`/`build`.
- Create a branch for new work named `type/description` (e.g. `feat/article-drafts`)
  and merge to `master` when done.
- Never add yourself as co-author of any contribution — commits, PRs, or
  otherwise. Agents cannot be authors, humans can be; agents are assistants.

## Don't touch unless asked

- `_config.yml`, `Gemfile`, `Gemfile.lock`, `vendor/`, `_site/`, theme layouts/includes.