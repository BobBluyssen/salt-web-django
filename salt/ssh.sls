{% if pillar.get('AllowPasswordAuthentication') %}
ssh_password:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PasswordAuthentication no
    - repl: PasswordAuthentication yes
    - append_if_not_found: True
    - show_changes: True
{% endif %}

{% if pillar.get('AllowRootLogin') %}
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
