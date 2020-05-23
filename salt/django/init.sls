python3:
  pkg.installed

python-pip:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python-pip
    - require:
      - python3  

django:
  pip.installed:
    - name: django
    - bin_env: '/usr/bin/pip3'
    - require:
      - python-pip
