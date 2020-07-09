# salt-web-django
Basic salt setup for configuring a Ubuntu webserver with apache, mysql and Django.

## Prerequisite
- To use the instructions below i installed a clean Ubuntu 18.04
- Execute all commands as root ```sudo su```  

## Install salt
First download bootstrap-salt:  
```wget -O bootstrap-salt.sh https://bootstrap.saltstack.com```  
You can choose to run salt with master and minion or masterless.

### Master
```sh bootstrap-salt.sh -M -i [MASTER ID]```  
(Notice -M for master)

### Minion  
```sh bootstrap-salt.sh -A [MASTER ID] -i [MINION ID]```

### Masterless minion
```sh bootstrap-salt.sh -i [MINION ID]```

Edit minion config to search for setup files locally
```vi /etc/salt/minion```
Change and uncomment:
```yaml
#file_client: remote
```
To:
```yaml
file_client: local
```

## Git clone all setup files to /srv/
The bootstrap-salt setup created the /srv/ dir. You can clone this repo or make your own setup files.  
```apt install git``` (if not installed)  
```cd /srv/```  
```git clone https://github.com/BobBluyssen/salt-web-django.git .```  

### Masterless minion
Copy the settings_example.conf to create your own settings
```cp /srv/pillar/settings_example.sls /srv/pillar/settings.sls```  
```vi /srv/pillar/settings.sls```  

Change al capitalised settings to your own
```settings:```

Then:
```salt-call state.apply```

TODO:  
add .vimrc, .bashrc and private_key  
