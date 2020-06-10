install apache2:
  pkg.installed:
    - name: apache2

apache2:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: apache2

000-default.conf:
  apache_site.disabled:
    - require:
      - pkg: apache2

default.conf:
  apache_site.disabled:
    - require:
      - pkg: apache2

{% for domain, data in pillar.get('domains', {}).items() %}
/etc/apache2/sites-available/{{domain}}.conf:
  apache.configfile:
    - config:
      - Directory:
        - this: {{data['project_root']}}
        - Order: Deny,Allow
        - Allow from: all
      - Directory:
        - this: {{data['project_root']}}/settings
        - Files:
          - this: wsgi.py
          - Require: all granted
      - Directory:
        - this: {{data['project_root']}}/static
        - Require: all granted
      - VirtualHost:
        - this: '*:80'
        - ServerName:
          - {{domain}}
        - Alias:
          - /static/ {{data['project_root']}}/static/
        - WSGIScriptAlias:
          - / {{data['project_root']}}/settings/wsgi.py
        - DocumentRoot: {{data['project_root']}}
    - listen_in:
      - service: apache2

apache2-wsgi-{{domain}}:
  file.append:
    - name: /etc/apache2/apache2.conf
    - text:
      - WSGIPythonPath {{data['project_root']}}

Enable {{domain}} site:
  apache_site.enabled:
    - name: {{domain}}

{% endfor %}

