################################################################################
#                           Dockerfile for STM32 with ROS
#
# This container is based on the ROS:jazzy image which os pre-build by ROS.ORG
# containing Ubuntu Linux (24.04 LTS) and the ROS2 jazzy environment (4.13.0).
#
# This Dockerfile builds several layers that include:
#  -- locale
#  -- base linux utils
#  -- Visual Studio CODE (from MS)
#  -- STM32 tools for VSCode
#  -- other ROS tools
#
# This container takes 10+ minutes for a clean build because it includes many
# additional packages for Ubuntu, ROS and STM32.
#
################################################################################
#
# Author:  Jose Pagan
#   Date:  07/28/2025
# Update:  07/28/2025
################################################################################

################################################################################
## Define the ROS distro:
ARG ROS_DISTRO="humble"
#ARG ROS_DISTRO="jazzy"

################################################################################
## Use ros:${ROS_DISTRO} as the base image:
FROM ros:${ROS_DISTRO}

################################################################################
ARG USERNAME="build"
ARG USER_UID=6000
ARG USER_GID=6000

ARG WORKING_DIR="workspace"
ARG HOME_DIR="/home/${USERNAME}"
ARG WORKSPACE="${HOME_DIR}/${WORKING_DIR}"
ARG DDS_CONFIG_DIR="/opt/dds/config"
ARG DDS_TYPE="fastrtps"

# rmw implementation can be overridden at runtime
# RMW_IMPLEMENTATION -> "rmw_cyclonedds_cpp" | "rmw_fastrtps_cpp"
ENV RMW_IMPLEMENTATION="rmw_fastrtps_cpp"

ENV CYCLONEDDS_URI="${DDS_CONFIG_DIR}/cyclonedds.xml"
ENV FASTRTPS_PROFILES_FILE="${DDS_CONFIG_DIR}/fastrtps.xml"

ARG DEBIAN_FRONTEND="noninteractive"

## USE C as prefix for Unicode
# ARG LOCALE_PREFIX="C"

## USE en_US as prefix for USA
ARG LOCALE_PREFIX="en_US"

ARG LOCALE_LANG=${LOCALE_PREFIX}.UTF-8 
ARG LOCALE_LC_ALL=${LOCALE_PREFIX}.UTF-8

ENV LANG=${LOCALE_LANG}
ENV LC_ALL=${LOCALE_LC_ALL}
ENV ROS_DISTRO=${ROS_DISTRO}
# ENV USER=$USERNAME
# ENV USERNAME=$USERNAME


################################################################################
## Install ROS pacakges, as ROOT
USER root

## Set the locale to: UTF-8
RUN  apt update \
  && apt install -y -q \
     	 locales \
     	 tzdata \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ${LOCALE_PREFIX} ${LOCALE_LANG} \
  && update-locale LC_ALL=${LOCALE_LC_ALL} LANG=${LOCALE_LANG} \
  && export LANG=${LOCALE_LANG}


################################################################################
## Install Linux tools
RUN  apt-get update \
  && apt-get install -y -q \
        apt-transport-https \
        bash-completion \
        build-essential \
        black \
        build-essential \
        clang-format \
        clang-tidy \
        clangd \
        curl \
        dirmngr \
        emacs \
        git \
        gnupg2 \
        gpg \
        iproute2 \
        libgpiod2 \
        libncurses? \
        nano \
        net-tools \
        nfs-client \
        rsync \
        ssh \
        sudo \
        tzdata \
        unzip \
        usbutils \
        wget \
        x11-apps \
        xauth \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


################################################################################
## Install Linux tools
RUN  apt-get update \
  && apt-get install -y -q \ 
        python3 \
        mypy \
        python3-pip \
        python-is-python3 \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


########################################################################
## Install Google Test Dependencies. From platform-op-bridge:
RUN  apt update \
  && apt-get install -y -q \
        kmod \
        libmount-dev \
        mount \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/


########################################################################
## Install the STM32 CLT, as a layer,
##   where the ".sh" file is on the ftp server.
##
## Sharepoint location:
##
## https://terexcorporation.sharepoint.com/:f:/r/sites/DEPT-AWP-Engineering-ControlsandTechnology/Shared%20Documents/Software/ALC200/STM32?csf=1&web=1&e=xEP6nY
##

## Set some default arguments for CLT processing:
ARG FTP_SRV="controls-Precision-7920-Tower"
    ## Destination for install, to match the DEFAUL desktop install location
