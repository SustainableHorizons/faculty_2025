---
layout: default
title: SHI Collaboration Profiles
---

## Our Collaborators

<div class="profiles-grid">
{% assign profiles_sorted = site.profiles | sort: 'name' %}
{% for profile in profiles_sorted %}
  <div class="profile-card">
    {% if profile.photo %}
      <img src="{{ '/assets/faculty_pictures/' | append: profile.photo | relative_url }}" alt="{{ profile.name }}" class="profile-card-image">
    {% else %}
      <div class="profile-card-image-placeholder">
        <span>{{ profile.name | slice: 0 | upcase }}</span>
      </div>
    {% endif %}
    
    <div class="profile-card-content">
      <h3><a href="{{ profile.url | relative_url }}">{{ profile.name }}</a></h3>
      {% if profile.academic_status %}
        <p class="profile-card-title">{{ profile.academic_status }}</p>
      {% endif %}
      {% if profile.institution %}
        <p class="profile-card-org">{{ profile.institution }}</p>
      {% endif %}
      {% if profile.biography %}
        <p class="profile-card-bio">{{ profile.biography | truncate: 120 }}</p>
      {% endif %}
      
      <div class="profile-card-links">
        {% if profile.email %}
          <a href="mailto:{{ profile.email }}" title="Email {{ profile.name }}">📧</a>
        {% endif %}
        {% if profile.linkedin and profile.linkedin != "" %}
          <a href="{{ profile.linkedin }}" target="_blank" title="LinkedIn Profile">💼</a>
        {% endif %}
        {% if profile.website and profile.website != "" %}
          <a href="{{ profile.website }}" target="_blank" title="Personal Website">🌐</a>
        {% endif %}
      </div>
    </div>
  </div>
{% endfor %}
</div>
