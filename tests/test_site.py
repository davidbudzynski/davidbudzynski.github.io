"""Static regression tests for the Jekyll blog.

No third-party dependencies (stdlib only) so they run anywhere with Python 3,
including GitHub Actions. They validate front matter consistency, config
hardening, navigation pages, and internal links without needing a Jekyll build.

Run:  python3 -m unittest discover -s tests -v
"""

import os
import re
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
POSTS_DIR = os.path.join(ROOT, "_posts")
DRAFTS_DIR = os.path.join(ROOT, "_drafts")


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def parse_front_matter(text):
    """Minimal YAML-subset parser for our front matter.

    Returns (dict, body). Handles `key: value`, inline `[a, b]` lists,
    and block `- item` lists (e.g. redirect_from).
    """
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return {}, text
    fm = {}
    current_list_key = None
    for line in lines[1:end]:
        if not line.strip() or line.strip().startswith("#"):
            continue
        m = re.match(r"^(\s*)-\s+(.*)$", line)
        if m and current_list_key:
            fm[current_list_key].append(m.group(2).strip().strip("'\""))
            continue
        if ":" not in line:
            current_list_key = None
            continue
        key, _, value = line.partition(":")
        key = key.strip()
        value = value.strip()
        if value == "":
            fm[key] = []
            current_list_key = key
        elif value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            fm[key] = (
                [v.strip().strip("'\"") for v in inner.split(",")] if inner else []
            )
            current_list_key = None
        else:
            if (value.startswith('"') and value.endswith('"')) or (
                value.startswith("'") and value.endswith("'")
            ):
                value = value[1:-1]
            fm[key] = value
            current_list_key = None
    return fm, "\n".join(lines[end + 1 :])


def post_files():
    return sorted(
        f for f in os.listdir(POSTS_DIR) if f.endswith(".md")
    )


class ConfigTest(unittest.TestCase):
    def setUp(self):
        self.config = read(os.path.join(ROOT, "_config.yml"))

    def test_lang(self):
        self.assertIn("lang: en-GB", self.config)

    def test_timezone_uk(self):
        self.assertIn("timezone: Europe/London", self.config)

    def test_permalink_has_no_categories(self):
        m = re.search(r"^permalink:\s*(.+)$", self.config, re.M)
        self.assertIsNotNone(m, "permalink must be explicit")
        self.assertNotIn(":categories", m.group(1))
        self.assertIn(":year", m.group(1))
        self.assertIn(":title", m.group(1))

    def test_future_posts_stay_hidden(self):
        self.assertRegex(self.config, r"(?m)^future:\s*false")

    def test_excerpts(self):
        self.assertIn("excerpt_separator:", self.config)
        self.assertIn("show_excerpts: true", self.config)

    def test_header_pages(self):
        for page in ["about.md", "projects.md", "archive.md", "tags.html",
                     "search.md"]:
            self.assertIn(page, self.config, f"header_pages missing {page}")

    def test_plugins(self):
        for plugin in ["jekyll-feed", "jekyll-sitemap", "jekyll-seo-tag",
                       "jekyll-redirect-from"]:
            self.assertIn(plugin, self.config, f"plugin missing: {plugin}")

    def test_minima_skin(self):
        self.assertIn("skin: auto", self.config)

    def test_url(self):
        self.assertIn("https://davidbudzynski.github.io", self.config)

    def test_tests_dir_excluded_from_build(self):
        self.assertIn("tests/", self.config)