ARG STM32_CLT_DEST="/opt/st/stm32cubeclt_1.15.1"
    ## CLT file name, on the FTP server
ARG STM32_CLT_SH_FILE_NAME="st-stm32cubeclt_1.15.1_21094_20240412_1041_amd64.sh"
    ## Needed for unattended CLT install:
ENV LICENSE_ALREADY_ACCEPTED=Y

## Intalling the CLT in steps:
##   1. Copy the CLT file from the server to the local container
##   2. install to the container's file-system, as root:
##   3. cleanup before finalizing the layer
RUN mkdir /tmpst && cd /tmpst \
 && wget -qO ./$STM32_CLT_SH_FILE_NAME  ftp://$FTP_SRV/$STM32_CLT_SH_FILE_NAME \
 && chmod +x ./${STM32_CLT_SH_FILE_NAME} \
 && ./${STM32_CLT_SH_FILE_NAME} --quiet $STM32_CLT_DEST \
 && cd && rm -rf /tmpst


########################################################################
## Install the STM32 CubeMX application, as a layer,
##   where the ".zip" file is on the ftp server.
##
## NOTE: the install path of the CubeMX tool is dictated by the
##       auto-install.xml file. The location of the tool, in the
##       container is "/opt/STM32CubeMX" to make it easy to find.
##       This may differ from a user's local install which is, by
##       default in the root file system;
##        "/usr/local/STMicroelectronics/STM32Cube/STM32CubeMX"
##
##       For consistency, users should install locally using the
##       pre-defined auto-install.xml file;
##         $  ./SetupSTM32CubeMX-6.11.1  auto-install.xml
##
## Set some default arguments for CLT processing:
##    CubeMX file name, on the FTP server
ARG STM32_MX_ZIP_FILE_NAME="en.stm32cubemx-lin-v6-12-0.zip"
ARG STM32_INSTALL_FILE_NAME="SetupSTM32CubeMX-6.12.0"
ARG STM32_INSTALL_SCRIPT_NAME="auto-install.xml"
    ## Needed for unattended CubeMX install:
ENV LICENSE_ALREADY_ACCEPTED=Y

## Intalling the CubeMX in steps:
##   1. Copy the CubeMX file and install script (XML) from the server
##   2. Unzip CubeMX
##   3. install CubeMX to the container's file-system, as root
##   4. cleanup
RUN  mkdir /tmpst && cd /tmpst \
  && wget -q ftp://$FTP_SRV/$STM32_INSTALL_SCRIPT_NAME -O $STM32_INSTALL_SCRIPT_NAME \
  && wget -q ftp://$FTP_SRV/$STM32_MX_ZIP_FILE_NAME  -O $STM32_MX_ZIP_FILE_NAME \
  && unzip $STM32_MX_ZIP_FILE_NAME \
  && ./$STM32_INSTALL_FILE_NAME $STM32_INSTALL_SCRIPT_NAME \
  && cd && rm -rf /tmpst


########################################################################
## To install VSCode: (or code-insiders) directly from Microsoft
##RUN  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
##  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
##  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null \
##  && rm -f packages.microsoft.gpg \
##  && apt update \
##  && apt install code -q -y \
##  && apt-get autoremove -y \
##  && apt-get clean \
##  && rm -rf /var/lib/apt/lists/*


########################################################################
## To install VSCode from a .DEB file:
##   1. copy DEB file
##   2. install DEB
##   3. remove the DEB, from container
####
#RUN  mkdir /${WORKING_DIR} && cd /${WORKING_DIR}
#ADD  ./code_1.91.1-1720564633_amd64.deb .
#RUN  apt-get install -y ./code_1.91.1-1720564633_amd64.deb
#RUN  rm  ./code_1.91.1-1720564633_amd64.deb


########################################################################
## Install ROS items:
##          ros-${ROS_DISTRO}-plotjuggler-ros
RUN  apt update \
  && apt install -q -y \
        python3-colcon-argcomplete \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
        ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
        ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-demo-nodes-cpp \
        ros-${ROS_DISTRO}-demo-nodes-py \
        ros-${ROS_DISTRO}-turtlesim \
        ros-${ROS_DISTRO}-rosbag2* \
        ros-${ROS_DISTRO}-rqt* \
        ros-dev-tools \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


