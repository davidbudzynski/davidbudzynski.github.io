# frozen_string_literal: true

# Static regression tests for the Jekyll blog.
#
# Stdlib only (minitest + yaml) so they run with any working Ruby and no
# `bundle install`:
#
#   ruby -Itests tests/test_site.rb
#
# They validate front matter consistency, config hardening, navigation
# pages, and internal links without needing a Jekyll build.

require "minitest/autorun"
require "yaml"
require "date"
require "set"

ROOT = File.expand_path("..", __dir__)
POSTS_DIR = File.join(ROOT, "_posts")
DRAFTS_DIR = File.join(ROOT, "_drafts")

def read_file(path)
  File.read(path, encoding: "utf-8")
end

# Returns [front_matter_hash, body_string] using a real YAML parser.
def parse_front_matter(text)
  lines = text.lines
  return [{}, text] unless lines.first&.strip == "---"

  closing = lines[1..].index { |line| line.strip == "---" }
  return [{}, text] if closing.nil?

  fm_text = lines[1, closing].join
  body = lines[(closing + 2)..]&.join.to_s
  data = YAML.safe_load(fm_text, permitted_classes: [Date, Time, DateTime]) || {}
  [data, body]
end

# Front-matter dates may parse to String, Date, Time, or DateTime.
# Normalizes all of them to "YYYY-MM-DD".
def front_date_prefix(value)
  if value.respond_to?(:strftime)
    value.strftime("%Y-%m-%d")
  else
    value.to_s[0, 10]
  end
end

def post_files
  Dir.children(POSTS_DIR).select { |f| f.end_with?(".md") }.sort
end

def markdown_files(dir)
  Dir.children(dir).select { |f| f.end_with?(".md") }.sort
end

class ConfigTest < Minitest::Test
  def setup
    @config = read_file(File.join(ROOT, "_config.yml"))
  end

  def test_lang
    assert_includes @config, "lang: en-GB"
  end

  def test_timezone_uk
    assert_includes @config, "timezone: Europe/London"
  end

  def test_permalink_has_no_categories
    permalink = @config[/^permalink:\s*(.+)$/, 1]
    refute_nil permalink, "permalink must be explicit"
    refute_includes permalink, ":categories"
    assert_includes permalink, ":year"
    assert_includes permalink, ":title"
  end

  def test_future_posts_stay_hidden
    assert_match(/^future:\s*false/, @config)
  end

  def test_excerpts
    assert_includes @config, "excerpt_separator:"
    assert_includes @config, "show_excerpts: true"
  end

  def test_header_pages
    %w[about.md projects.md archive.md tags.html search.md].each do |page|
      assert_includes @config, page, "header_pages missing #{page}"
    end
  end

  def test_plugins
    %w[jekyll-feed jekyll-sitemap jekyll-seo-tag jekyll-redirect-from].each do |plugin|
      assert_includes @config, plugin, "plugin missing: #{plugin}"
    end
  end

  def test_minima_skin
    assert_includes @config, "skin: auto"
  end

  def test_url
    assert_includes @config, "https://davidbudzynski.github.io"
  end

  def test_tests_dir_excluded_from_build
    assert_includes @config, "tests/"
  end
end

