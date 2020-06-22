mysql-install:
  pkg.installed:
    - pkgs:
      - mysql-server
      - libmysqlclient-dev
      - default-libmysqlclient-dev
      - python3-mysqldb
      - python-mysqldb
      - phpmyadmin
    - require:
      - python3

phpmyadmin-append:
  file.append:
    - name: /etc/apache2/apache2.conf
    - text:
      - Include /etc/phpmyadmin/apache.conf

mysql-python:
  pip.installed:
    - name: mysqlclient
    - require:
      - mysql-install

mysql:
  pkg.installed:
    - name: mysql-server
    - service:
      - running

salt-mysql-settings:
  file.append:
    - name: /etc/salt/minion
    - text: "mysql.default_file: /etc/mysql/debian.cnf"

{% for domain, data in pillar.get('domains', {}).items() %}
mysql-database-{{domain}}:
  mysql_database.present:
    - name: {{domain}}
  mysql_user.present:
    - name: {{data['user']}}
    - password_hash: '{{pillar.get('users')[data['user']]['mysql_password']}}'
  mysql_grants.present:
    - database: {{domain}}.*
    - grant: ALL PRIVILEGES
    - user: {{data['user']}}
  require:
    - pkg: python-mysqldb
{% endfor %}

mysql-user-root:
  mysql_user.present:
    - name: root
    - password_hash: '{{pillar.get('RootMysqlPassword', "")}}'
  mysql_grants.present:
    - database: '*'
    - grant: ALL PRIVILEGES
    - user: root
  require:
    - pkg: python-mysqldb
