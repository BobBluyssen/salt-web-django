{% if pillar.get('allow_password_authentication') %}
ssh_password:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PasswordAuthentication no
    - repl: PasswordAuthentication yes
    - append_if_not_found: True
    - show_changes: True
{% endif %}

{% if pillar.get('allow_root_login') %}
ssh_root:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "#PermitRootLogin prohibit-password"
    - repl: PermitRootLogin yes
    - append_if_not_found: True
    - show_changes: True
{% endif %}

ssh:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/ssh/sshd_config