class PostFrontMatterTest < Minitest::Test
  def test_all_posts
    files = post_files
    assert_operator files.length, :>=, 10, "expected at least 10 posts"
    files.each { |fname| check_post(fname) }
  end

  def check_post(fname)
    ctx = "post #{fname}"
    assert_match(/^\d{4}-\d{2}-\d{2}-.+\.md$/, fname,
      "#{ctx}: filename must be YYYY-MM-DD-slug.md")
    fm, = parse_front_matter(read_file(File.join(POSTS_DIR, fname)))
    assert_equal "post", fm["layout"], "#{ctx}: layout must be post"
    assert fm["title"] && !fm["title"].to_s.empty?, "#{ctx}: title is required"
    assert fm["date"], "#{ctx}: date is required"
    # Filename date must match front-matter date (prevents URL confusion).
    assert_equal fname[0, 10], front_date_prefix(fm["date"]),
      "#{ctx}: filename date != front-matter date"
    # Tags must be a non-empty list (never a bare string).
    tags = fm["tags"]
    assert_kind_of Array, tags, "#{ctx}: tags must be a YAML list like [R]"
    refute_empty tags, "#{ctx}: tags must not be empty"
    tags.each do |tag|
      assert !tag.to_s.strip.empty?, "#{ctx}: tags must not contain blanks"
    end
    lowered = tags.map { |t| t.to_s.downcase }
    assert_equal lowered.uniq.length, tags.length, "#{ctx}: duplicate tags"
    # Legacy single-category URLs are gone; permalink is explicit.
    refute fm.key?("category"), "#{ctx}: use tags, not category"
    refute fm.key?("categories"), "#{ctx}: use tags, not categories"
    # SEO description required.
    desc = fm["description"]
    assert_kind_of String, desc, "#{ctx}: description is required"
    assert_operator desc.length, :>=, 20,
      "#{ctx}: description should be a full sentence (20+ chars)"
  end

  def test_legacy_category_urls_preserved
    expected = {
      "2021-10-25-two-years-in-linux.md" => "/general/2021/10/25/two-years-in-linux.html",
      "2022-04-23-r-native-placeholder.md" => "/general/2022/04/23/r-native-placeholder.html",
      "2024-03-10-split-keyboard.md" => "/general/2024/03/10/split-keyboard.html",
      "2024-04-13-firefox-customization.md" => "/general/2024/04/13/firefox-customization.html"
    }
    expected.each do |fname, old_url|
      fm, = parse_front_matter(read_file(File.join(POSTS_DIR, fname)))
      assert_kind_of Array, fm["redirect_from"], "#{fname}: redirect_from required"
      assert_includes fm["redirect_from"], old_url, fname
    end
  end

  def test_renamed_files_match_front_matter
    assert File.exist?(File.join(POSTS_DIR, "2026-08-15-program-spotlight-rclone.md"))
    assert File.exist?(File.join(POSTS_DIR, "2024-03-15-cpp-notebooks-org-mode.md"))
    refute File.exist?(File.join(POSTS_DIR, "2024-03-13-program-spotlight-rclone.md"))
    refute File.exist?(File.join(POSTS_DIR, "2024-04-15-cpp-notebooks-org-mode.md"))
  end
end

class ExcerptMarkerTest < Minitest::Test
  # Every post/draft must contain the excerpt_separator marker.
  # With a custom excerpt_separator, Jekyll uses the WHOLE article as the
  # excerpt when the marker is missing — the home page then renders full
  # articles instead of previews. These tests make that failure loud.
  def check_dir(directory)
    files = markdown_files(directory)
    refute_empty files, "expected markdown files in #{directory}"
    files.each do |fname|
      _, body = parse_front_matter(read_file(File.join(directory, fname)))
      assert_includes body, "<!--more-->",
        "#{fname}: missing excerpt marker — home page would show full text"
    end
  end

  def test_posts_have_markers
    check_dir(POSTS_DIR)
  end

  def test_drafts_have_markers
    check_dir(DRAFTS_DIR)
  end
end

class PostImagesTest < Minitest::Test
  IMG_RE = %r{!\[([^\]]*)\]\(([^)]+)\)}

  def test_images_exist_lazy_and_descriptive
    post_files.each do |fname|
      text = read_file(File.join(POSTS_DIR, fname))
      _, body = parse_front_matter(text)
      alts = []
      body.scan(IMG_RE) do |alt, src|
        ctx = "post #{fname}, image #{src}"
        assert_operator alt.strip.length, :>=, 4,
          "#{ctx}: alt text must be descriptive"
        alts << alt.strip.downcase
        if src.start_with?("/assets/")
          assert File.exist?(File.join(ROOT, src.delete_prefix("/"))),
            "#{ctx}: missing image file"
        end
        line = body.each_line.find { |l| l.include?(src) }
        assert_includes line, 'loading="lazy"',
          "#{ctx}: image should lazy-load"
      end
      assert_equal alts.uniq.length, alts.length,
        "#{fname}: duplicate alt text"
    end
  end
end

class PagesTest < Minitest::Test
  def test_archive
    fm, body = parse_front_matter(read_file(File.join(ROOT, "archive.md")))
    assert_equal "/archive/", fm["permalink"]
    assert_includes body, "group_by_exp"
  end

  def test_search_page
    fm, body = parse_front_matter(read_file(File.join(ROOT, "search.md")))
    assert_equal "/search/", fm["permalink"]
    assert_includes body, "search.json"
    assert_includes body, "search-input"
  end

  def test_search_index
    fm, text = parse_front_matter(read_file(File.join(ROOT, "search.json")))
    # `layout: null` parses to nil in real YAML — which is exactly what
    # Jekyll wants for "no layout".
    assert_nil fm["layout"]
    assert_includes text, "site.posts"
    assert_includes text, "post.description"
  end

  def test_tags_page
    fm, = parse_front_matter(read_file(File.join(ROOT, "tags.html")))
    assert_equal "/tags/", fm["permalink"]
  end

  def test_404_links_home_archive_tags
    text = read_file(File.join(ROOT, "404.html"))
    assert_includes text, '"/" | relative_url'
    assert_includes text, "/archive/"
    assert_includes text, "/tags/"
  end

  def test_home_intro_links
    text = read_file(File.join(ROOT, "index.markdown"))
    %w[/about/ /tags/ /archive/ /search/ /feed.xml].each do |link|
      assert_includes text, link, "home missing link #{link}"
    end
  end

  def test_about_crosslinks
    text = read_file(File.join(ROOT, "about.md"))
    %w[/archive/ /tags/ /projects/ /feed.xml].each do |link|
      assert_includes text, link, "about missing link #{link}"
    end
  end
