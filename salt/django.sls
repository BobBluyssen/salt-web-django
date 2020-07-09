python3:
  pkg.installed:
    - pkgs:
      - python3
      - python3-dev

python-pip:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python-pip
    - require:
      - python3

mod-wsgi:
  pkg.installed:
    - pkgs:
      - libapache2-mod-wsgi-py3
    - require:
      - apache2

django:
  pip.installed:
    - name: django
    - bin_env: '/usr/bin/pip3'
    - require:
      - python-pip

{% for domain, data in pillar.get('domains', {}).items() %}

{% set project_root = data['django_path'] ~ data['project_name'] %}
{% if not salt['file.directory_exists'](project_root) %}

{% set user = data['user']  %}
{% set group = pillar.get('users')[user]['group'] %}
{% set email = pillar.get('users')[user]['email'] %}

create_django_project_{{ domain }}:
  cmd.run:
    - group: {{ group }}
    - name: django-admin startproject settings
    - cwd: {{ data['django_path'] }}
    - require:
      - django

chown_django_project_{{ domain }}:
  cmd.run:
    - name: chown -R {{ user }}: {{ data['django_path'] }}

rename_project_dir_{{ domain }}:
  cmd.run:
    - runas: {{ user }}
    - group: {{ group }}
    - name: mv settings {{ project_root }}
    - cwd: {{ data['django_path'] }}

collectstatic_{{domain}}:
  module.wait:
    - name: django.collectstatic
    - settings_module: settings.settings
    - pythonpath: {{project_root}}
    - watch:
      - add_local_settings_{{ domain }}

createsuperuser_{{domain}}:
  module.run:
    - name: django.createsuperuser
    - username: {{ user }}
    - email: {{ email }}
    - settings_module: settings.settings
    - pythonpath: {{ project_root }}

{% endif %}

append_settings_{{domain}}:
  file.append:
    - name: {{ project_root }}/settings/settings.py
    - text:
      - from settings.local_settings import *

{% set allowed_hosts = [] %}
{% for domain, data in pillar.get('domains', {}).items() %}
{% set _ = allowed_hosts.append("'"+domain+"'") %}
{% set _ = allowed_hosts.append("'www."+domain+"'") %}
{% endfor %}

# Weird bug in Jinja; vars no longer available after loop:
{% set user = data['user']  %}
{% set group = pillar.get('users')[user]['group'] %}

add_local_settings_{{ domain }}:
  file.managed:
    - name: {{ project_root }}/settings/local_settings.py
    - user: {{ user }}
    - group: {{ group }}
    - template: jinja
    - contents: |
        DEBUG = {{ data['debug'] }}
        ALLOWED_HOSTS = [{{ allowed_hosts|join(', ') }}]
        STATIC_ROOT = "{{ project_root }}/static/"
        DATABASES = {
          'default': {
              'ENGINE': 'django.db.backends.mysql',
              'NAME': '{{ domain }}',
              'USER' : '{{ data['project_name'] }}',
              'PASSWORD' : '{{ data['mysql_password'] }}',
              'HOST' : 'localhost',
          },
        }
    - require:
      - append_settings_{{ domain }}
    - listen_in:
      - service: apache2

change_wsgi_{{ domain }}:
  file.replace:
    - name: {{ project_root }}/settings/wsgi.py
    - pattern: settings.settings
    - repl: settings.settings

migrate_database_{{ domain }}:
  module.run:
    - name: django.migrate
    - settings_module: settings.settings
    - pythonpath: {{ project_root }}

create_superuser{{ domain }}:
  module.run:
    - name: django.createsuperuser
    - settings_module: settings.settings
    - pythonpath: {{ project_root }}
    - username: {{ user }}
    - email: {{ pillar.get('users')[user]['email'] }}

{% endfor %}
