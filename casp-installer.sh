HOSTNAME="master"
PROJECTNAME="hyze"
BLUEHTTPPORT="8001"
GREENHTTPPORT="8002"
BLUEHTTPSPORT="8441"
GREENHTTPSPORT="8442"
BLUESSHPORT="8023"
GREENSSHPORT="8024"
reset
echo "======Please provide additional info======"
read -p 'Set hostname for this host: ' HOSTNAME
read -p 'Set project name for new project: ' PROJECTNAME
if [[ -z "$HOSTNAME" ]]; then
HOSTNAME="master"
fi
if [[ -z "$PROJECTNAME" ]]; then
PROJECTNAME="hyze"
fi
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo /etc/init.d/network restart
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -p
sudo hostnamectl set-hostname $HOSTNAME
sudo bash -c "{ hostname --ip-address ; echo $HOSTNAME ; } | sed ':a;N;s/\n/ /;ba' >> /etc/hosts"
sudo yum -y update
sudo yum -y install nano wget curl net-tools lsof bash-completion yum-utils device-mapper-persistent-data lvm2 docker epel-release python-pip nginx git
sudo yum upgrade python*
sudo pip install docker-compose
sudo systemctl enable docker && sudo systemctl start docker
sudo systemctl enable nginx && sudo systemctl start nginx
sudo mkdir -p /data/projects/$PROJECTNAME/scripts
sudo chmod 777 /data/projects/$PROJECTNAME/scripts
sleep 1
sudo git clone --recursive https://github.com/takezie/docker-recipes.git /data/projects/$PROJECTNAME/$PROJECTNAME-blue
sudo git clone --recursive https://github.com/takezie/docker-recipes.git /data/projects/$PROJECTNAME/$PROJECTNAME-green
sudo sed -i --follow-symlinks "s/"8000:80"/"$BLUEHTTPPORT:80"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-blue/docker-compose.yml
sudo sed -i --follow-symlinks "s/"8443:443"/"$BLUEHTTPSPORT:443"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-blue/docker-compose.yml
sudo sed -i --follow-symlinks "s/"10022:22"/"$BLUESSHPORT:22"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-blue/docker-compose.yml
sudo sed -i --follow-symlinks "s/"8000:80"/"$GREENHTTPPORT:80"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-green/docker-compose.yml
sudo sed -i --follow-symlinks "s/"8443:443"/"$GREENHTTPSPORT:443"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-green/docker-compose.yml
sudo sed -i --follow-symlinks "s/"10022:22"/"$GREENSSHPORT:22"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-green/docker-compose.yml
cd /data/projects/$PROJECTNAME/$PROJECTNAME-green/ && sudo docker-compose build && sudo docker-compose up -d && echo -e "\e[92mStarted GREEN things up\e[0m"'!'
cd /data/projects/$PROJECTNAME/$PROJECTNAME-blue/ && sudo docker-compose build && sudo docker-compose up -d && echo -e "\e[94mStarted BLUE things up\e[0m"'!'
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx-blue.conf
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx-green.conf
sudo sed -i "48iproxy_read_timeout 180;" /etc/nginx/nginx-blue.conf
sudo sed -i "48iproxy_send_timeout 120;" /etc/nginx/nginx-blue.conf
sudo sed -i "48iproxy_connect_timeout 120;" /etc/nginx/nginx-blue.conf
sudo sed -i "48iproxy_pass http://$HOSTNAME:$BLUEHTTPPORT;" /etc/nginx/nginx-blue.conf
sudo sed -i "48iproxy_read_timeout 180;" /etc/nginx/nginx-green.conf
sudo sed -i "48iproxy_send_timeout 120;" /etc/nginx/nginx-green.conf
sudo sed -i "48iproxy_connect_timeout 120;" /etc/nginx/nginx-green.conf
sudo sed -i "48iproxy_pass http://$HOSTNAME:$GREENHTTPPORT;" /etc/nginx/nginx-green.conf
sudo cp /etc/nginx/nginx-blue.conf /etc/nginx/nginx.conf
sudo rm -rf /data/projects/$PROJECTNAME/$PROJECTNAME-blue/app
sudo rm -rf /data/projects/$PROJECTNAME/$PROJECTNAME-green/app
sudo git clone --recursive https://github.com/jrgp/linfo.git /data/projects/$PROJECTNAME/$PROJECTNAME-blue/app/
sudo git clone --recursive https://github.com/jrgp/linfo.git /data/projects/$PROJECTNAME/$PROJECTNAME-green/app/
sudo chmod -R 755 /data/projects/$PROJECTNAME/$PROJECTNAME-blue/app
sudo chmod -R 755 /data/projects/$PROJECTNAME/$PROJECTNAME-green/app
sudo mv /data/projects/$PROJECTNAME/$PROJECTNAME-blue/app/sample.config.inc.php /data/projects/$PROJECTNAME/$PROJECTNAME-blue/app/config.inc.php
sudo mv /data/projects/$PROJECTNAME/$PROJECTNAME-green/app/sample.config.inc.php /data/projects/$PROJECTNAME/$PROJECTNAME-green/app/config.inc.php
sudo sed -i --follow-symlinks "s/"4a8fd6"/"4ad64a"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-green/app/layout/theme_default.css
sudo sed -i --follow-symlinks "s/"5c9ada"/"5cda5c"/g" /data/projects/$PROJECTNAME/$PROJECTNAME-green/app/layout/theme_default.css
sudo echo "cd /etc/nginx/" > /data/projects/$PROJECTNAME/scripts/go-green.sh
sudo echo "yes | cp  nginx-green.conf nginx.conf" >> /data/projects/$PROJECTNAME/scripts/go-green.sh
sudo echo "service restart nginx" >> /data/projects/$PROJECTNAME/scripts/go-green.sh
sudo chmod +x /data/projects/$PROJECTNAME/scripts/go-green.sh
sudo echo "cd /etc/nginx/" > /data/projects/$PROJECTNAME/scripts/go-blue.sh
sudo echo "yes | cp  nginx-green.conf nginx.conf" >> /data/projects/$PROJECTNAME/scripts/go-blue.sh
sudo echo "service restart nginx" >> /data/projects/$PROJECTNAME/scripts/go-blue.sh
sudo chmod +x /data/projects/$PROJECTNAME/scripts/go-blue.sh
sudo chmod 755 /data/projects/$PROJECTNAME/scripts
sudo service nginx restart
cd /data/projects/$PROJECTNAME/$PROJECTNAME-green/ && sudo docker-compose restart
cd /data/projects/$PROJECTNAME/$PROJECTNAME-blue/ && sudo docker-compose restart
