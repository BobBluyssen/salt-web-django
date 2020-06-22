{% for user, data in pillar.get('users', {}).items() %}
{{user}}:
  user.present:
    - fullname: {{data['fullname']}}
    - password: {{data['password']}}
    - gid: users
    - groups:
      - {{data['group']}}
{% if data['admin'] %}
      - adm
      - sudo
{% endif %}
    - shell: /bin/bash
    - home: /home/{{user}}
{% endfor %}