end

class LayoutsTest < Minitest::Test
  def test_home_prefers_description_over_excerpt
    text = read_file(File.join(ROOT, "_layouts", "home.html"))
    assert_includes text, "post.description"
    assert_includes text, "post.excerpt",
      "home must fall back to excerpt when description missing"
    assert_includes text, "post-list"
    assert_includes text, "rss-subscribe"
  end

  def test_post_layout_nav_related_comments
    text = read_file(File.join(ROOT, "_layouts", "post.html"))
    assert_includes text, "page.previous"
    assert_includes text, "page.next"
    # Jekyll: site.posts is newest-first, so previous == older post,
    # next == newer post. Labels must match that order.
    prev_block = text.split("page.previous")[1].split("endif").first
    assert_includes prev_block, "Older"
    next_block = text.split("page.next")[1].split("endif").first
    assert_includes next_block, "Newer"
    assert_includes text, "Related posts"
    assert_includes text, 'include utterances.html issue-term="pathname"'
    refute_includes text, "prepend: 'Comments:"
  end

  def test_utterances_stable_and_accessible
    text = read_file(File.join(ROOT, "_includes", "utterances.html"))
    assert_includes text, "default: 'pathname'"
    assert_includes text, "<noscript>"
  end

  def test_head_polish
    text = read_file(File.join(ROOT, "_includes", "head.html"))
    assert_includes text, "theme-color"
    assert_includes text, "apple-touch-icon"
  end
end

class LinksTest < Minitest::Test
  def test_post_url_tags_resolve
    slugs = post_files.map { |f| f[0...-3] }.to_set
    pages = %w[projects.md about.md archive.md]
    pages += post_files.map { |f| File.join("_posts", f) }
    if Dir.exist?(DRAFTS_DIR)
      pages += markdown_files(DRAFTS_DIR).map { |f| File.join("_drafts", f) }
    end
    pages.each do |page|
      path = File.join(ROOT, page)
      next unless File.exist?(path)

      read_file(path).scan(/{%\s*post_url\s+(\S+)\s*%}/) do |(slug)|
        slug = File.basename(slug.delete_prefix("'").delete_suffix("'")
          .delete_prefix('"').delete_suffix('"'))
        assert_includes slugs, slug, "#{page}: broken post_url #{slug}"
      end
    end
  end

  def test_no_ds_store
    offenders = []
    search_dirs = Dir.glob(File.join(ROOT, "**")).reject do |d|
      d.include?("/.git/") || d.include?("/vendor/")
    end
    search_dirs.each do |dir|
      next unless File.directory?(dir)

      offenders << dir if File.exist?(File.join(dir, ".DS_Store"))
    end
    assert_empty offenders, ".DS_Store found in: #{offenders.join(', ')}"
    assert_includes read_file(File.join(ROOT, ".gitignore")), ".DS_Store"
  end
end

class LicenseTest < Minitest::Test
  def test_license_gpl_for_code_reserved_for_content
    text = read_file(File.join(ROOT, "LICENSE.md"))
    assert_includes text, "GNU GENERAL PUBLIC LICENSE"
    assert_includes text, "Version 3"
    assert_includes text, "David Budzyński"
    assert_includes text, "code blocks",
      "LICENSE must state that post code examples are GPLv3"
    assert_match(/all rights reserved/i, text)
    refute_includes text, "Creative Commons",
      "content must not carry a CC grant"
    refute_includes text, "Permission is hereby granted",
      "code must not carry the MIT grant"
  end

  def test_footer_shows_rights_notice
    text = read_file(File.join(ROOT, "_includes", "footer.html"))
    assert_includes text, "All rights reserved"
    assert_includes text, "LICENSE"
  end

  def test_readme_points_at_license
    assert_includes read_file(File.join(ROOT, "README.md")), "LICENSE"
  end
end

class DraftsTest < Minitest::Test
  def test_drafts_have_basics
    skip "no _drafts dir" unless Dir.exist?(DRAFTS_DIR)

    files = markdown_files(DRAFTS_DIR)
    refute_empty files, "expected drafts"
    files.each do |fname|
      fm, = parse_front_matter(read_file(File.join(DRAFTS_DIR, fname)))
      assert_equal "post", fm["layout"], "draft #{fname}"
      assert fm["title"] && !fm["title"].to_s.empty?, "draft #{fname}: title required"
      assert_kind_of Array, fm["tags"], "draft #{fname}: tags must be a list"
    end
  end
end
