######
# Dockerize Minecraft Forge Server
######

FROM ubuntu:16.04

RUN apt-get update && apt-get -y install apt-utils && apt-get -y dist-upgrade
RUN apt-get -y install software-properties-common vim curl screen rsync zip
RUN add-apt-repository ppa:webupd8team/java && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && apt-get -y install oracle-java8-installer

#RUN wget -q http://git.io/Sxpr9g -O /tmp/msm
# Copy MSM conf file to /etc
# TODO: convert to template for 
COPY ./etc/msm.conf /etc/msm.conf
# Setup the Minecraft user
RUN mkdir /opt/msm && useradd minecraft --home /opt/msm && chown minecraft /opt/msm && chmod -R 775 /opt/msm
# Create RAMDISK
RUN mkdir /dev/shm/msm && chown minecraft /dev/shm/msm && chmod -R 775 /dev/shm/msm
# Fetch the MSM script
RUN wget http://git.io/J1GAxA -O /etc/init.d/msm
# Make script executable, enable autorun, place in path to also use as command
RUN chmod 755 /etc/init.d/msm && update-rc.d msm defaults 99 10 && ln -s /etc/init.d/msm /usr/local/bin/msm
# Test MSM by updating
RUN msm update --noinput
# Install and enable MSM cron tasks
# TODO: Bring into package so we can update these as needed
RUN wget http://git.io/pczolg -O /etc/cron.d/msm && service cron reload
# Create jargroup to hold Minecraft server jars
RUN msm jargroup create minecraft minecraft
# Create default server - 'forgesrv'
# TODO: move this into a script so we can template
RUN msm server create forgesrv && msm forgesrv jar minecraft
RUN msm forgesrv config msm-version minecraft/1.12.1
# Copy eula file to server directory
COPY ./forgesrv/eula.txt /opt/msm/servers/forgesrv/

EXPOSE 25565
