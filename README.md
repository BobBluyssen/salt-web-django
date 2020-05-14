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

### Minion masterless 
```sh bootstrap-salt.sh -i [MINION ID]```

## Git clone all setup files to /srv/
The bootstrap-salt setup created the /srv/ dir. You can clone this repo or make your own setup files.  
```apt install git``` (if not installed)  
```cd /srv/```  
```git clone https://github.com/BobBluyssen/salt-web-django.git .```  

