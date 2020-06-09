python3:
  pkg.installed

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
{% if not salt['file.directory_exists'](data['project_root']) %}
create_django_project_{{domain}}:
  cmd.run:
    - group: {{data['group']}}
    - name: django-admin startproject settings
    - cwd: {{data['django_path']}}
    - require:
      - django

chown_django_project_{{domain}}:
  cmd.run:
    - name: chown -R {{data['user']}}:{{data['group']}} {{data['django_path']}}

rename_project_dir_{{domain}}:
  cmd.run:
    - runas: {{data['user']}}
    - group: {{data['group']}}
    - name: mv settings {{data['project_root']}}
    - cwd: {{data['django_path']}}

collectstatic_{{domain}}:
  module.wait:
    - name: django.collectstatic
    - settings_module: settings.settings
    - pythonpath: {{data['project_root']}}
    - watch:
      - add_local_settings_{{domain}}

createsuperuser_{{domain}}:
  module.run:
    - name: django.createsuperuser
    - username: {{data['user']}}
    - email: {{data['email']}}
    - settings_module: settings.settings
    - pythonpath: {{data['project_root']}}

{% endif %}

append_settings_{{domain}}:
  file.append:
    - name: {{data['project_root']}}/settings/settings.py
    - text:
      - from settings.local_settings import *

{% set allowed_hosts = [] %}
{% for domain, data in pillar.get('domains', {}).items() %}
{% set _ = allowed_hosts.append("'"+domain+"'") %}
{% set _ = allowed_hosts.append("'www."+domain+"'") %}
{% endfor %}

add_local_settings_{{domain}}:
  file.managed:
    - name: {{data['project_root']}}/settings/local_settings.py
    - user: {{data['user']}}
    - group: {{data['group']}}
    - template: jinja
    - contents: |
        DEBUG = {{data['debug']}}
        ALLOWED_HOSTS = [{{ allowed_hosts|join(', ') }}]
        STATIC_ROOT = "{{data['project_root']}}/static/"
    - require:
      - append_settings_{{domain}}
    - listen_in:
      - service: apache2

change_wsgi_{{domain}}:
  file.replace:
    - name: {{data['project_root']}}/settings/wsgi.py
    - pattern: settings.settings
    - repl: settings.settings

{% endfor %}
