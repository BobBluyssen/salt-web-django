# Users
users:
  bob:
    fullname: Bob
    email: example@example.com
    password: secret_passowrd # (encrypt password with: mkpasswd -m sha-256 YourPassword)
    group: users
    admin: True

# SSH settings (used in sshd_config)
allow_password_authentication: True
allow_root_login: True

# Domains (used in Apache and MYSQL config)
domains:
  example.com: # used in Apache as domain
    user: bob
    project_name: example_project
    django_path: /var/www/
    debug: False
    mysql_password: 'secret_password'
    mysql_password_hash: 'secret_password' # Generate mysql password https://www.browserling.com/tools/mysql-password
  dev.example.com:
    user: bob
    project_name: dev_example_project
    django_path: /home/bob/
    debug: True
    mysql_password: 'secret_password'
    mysql_password_hash: 'secret_password' # Generate mysql password https://www.browserling.com/tools/mysql-password

# Mysql settings
root_user: 'root'
root_mysql_password: 'secret_password' # Generate mysql password https://www.browserling.com/tools/mysql-password
