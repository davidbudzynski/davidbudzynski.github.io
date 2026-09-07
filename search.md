---
layout: page
title: Search
permalink: /search/
description: "Search posts by title, tag, or description."
---

<input type="search" id="search-input" placeholder="Type to filter posts…" aria-label="Search posts" style="width: 100%; padding: 0.5em;" />

<ul id="search-results"></ul>
<p id="search-count" aria-live="polite"></p>

<script>
(function () {
  var input = document.getElementById('search-input');
  var results = document.getElementById('search-results');
  var count = document.getElementById('search-count');
  var posts = [];

  function render(query) {
    var q = query.trim().toLowerCase();
    results.innerHTML = '';
    if (!q) {
      count.textContent = posts.length + ' posts. Start typing to filter.';
      return;
    }
    var matches = posts.filter(function (p) {
      return (p.title + ' ' + p.tags.join(' ') + ' ' + p.description)
        .toLowerCase().indexOf(q) !== -1;
    });
    count.textContent = matches.length + ' match' + (matches.length === 1 ? '' : 'es') + '.';
    matches.slice(0, 30).forEach(function (p) {
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.href = p.url;
      a.textContent = p.title;
      li.appendChild(a);
      var span = document.createElement('span');
      span.textContent = ' — ' + p.date;
      li.appendChild(span);
      results.appendChild(li);
    });
  }

  fetch('{{ "/search.json" | relative_url }}')
    .then(function (r) { return r.json(); })
    .then(function (data) {
      posts = data;
      render('');
    })
    .catch(function () {
      count.textContent = 'Search index could not be loaded.';
    });

  input.addEventListener('input', function () { render(input.value); });
})();
</script>