class PostFrontMatterTest(unittest.TestCase):
    def test_all_posts(self):
        files = post_files()
        self.assertGreaterEqual(len(files), 10, "expected at least 10 posts")
        for fname in files:
            with self.subTest(post=fname):
                self._check_post(fname)

    def _check_post(self, fname):
        self.assertRegex(
            fname, r"^\d{4}-\d{2}-\d{2}-.+\.md$",
            "filename must be YYYY-MM-DD-slug.md",
        )
        fm, body = parse_front_matter(read(os.path.join(POSTS_DIR, fname)))
        self.assertEqual(fm.get("layout"), "post")
        self.assertTrue(fm.get("title"), "title is required")
        self.assertTrue(fm.get("date"), "date is required")
        # Filename date must match front-matter date (prevents URL confusion).
        front_date = str(fm["date"])[:10]
        self.assertEqual(
            fname[:10],
            front_date,
            f"filename date {fname[:10]} != front-matter date {front_date}",
        )
        # Tags must be a non-empty list (never a bare string).
        tags = fm.get("tags")
        self.assertIsInstance(tags, list, "tags must be a YAML list like [R]")
        self.assertTrue(tags, "tags must not be empty")
        for tag in tags:
            self.assertTrue(tag.strip(), "tags must not contain blanks")
        lowered = [t.lower() for t in tags]
        self.assertEqual(len(set(lowered)), len(tags), "duplicate tags")
        # Legacy single-category URLs are gone; permalink is explicit.
        self.assertNotIn("category", fm, "use tags, not category")
        self.assertNotIn("categories", fm, "use tags, not categories")
        # SEO description required.
        desc = fm.get("description", "")
        self.assertIsInstance(desc, str)
        self.assertGreaterEqual(
            len(desc), 20, "description should be a full sentence (20+ chars)"
        )

    def test_legacy_category_urls_preserved(self):
        expected = {
            "2021-10-25-two-years-in-linux.md":
                "/general/2021/10/25/two-years-in-linux.html",
            "2022-04-23-r-native-placeholder.md":
                "/general/2022/04/23/r-native-placeholder.html",
            "2024-03-10-split-keyboard.md":
                "/general/2024/03/10/split-keyboard.html",
            "2024-04-13-firefox-customization.md":
                "/general/2024/04/13/firefox-customization.html",
        }
        for fname, old_url in expected.items():
            with self.subTest(post=fname):
                fm, _ = parse_front_matter(
                    read(os.path.join(POSTS_DIR, fname))
                )
                redirects = fm.get("redirect_from", [])
                self.assertIn(old_url, redirects)

    def test_renamed_files_match_front_matter(self):
        self.assertTrue(
            os.path.exists(
                os.path.join(POSTS_DIR,
                             "2026-08-15-program-spotlight-rclone.md")
            )
        )
        self.assertTrue(
            os.path.exists(
                os.path.join(POSTS_DIR, "2024-03-15-cpp-notebooks-org-mode.md")
            )
        )
        self.assertFalse(
            os.path.exists(
                os.path.join(POSTS_DIR,
                             "2024-03-13-program-spotlight-rclone.md")
            )
        )
        self.assertFalse(
            os.path.exists(
                os.path.join(POSTS_DIR, "2024-04-15-cpp-notebooks-org-mode.md")
            )
        )


class ExcerptMarkerTest(unittest.TestCase):
    """Every post/draft must contain the excerpt_separator marker.

    With a custom excerpt_separator, Jekyll uses the WHOLE article as the
    excerpt when the marker is missing — the home page then renders full
    articles instead of previews. This test makes that failure loud.
    """

    def _check_dir(self, directory):
        files = sorted(
            f for f in os.listdir(directory) if f.endswith(".md")
        )
        self.assertTrue(files, f"expected markdown files in {directory}")
        for fname in files:
            with self.subTest(file=fname):
                _, body = parse_front_matter(
                    read(os.path.join(directory, fname))
                )
                self.assertIn(
                    "<!--more-->",
                    body,
                    "missing excerpt marker — home page would show full text",
                )

    def test_posts_have_markers(self):
        self._check_dir(POSTS_DIR)

    def test_drafts_have_markers(self):
        self._check_dir(DRAFTS_DIR)


class PostImagesTest(unittest.TestCase):
    IMG_RE = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")

    def test_images_exist_lazy_and_descriptive(self):
        for fname in post_files():
            text = read(os.path.join(POSTS_DIR, fname))
            _, body = parse_front_matter(text)
            alts = []
            for m in self.IMG_RE.finditer(body):
                alt, src = m.group(1), m.group(2)
                with self.subTest(post=fname, src=src):
                    self.assertGreaterEqual(
                        len(alt.strip()), 4, "alt text must be descriptive"
                    )
                    alts.append(alt.strip().lower())
                    if src.startswith("/assets/"):
                        disk = os.path.join(ROOT, src.lstrip("/"))
                        self.assertTrue(
                            os.path.exists(disk), f"missing image: {src}"
                        )
                    line = next(
                        line for line in body.splitlines() if src in line
                    )
                    self.assertIn(
                        'loading="lazy"',
                        line,
                        f"image should lazy-load: {src}",
                    )
            self.assertEqual(
                len(set(alts)), len(alts), f"duplicate alt text in {fname}"
            )


