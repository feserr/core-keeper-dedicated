###########################################################
# Dockerfile that builds a Core Keeper Gameserver
###########################################################
FROM cm2network/steamcmd:root

LABEL maintainer="leandro.martin@protonmail.com"

ENV STEAMAPPID 1007
ENV STEAMAPPID_TOOL 1963720
ENV STEAMAPP core-keeper
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMAPPDATADIR "${HOMEDIR}/${STEAMAPP}-data"
ENV SCRIPTSDIR "${HOMEDIR}/scripts"
ENV MODSDIR "${STEAMAPPDATADIR}/StreamingAssets/Mods"
ENV DLURL https://raw.githubusercontent.com/escapingnetwork/core-keeper-dedicated

RUN dpkg --add-architecture i386

# Install Core Keeper server dependencies and clean up
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        xvfb \
        libxi6 \
        tini \
        tzdata \
        gosu \
        jo \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Setup X11 Sockets folder
RUN mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix

# Setup folders
COPY ./scripts ${SCRIPTSDIR}
RUN set -x \
    && chmod +x -R "${SCRIPTSDIR}" \
    && mkdir -p "${STEAMAPPDIR}" \
    && mkdir -p "${STEAMAPPDATADIR}" \
    && chown -R "${USER}:${USER}" "${SCRIPTSDIR}" "${STEAMAPPDIR}" "${STEAMAPPDATADIR}"

# Declare envs and their default values
ENV PUID=1000 \
    PGID=1000 \
    WORLD_INDEX=0 \
    WORLD_NAME="Core Keeper Server" \
    WORLD_SEED=0 \
    WORLD_MODE=0 \
    GAME_ID="" \
    DATA_PATH="${STEAMAPPDATADIR}" \
    MAX_PLAYERS=10 \
    SEASON=-1 \
    SERVER_IP="" \
    SERVER_PORT="" \
    DISCORD_WEBHOOK_URL="" \
    # Player Join
    DISCORD_PLAYER_JOIN_ENABLED=true \
    DISCORD_PLAYER_JOIN_MESSAGE='${char_name} (${steamid}) has joined the server.' \
    DISCORD_PLAYER_JOIN_TITLE="Player Joined" \
    DISCORD_PLAYER_JOIN_COLOR="47456" \
    # Player Leave
    DISCORD_PLAYER_LEAVE_ENABLED=true \
    DISCORD_PLAYER_LEAVE_MESSAGE='${char_name} (${steamid}) has disconnected. Reason: ${reason}.' \
    DISCORD_PLAYER_LEAVE_TITLE="Player left" \
    DISCORD_PLAYER_LEAVE_COLOR="11477760" \
    # Server Start
    DISCORD_SERVER_START_ENABLED=true \
    DISCORD_SERVER_START_MESSAGE='**World:** ${world_name}\n**GameID:** ${gameid}' \
    DISCORD_SERVER_START_TITLE="Server Started" \
    DISCORD_SERVER_START_COLOR="2013440" \
    # Server Stop
    DISCORD_SERVER_STOP_ENABLED=true \
    DISCORD_SERVER_STOP_MESSAGE="" \
    DISCORD_SERVER_STOP_TITLE="Server Stopped" \
    DISCORD_SERVER_STOP_COLOR="12779520"

# Switch to workdir
WORKDIR ${HOMEDIR}

# Use tini as the entrypoint for signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["bash", "scripts/entry.sh"]
