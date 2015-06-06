#!/bin/bash
### To load Server Density agent on a server
###  This is a full install if name of instance is known.  The example below must be executed from a "Gateway" instance
### ssh -vvv username@supervisor-02.blue.process.prod -t "sudo ./agent-install.sh -a https://tvdev.serverdensity.io -t 26917a96eb2b83e16e325d458fe06fb0 -g \ 
### Supervisor -T "supervisor-02.blue.process.prod"; sudo sed -i '/^plugin_directory:/ s/$/ \/usr\/bin\/sd-agent\/plugins/' /etc/sd-agent/config.cfg; \
### sudo service sd-agent restart"
###
### This is the generic install without tag or group info that will require internet access.  It also assumes sudo privileges.
## THis will download the agent install script
sudo curl -LO https://www.serverdensity.com/downloads/agent-install.sh

## Change to execute mode
sudo chmod +x agent-install.sh

## This will query AWS to acquire the Instance Id which will be used in the 'Tag" info to identify the instance
id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
key=$(aws ec2 describe-tags --region us-east-1 --filters Name=resource-id,Values=$id Name=key,Values=layer |grep Value |sed -r 's/"//g';s/,//g ;s/Value://g')

## This will install the agent and add it the the Server Density server list using the hostname.  The " -G " is for Group and will use result of the query on the tag key value to
## add it to the correct group

sudo ./agent-install.sh -a https://tvdev.serverdensity.io -t 26917a96eb2b83e16e325d458fe06fb0 -G $key -T $id

## This will create the directory needed to add plugins
sudo mkdir -p /usr/bin/sd-agent/plugins

## This will update the config with the location of the plugin directory
sudo sed -i '/^plugin_directory:/ s/$/ \/usr\/bin\/sd-agent\/plugins/' /etc/sd-agent/config.cfg

## Update changes
sudo service sd-agent 
