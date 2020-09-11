# docker images installed

## CyberChef
### start
sudo docker run -d -p 8080:8080 remnux/cyberchef

## Covenant 127.0.0.1:7443
### start first time
sudo docker run -it -p 7443:7443 -p 80:80 -p 443:443 --name covenant -v /tools/Covenant/Covenant/Data:/app/Data covenant:covenant
### restart with Data
sudo docker start covenant -ai
### restart fresh, remove old Data
sudo docker rm covenant
sudo docker run -it -p 7443:7443 -p 80:80 -p 443:443 --name covenant -v /tools/Covenant/Covenant/Data:/app/Data covenant:covenant --username AdminUser --computername 0.0.0.0

## jsdetox
### start
sudo docker run -d --rm --name jsdetox -p 3000:3000 remnux/jsdetox
### stop
sudo docker stop jsdetox