class PagesTest(unittest.TestCase):
    def test_archive(self):
        text = read(os.path.join(ROOT, "archive.md"))
        fm, body = parse_front_matter(text)
        self.assertEqual(fm.get("permalink"), "/archive/")
        self.assertIn("group_by_exp", body)

    def test_search_page(self):
        text = read(os.path.join(ROOT, "search.md"))
        fm, body = parse_front_matter(text)
        self.assertEqual(fm.get("permalink"), "/search/")
        self.assertIn("search.json", body)
        self.assertIn("search-input", body)

    def test_search_index(self):
        text = read(os.path.join(ROOT, "search.json"))
        fm, _ = parse_front_matter(text)
        self.assertEqual(fm.get("layout"), "null")
        self.assertIn("site.posts", text)
        self.assertIn("post.description", text)

    def test_tags_page(self):
        text = read(os.path.join(ROOT, "tags.html"))
        fm, _ = parse_front_matter(text)
        self.assertEqual(fm.get("permalink"), "/tags/")

    def test_404_links_home_archive_tags(self):
        text = read(os.path.join(ROOT, "404.html"))
        self.assertIn('"/" | relative_url', text)
        self.assertIn("/archive/", text)
        self.assertIn("/tags/", text)

    def test_home_intro_links(self):
        text = read(os.path.join(ROOT, "index.markdown"))
        for link in ["/about/", "/tags/", "/archive/", "/search/",
                     "/feed.xml"]:
            self.assertIn(link, text, f"home missing link {link}")

    def test_about_crosslinks(self):
        text = read(os.path.join(ROOT, "about.md"))
        for link in ["/archive/", "/tags/", "/projects/", "/feed.xml"]:
            self.assertIn(link, text, f"about missing link {link}")


class LayoutsTest(unittest.TestCase):
    def test_home_prefers_description_over_excerpt(self):
        text = read(os.path.join(ROOT, "_layouts", "home.html"))
        self.assertIn("post.description", text)
        self.assertIn("post.excerpt", text,
                      "home must fall back to excerpt when description missing")
        self.assertIn("post-list", text)
        self.assertIn("rss-subscribe", text)
    def test_post_layout_nav_related_comments(self):
        text = read(os.path.join(ROOT, "_layouts", "post.html"))
        self.assertIn("page.previous", text)
        self.assertIn("page.next", text)
        # Jekyll: site.posts is newest-first, so previous == older post,
        # next == newer post. Labels must match that order.
        prev_block = text.split("page.previous")[1].split("endif")[0]
        self.assertIn("Older", prev_block)
        next_block = text.split("page.next")[1].split("endif")[0]
        self.assertIn("Newer", next_block)
        self.assertIn("Related posts", text)
        self.assertIn('include utterances.html issue-term="pathname"', text)
        self.assertNotIn("prepend: 'Comments:", text)

    def test_utterances_stable_and_accessible(self):
        text = read(os.path.join(ROOT, "_includes", "utterances.html"))
        self.assertIn("default: 'pathname'", text)
        self.assertIn("<noscript>", text)

    def test_head_polish(self):
        text = read(os.path.join(ROOT, "_includes", "head.html"))
        self.assertIn("theme-color", text)
        self.assertIn("apple-touch-icon", text)


class LinksTest(unittest.TestCase):
    def test_post_url_tags_resolve(self):
        slugs = {f[:-3] for f in post_files()}  # filename without .md
        for page in ["projects.md", "about.md", "archive.md"]:
            path = os.path.join(ROOT, page)
            if not os.path.exists(path):
                continue
            text = read(path)
            for m in re.finditer(r"{%\s*post_url\s+(\S+)\s*%}", text):
                slug = m.group(1).strip("'\"")
                # post_url takes a filename without dirs, e.g. 2024-11-20-x
                slug = os.path.basename(slug)
                with self.subTest(page=page, slug=slug):
                    self.assertIn(slug, slugs, f"broken post_url: {slug}")

    def test_no_ds_store(self):
        for dirpath, _, filenames in os.walk(ROOT):
            if "/.git/" in dirpath or "/vendor/" in dirpath:
                continue
            self.assertNotIn(".DS_Store", filenames, dirpath)
        gitignore = read(os.path.join(ROOT, ".gitignore"))
        self.assertIn(".DS_Store", gitignore)


class DraftsTest(unittest.TestCase):
    def test_drafts_have_basics(self):
        if not os.path.isdir(DRAFTS_DIR):
            self.skipTest("no _drafts dir")
        files = [f for f in os.listdir(DRAFTS_DIR) if f.endswith(".md")]
        self.assertTrue(files, "expected drafts")
        for fname in sorted(files):
            with self.subTest(draft=fname):
                fm, _ = parse_front_matter(
                    read(os.path.join(DRAFTS_DIR, fname))
                )
                self.assertEqual(fm.get("layout"), "post")
                self.assertTrue(fm.get("title"))
                self.assertIsInstance(fm.get("tags"), list)


if __name__ == "__main__":
    unittest.main()
