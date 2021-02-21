---
layout: page
title: Snippets
permalink: /snippets/
---

# Snippets

Here you can quickly jump to a particular snippet page.

{% assign all_categories = site.snippets | map: "tags" | uniq %}

<div class="section-index">
    {% for category in all_categories %}
        <h3 id="{{category}}">{{category}}</h3>
        <hr class="panel-line">
        {% assign posts_in_category = site.snippets | where: "tags", category %}
        {% for post in posts_in_category  %}
            <div class="entry">
            <h5><a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a></h5>
            <p>{{ post.description }}</p>
            </div>
        {% endfor %}
    {% endfor %}
</div>
