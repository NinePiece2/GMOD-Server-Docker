#!/bin/sh

# Update Garry's Mod
${STEAMCMDDIR}/steamcmd.sh +login anonymous \
    +force_install_dir ${GMODDIR} +app_update ${GMODID} validate +quit

# Update other game content
${STEAMCMDDIR}/steamcmd.sh +login anonymous \
    +force_install_dir ${CSSDIR} +app_update ${CSSID} validate +quit
${STEAMCMDDIR}/steamcmd.sh +login anonymous \
    +force_install_dir ${TF2DIR} +app_update ${TF2ID} validate +quit



# Edit server config file
touch ${SERVERCFG}
if [ ! -z "${HOSTNAME}" ]
then
    if grep -q 'hostname' ${SERVERCFG}
    then
        sed -i 's`hostname.*`hostname "'"${HOSTNAME}"'"`' ${SERVERCFG}
    else
        echo "hostname \"${HOSTNAME}\"" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${ALLTALK}" ]
then
    if grep -q 'sv_alltalk' ${SERVERCFG}
    then
        sed -i 's`sv_alltalk.*`sv_alltalk '${ALLTALK}'`' ${SERVERCFG}
    else
        echo "sv_alltalk ${ALLTALK}" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${VOICEICON}" ]
then
    if grep -q 'mp_show_voice_icons' ${SERVERCFG}
    then
        sed -i 's`mp_show_voice_icons.*`mp_show_voice_icons '${VOICEICON}'`' ${SERVERCFG}
    else
        echo "mp_show_voice_icons ${VOICEICON}" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${MAXFILESIZE}" ]
then
    if grep -q 'net_maxfilesize' ${SERVERCFG}
    then
        sed -i 's`net_maxfilesize.*`net_maxfilesize '${MAXFILESIZE}'`' ${SERVERCFG}
    else
        echo "net_maxfilesize ${MAXFILESIZE}" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${DOWNLOADURL}" ]
then
    if grep -q 'sv_downloadurl' ${SERVERCFG}
    then
        sed -i 's`sv_downloadurl.*`sv_downloadurl "'"${DOWNLOADURL}"'"`' ${SERVERCFG}
    else
        echo "sv_downloadurl \"${DOWNLOADURL}\"" >> ${SERVERCFG}
    fi
    if grep -q 'sv_allowdownload' ${SERVERCFG}
    then
        sed -i 's`sv_allowdownload.*`sv_allowdownload 1`' ${SERVERCFG}
    else
        echo "sv_allowdownload 1" >> ${SERVERCFG}
    fi
    if grep -q 'sv_allowupload' ${SERVERCFG}
    then
        sed -i 's`sv_allowupload.*`sv_allowupload 1`' ${SERVERCFG}
    else
        echo "sv_allowupload 1" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${LOADINGURL}" ]
then
    if grep -q 'sv_loadingurl' ${SERVERCFG}
    then
        sed -i 's`sv_loadingurl.*`sv_loadingurl "'"${LOADINGURL}"'"`' ${SERVERCFG}
    else
        echo "sv_loadingurl \"${LOADINGURL}\"" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${PASSWORD}" ]
then
    if grep -q 'sv_password' ${SERVERCFG}
    then
        sed -i 's`sv_password.*`sv_password "'"${PASSWORD}"'"`' ${SERVERCFG}
    else
        echo "sv_password \"${PASSWORD}\"" >> ${SERVERCFG}
    fi
fi
if [ ! -z "${RCONPASSWORD}" ]
then
    if grep -q 'rcon_password' ${SERVERCFG}
    then
        sed -i 's`rcon_password.*`rcon_password "'"${RCONPASSWORD}"'"`' ${SERVERCFG}
    else
        echo "rcon_password \"${RCONPASSWORD}\"" >> ${SERVERCFG}
    fi
fi
if ! grep -q 'exec banned_ip.cfg' ${SERVERCFG}
then
    echo "exec banned_ip.cfg" >> ${SERVERCFG}
fi
if ! grep -q 'exec banned_user.cfg' ${SERVERCFG}
then
    echo "exec banned_user.cfg" >> ${SERVERCFG}
fi

# Start the server
if [ -z "${GMODPORT}" ]
then
    GMODPORT=27015
fi
if [ -z "${CLIENTPORT}" ]
then
    CLIENTPORT=27005
fi
if [ -z "${MAXPLAYERS}" ]
then
    MAXPLAYERS=20
fi
if [ -z "${GAMEMODE}" ]
then
    GAMEMODE=sandbox
fi
if [ -z "${GAMEMAP}" ]
then
    GAMEMAP=gm_flatgrass
fi
if [ -z "${WORKSHOPID}" ]
then
    if [ -z "${LOGINTOKEN}" ]
    then
        exec ${GMODDIR}/srcds_run \
            -autoupdate \
            -steam_dir ${STEAMCMDDIR} \
            -steamcmd_script /home/steam/autoupdatescript.txt \
            -port ${GMODPORT} \
            -clientport ${CLIENTPORT} \
            -maxplayers ${MAXPLAYERS} \
            -game garrysmod \
            +gamemode ${GAMEMODE} \
            +map ${GAMEMAP}
    else
        exec ${GMODDIR}/srcds_run \
            -autoupdate \
            -steam_dir ${STEAMCMDDIR} \
            -steamcmd_script /home/steam/autoupdatescript.txt \
            -port ${GMODPORT} \
            -clientport ${CLIENTPORT} \
            -maxplayers ${MAXPLAYERS} \
            -game garrysmod \
            +sv_setsteamaccount ${LOGINTOKEN} \
            +gamemode ${GAMEMODE} \
            +map ${GAMEMAP}
    fi
else
    if [ -z "${LOGINTOKEN}" ]
    then
        exec ${GMODDIR}/srcds_run \
            -autoupdate \
            -steam_dir ${STEAMCMDDIR} \
            -steamcmd_script /home/steam/autoupdatescript.txt \
            -port ${GMODPORT} \
            -clientport ${CLIENTPORT} \
            -maxplayers ${MAXPLAYERS} \
            -game garrysmod \
            +host_workshop_collection ${WORKSHOPID} \
            +gamemode ${GAMEMODE} \
            +map ${GAMEMAP}
    else
        exec ${GMODDIR}/srcds_run \
            -autoupdate \
            -steam_dir ${STEAMCMDDIR} \
            -steamcmd_script /home/steam/autoupdatescript.txt \
            -port ${GMODPORT} \
            -clientport ${CLIENTPORT} \
            -maxplayers ${MAXPLAYERS} \
            -game garrysmod \
            +sv_setsteamaccount ${LOGINTOKEN} \
            +host_workshop_collection ${WORKSHOPID} \
            +gamemode ${GAMEMODE} \
            +map ${GAMEMAP}
    fi
fi

GAMEINFO_PATH="${GMODDIR}/garrysmod/gameinfo.txt"

# Wait for gameinfo.txt to exist
while [ ! -f "${GAMEINFO_PATH}" ]; do
    sleep 1
done

# Patch mount paths in gameinfo.txt
sed -i '/Game\/garrysmod\/garrysmod/a \ \ \ \ Game\t\t'"${TF2DIR}/tf"'\n\t\tGame\t\t'"${CSSDIR}/cstrike"'' "${GAMEINFO_PATH}"
