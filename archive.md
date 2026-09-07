---
layout: page
title: Archive
permalink: /archive/
description: "All posts by year."
---

All posts, newest first. See also [Tags](/tags/).

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}
## {{ year.name }}

<ul>
  {% for post in year.items %}
  <li>
    <span>{{ post.date | date: "%b %-d" }}</span> —
    <a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
  </li>
  {% endfor %}
</ul>
{% endfor %}
