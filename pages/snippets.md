---
layout: page
title: Snippets
permalink: /snippets/
---

# Snippets

Here you can quickly jump to a particular snippet page.

<div class="section-index">
    <hr class="panel-line">
    {% for post in site.snippets  %}        
    <div class="entry">
    <h5><a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a></h5>
    <p>{{ post.description }}</p>
    </div>{% endfor %}
</div>
