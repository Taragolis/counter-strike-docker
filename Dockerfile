FROM debian:jessie

LABEL maintainer "Artem Panchenko <kazar.artem@gmail.com>"

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y lib32gcc1 curl

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 10 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd

# Install metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls
RUN curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -

# Install dproto
RUN mkdir -p /opt/hlds/cstrike/addons/dproto

# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -

# Cleanup
RUN apt-get remove -y curl apt-utils && \
    apt-get -y autoremove

# Add Metamod lib
ADD files/metamod/liblist.gam /opt/hlds/cstrike/liblist.gam

# Add dproto lib
ADD files/dproto/dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so

# Metamod conf
ADD files/metamod/cfg/plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Add default config
ADD files/general/cfg/steam_appid.txt /opt/hlds/steam_appid.txt
ADD files/general/cfg/server.cfg /opt/hlds/cstrike/server.cfg

# AMX mod X configurations
ADD files/amx/cfg/* /opt/hlds/cstrike/addons/amxmodx/configs/

# dproto configuration
ADD files/dproto/cfg/dproto.cfg /opt/hlds/cstrike/dproto.cfg

# Add maps
ADD files/maps/*.bsp /opt/hlds/cstrike/maps/
ADD files/maps/cfg/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt
ADD files/maps/cfg/mapcycle.txt /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini

# Add Execution script
ADD files/general/hlds_run.sh /bin/hlds_run.sh

WORKDIR /opt/hlds
VOLUME ["/opt/hlds/cstrike/addons/amxmodx/data"]
ENTRYPOINT ["/bin/hlds_run.sh"]