########################################################################
## Create user in the container that matches the current workstation user:
# ROS:jazzy image contains a Ubuntu user with ID=1000:1000
# We need to assign this user ID=2000:2000 to make room for
# the local workstation user.
#   -- NOTE: the trailing exit will ignore failure for non-jazzy ROS.
RUN  groupmod -g 2000 ubuntu \
  && usermod -g 2000 -u 2000 ubuntu \
  && chown -R ubuntu:ubuntu /home/ubuntu \
  && passwd -d ubuntu \
  || exit 0

# Copy dds config files
RUN mkdir -p ${DDS_CONFIG_DIR}
ADD ${DDS_CONFIG_SOURCE_DIR}  ${DDS_CONFIG_DIR}

################################################################################
## Update the user skeleton ".bashrc" file for all new users 
##
## Prefix path with "docker-" for everyone
RUN  sed -i s/"\${debian_chroot:+(\$debian_chroot)}"/"docker-\${debian_chroot:+(\$debian_chroot)}"/g  /etc/skel/.bashrc
##
RUN  echo "export PATH=${STM32_CLT_DEST}/STM32CubeProgrammer/bin:\$PATH"        >> /etc/skel/.bashrc \
  && echo "export PATH=${STM32_CLT_DEST}/STLink-gdb-server/bin:\$PATH"          >> /etc/skel/.bashrc \
  && echo "export PATH=${STM32_CLT_DEST}/CMake/bin:\$PATH"                      >> /etc/skel/.bashrc \
  && echo "export PATH=${STM32_CLT_DEST}/Ninja/bin:\$PATH"                      >> /etc/skel/.bashrc \
  && echo "export PATH=${STM32_CLT_DEST}/GNU-tools-for-STM32/bin:\$PATH"        >> /etc/skel/.bashrc \
  && echo "export ROS_DISTRO=$ROS_DISTRO"                                       >> /etc/skel/.bashrc \
  && echo "source /opt/ros/${ROS_DISTRO}/setup.bash"                            >> /etc/skel/.bashrc \
  && echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib"             >> /etc/skel/.bashrc \
  && echo "SETUP=\"\$(find /${WORKING_DIR} -name setup.bash)\""                 >> /etc/skel/.bashrc \
  && echo "[ -n \"\${SETUP}\" ] && source \${SETUP}"                            >> /etc/skel/.bashrc \
  && echo "export RMW_IMPLEMENTATION=\${USE_DDS:-$RMW_IMPLEMENTATION}"          >> /etc/skel/.bashrc \
  && echo "export FASTRTPS_DEFAULT_PROFILES_FILE=${FASTRTPS_PROFILES_FILE}"     >> /etc/skel/.bashrc \
  && echo "export CYCLONEDDS_URI=${CYCLONEDDS_URI}"                             >> /etc/skel/.bashrc \
  && echo "source /etc/profile.d/bash_completion.sh"                            >> /etc/skel/.bashrc \
  && echo "[[ \$LD_LIBRARY_PATH != */usr/local/lib* ]] && export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib"    >> /etc/skel/.bashrc 


########################################################################
## Create a user and group to match the local user's account:
RUN  mkdir -m 777 /${WORKING_DIR}
RUN  groupadd --gid ${USER_GID} ${USERNAME}
RUN  useradd  -m \
       -s /bin/bash \
       -c "${USERNAME}" \
       --uid ${USER_UID} \
       --gid ${USER_GID} \
       -G users,nogroup,dialout,sudo \
       ${USERNAME} \
  && passwd -d ${USERNAME}

RUN  cp /etc/skel/.bash*    ${HOME_DIR}/  \
  && cp /etc/skel/.profile  ${HOME_DIR}/  \
  && ln -s /${WORKING_DIR}  ${HOME_DIR}/${WORKING_DIR} \
  && chown -R ${UID}:${GID} ${HOME_DIR}/.*  ${HOME_DIR}/*


################################################################################
#  && sudo apt-get update \
#  && sudo rosdep init \
#  && rosdep update --rosdistro ${ROS_DISTRO} \
#  && rosdep install -y -r -i --from-paths ${WORKSPACE}/src \
#  && sudo rm -rf /var/lib/apt/lists/*"

USER ${USERNAME}

#RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash"

#CMD ["ros2", "launch", "demo_nodes_cpp", "talker_listener_launch.py"]

# by default hold container open in background
#CMD ["tail", "-f", "/dev/null"]


################################################################################
# END:
