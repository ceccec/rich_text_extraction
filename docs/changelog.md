---
layout: default
title: Changelog
nav_order: 99
---

# Changelog

<div class="whats-new-banner">
  🚀 <strong>What's New:</strong>
  {% assign latest = site.categories.changelog | first %}
  {% if latest %}
    <a href="{{ latest.url }}">{{ latest.title }}</a>
    <span style="color: #888;">({{ latest.date | date: "%Y-%m-%d" }})</span>
  {% endif %}
  &nbsp;|&nbsp; <a href="https://github.com/ceccec/rich_text_extraction/releases">GitHub Releases</a>
</div>

{% assign tags = site.categories.changelog | map: 'tags' | join: ',' | split: ',' | uniq | sort %}
{% assign tags = tags | reject: '' %}
{% if tags.size > 0 %}
<div id="changelog-filter-bar">
  <strong>Filter by tag:</strong>
  <button class="changelog-tag" data-tag="all">All</button>
  {% for tag in tags %}
    <button class="changelog-tag {{ tag | downcase }}" data-tag="{{ tag | strip }}">{{ tag | strip }}</button>
  {% endfor %}
</div>
{% endif %}

<ul id="changelog-list" style="list-style: none; padding-left: 0;">
{% assign last_year = nil %}
{% for post in site.categories.changelog %}
  {% assign year = post.date | date: "%Y" %}
  {% if year != last_year %}
    <li style="margin-top: 1.5em;"><h2>{{ year }}</h2></li>
    {% assign last_year = year %}
  {% endif %}
  <li class="changelog-entry" data-tags="{{ post.tags | join: ' ' }}" style="margin-bottom: 0.5em;">
    <a href="{{ post.url }}"><strong>{{ post.title }}</strong></a>
    <span style="color: #888;">({{ post.date | date: "%Y-%m-%d" }})</span>
    {% if post.tags %}
      <span>
        {% for tag in post.tags %}
          <span class="changelog-tag {{ tag | downcase }}">{{ tag }}</span>
        {% endfor %}
      </span>
    {% endif %}
  </li>
{% endfor %}
</ul>

<script>
document.addEventListener('DOMContentLoaded', function() {
  var filterBar = document.getElementById('changelog-filter-bar');
  if (!filterBar) return;
  var entries = document.querySelectorAll('.changelog-entry');
  filterBar.addEventListener('click', function(e) {
    if (e.target.tagName !== 'BUTTON') return;
    var tag = e.target.getAttribute('data-tag');
    entries.forEach(function(entry) {
      if (tag === 'all' || entry.getAttribute('data-tags').includes(tag)) {
        entry.style.display = '';
      } else {
        entry.style.display = 'none';
      }
    });
  });
});
</script>

<p style="margin-top:2em;">Or browse all <a href="_posts/">changelog posts</a>.</p> 