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
- Drafts: `_drafts/slug.md` — no date and no `date` field.
- Markdown with `##` headings and reference-style links (`[text][1]` + `[1]: url`).
- Tags render as links to `/tags/#<slug>` and are normalized to lowercase.

## Drafts vs. publication

Drafting and publishing are two separate pieces of work and belong in two
separate PRs. Do not mix them unless the user explicitly asks for one PR.

### Draft PR (authoring)

- Branch: `content/<slug>` (e.g. `content/r-packages-2026`).
- File: `_drafts/<slug>.md`, edited in place as the draft evolves.
- Commits: `content(drafts): ...` — e.g. `content(drafts): add r packages draft`.
- Scope: the draft content only. No `date`, no move into `_posts/`, no site
  changes.
- Done when the draft reads complete on its own. It is fine to merge it and
  leave it unpublished for weeks.

### Publication PR (release)

- Branch: `content/publish-<slug>` (e.g. `content/publish-r-packages-2026`).
- Change: move `_drafts/<slug>.md` to `_posts/YYYY-MM-DD-<final-slug>.md` and
  add the `date` field.
- Commits: `content(post): publish <title>`.
- Scope: only what publishing requires — the rename, the `date`, front-matter
  touch-ups (final `title`, `description`, `tags`), and fixing links that used
  the old draft slug. No new sections or rewrites; if the body still needs
  work, do that in a draft PR first.
- The filename slug is the public URL (`/YYYY/MM/DD/<final-slug>.html`), so
  choose the final name here rather than during drafting.
- `date` is the intended publication date, not the date the draft was written.
  A future date schedules the post and is allowed.
- Done when `bundle exec jekyll build` passes and the rendered URL, title,
  date, and tags are correct.

If the request is just "write a post" without saying to publish, default to a
draft PR and ask before publishing.

## Git workflow

- Default branch is `master`.
- Use conventional commits: `type(scope): description` — repo also uses custom
  `content(...)` and `polish(...)` types alongside `feat`/`fix`/`docs`/`chore`/`build`.
- Create a branch for new work named `type/description` (e.g. `feat/article-drafts`)
  and merge to `master` when done. Content branches follow the draft/publication
  split above: `content/<slug>` for drafts, `content/publish-<slug>` for releases.
- PR titles follow the same convention as commits, so a draft PR is
  `content(drafts): ...` and a publication PR is `content(post): publish ...`.
- Never add yourself as co-author of any contribution — commits, PRs, or
  otherwise. Agents cannot be authors, humans can be; agents are assistants.

## Don't touch unless asked

- `_config.yml`, `Gemfile`, `Gemfile.lock`, `vendor/`, `_site/`, theme layouts/includes.