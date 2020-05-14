# salt-web-django
Basic salt setup for configuring a Ubuntu webserver with apache, mysql and Django

## Install salt
You can choose to run salt with a master or masterless.

### master
```curl -L https://bootstrap.saltstack.com -o install_salt.sh```  
```sudo sh install_salt.sh -M -i [MASTER ID]```
(Notice -M for master)

### minion
```curl -L https://bootstrap.saltstack.com -o install_salt.sh```  
```sudo sh install_salt.sh -A [MASTER ID] -i [MINION ID]``` 

### minion masterless
```curl -L https://bootstrap.saltstack.com -o install_salt.sh```  
```sudo sh install_salt.sh -i [MINION ID]``` 
