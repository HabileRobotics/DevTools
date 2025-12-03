################################################################################
#                             User's ROS Dockerfile
#
# This container is based on Docker images created below the xxx-base directories.
#
################################################################################
#
# Author:  Jose Pagan
#   Date:  07/28/2025
# Update:  07/28/2025
################################################################################

## Argument to adjust the docker container runtime behavior
ARG BASE_IMAGE=habilerobotics/ros2-jazzy

################################################################################
FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ARG WORKING=workspace
ARG USERNAME=build
ARG UUID=6000
ARG GGID=6000
ARG NXP=0
ARG VSCODE_VER=1.96

ENV HOME="/home/${USERNAME}"
ENV USER=${USERNAME}
ENV USERNAME=${USERNAME}

ARG NXP_INSTALLER_DIR=MCUXpressoInstaller
ARG NXP_TOOLS=.mcuxpressotools

################################################################################
USER root
RUN  userdel -r ubuntu || exit 0

#        usermod -aG users,nogroup,dialout,sudo ${USERNAME}; \
#        mkdir -m777 -p /${WORKING}; \

# create non-root user with given username
# and allow sudo without password
# and setup default users .bashrc
RUN if [ ${UUID} -ne 6000 ]; then \
        groupadd --gid ${GGID} ${USERNAME}; \
        useradd -r --create-home \
            -d ${HOME} \
            -s /bin/bash \
            --uid ${UUID} \
            --gid ${GGID} \
            -c "${USERNAME}" \
            -G users,nogroup,dialout,sudo,adm \
            ${USERNAME}; \
        passwd -d ${USERNAME}; \
        ln -s ${WORKING}  ${HOME}/${WORKING}; \
        chown -R ${USERNAME}:${USERNAME} ${HOME}/.* ${HOME}/* ; \
    fi

########################################################################
## To install VSCode: (or code-insiders) directly from Microsoft
RUN  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null \
  && rm -f packages.microsoft.gpg \
  && apt update \
  && apt install code -q -y \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


################################################################################
USER ${USERNAME}
RUN if [ $NXP -eq 1 ]; then \
         cd ${HOME}; \
         code  --install-extension  ms-vscode.cmake-tools; \
         pip3 install --user -U west; \
    fi

RUN if [ ${NXP} -eq 1 ]; then \
        ln -s /opt/${NXP_TOOLS}  ${HOME}/${NXP_TOOLS}; \
        ln -s /opt/${NXP_INSTALLER_DIR}  ${HOME}/${NXP_INSTALLER_DIR}; \
    fi


WORKDIR ${WORKING}
# ENTRYPOINT [ "/usr/bin/bash", "/opt/ros/humble/setup.bash", "tail -f /dev/null" ]
