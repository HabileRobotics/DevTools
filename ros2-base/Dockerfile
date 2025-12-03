################################################################################
#                             Dockerfile for ROS
#
# This container is based on Ubuntu Linux (24.04 LTS) and adds 
# ROS2 jazzy (4.13.0).
#
# This Dockerfile builds several layers that include:
#  -- locale
#  -- base linux utils
#  -- other ROS tools
#
# This container takes 20+ minutes for a clean build because it includes many
# additional packages for Ubuntu and ROS.
#
################################################################################
#
# Author:  Jose Pagan
#   Date:  07/28/2025
# Update:  07/28/2025
################################################################################

## Arguments to adjust the dockercontainer runtime behavior
ARG ROS_DISTRO=humble   # jazzy
ARG LINUX_DISTRO=jammy  # noble

################################################################################
FROM docker.io/ubuntu:${LINUX_DISTRO}

ARG ROS_DISTRO
ARG LINUX_DISTRO
ARG DDS_CONFIG_SOURCE_DIR=dds_config
ARG DDS_CONFIG_DIR="/opt/dds/${DDS_CONFIG_SOURCE_DIR}"

ARG DDS_TYPE="rmw_fastrtps_cpp"

ARG DEBIAN_FRONTEND="noninteractive"

ARG WORKING_DIR=workspace

## The default user for this container:
ARG USERNAME=build
ARG UID=6000
ARG GID=6000

ARG LANGUAGE=en
ARG COUNTRY=US
ARG LOCALE=UTF-8
ARG LANG="${LANGUAGE}_${COUNTRY}.${LOCALE}"
ARG LC_ALL="${LANG}"

ENV HOME="/home/${USERNAME}"

# rmw implementation can be overridden at runtime
# RMW_IMPLEMENTATION -> "rmw_cyclonedds_cpp" | "rmw_fastrtps_cpp"
ENV RMW_IMPLEMENTATION=${DDS_TYPE}

ENV CYCLONEDDS_URI="${DDS_CONFIG_DIR}/cyclonedds.xml"
ENV FASTRTPS_PROFILES_FILE="${DDS_CONFIG_DIR}/fastrtps.xml"


################################################################################
## Set Locale: UTC-8
ENV LANG=${LANG}
ENV LC_ALL=${LC_ALL}

RUN  apt update \
  && apt install -y -q \
         locales \
         tzdata \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ${LANGUAGE}_${COUNTRY} ${LANG} \
  && update-locale LC_ALL=${LC_ALL} LANG=${LANG} \
  && export LANG=${LANG}


################################################################################
## ensure that the Ubuntu Universe repository is enabled
#RUN  apt install software-properties-common
#RUN  add-apt-repository universe \
#  && apt autoremove -y \
#  && apt clean \
#  && rm -rf /var/lib/apt/lists/*


################################################################################
## Install Linux tools
## -- need apt-get for "libncurses?"  
RUN  apt-get update \
  && apt-get install -y -q \
        autoconf \
        autoconf-archive \
        apt-transport-https \
        bash-completion \
        build-essential \
        catch2 \
        clang-format \
        clang-tidy \
        clangd \
        curl \
        dirmngr \
        dnsutils \
        emacs \
        git \
        gnupg2 \
        gpg \
        iproute2 \
        iputils-ping \
        libkmod-dev \
        libncurses? \
        libtool \
        lsb-release \
        nano \
        net-tools \
        nfs-client \
        rsync \
        ssh \
        sudo \
        unzip \
        usbutils \
        vim \
        wget \
        x11-apps \
        xauth \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


################################################################################
## Install special Linux packages used for development
## Cannot add kernel headers such as; linux-headers-6.11.0-21-generic
RUN  apt update \
  && apt install -y -q \
        black \
        can-utils \
        ddd \
        gdb \
        gdbserver \
        python3 \
        mypy \
        python3-can \
        python3-pip \
        python-is-python3 \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*


########################################################################
## Install Google Test Dependencies. From platform-op-bridge:
RUN  apt update \
  && apt install -y -q \
        kmod \
        libmount-dev \
        mount \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*


################################################################################
# Install Gazebo Key
#
RUN  curl -sSl https://packages.osrfoundation.org/gazebo.gpg \
          -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
           http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
       | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
################################################################################
# Install ROS2 Key
#
RUN  curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
          -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
           http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
       | tee /etc/apt/sources.list.d/ros2.list > /dev/null


################################################################################
## (#8)  Install ROS2
## -- want to upgrade before install ROS2
RUN  apt update \
  && apt upgrade -y -q \
  && apt install -y -q \
         python3-colcon-argcomplete \
         python3-colcon-common-extensions \
         python3-colcon-mixin \
         python3-rosdep \
         python3-vcstool \
         ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
         ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
         ros-${ROS_DISTRO}-desktop \
         ros-${ROS_DISTRO}-geometry2 \
         ros-${ROS_DISTRO}-gazebo-msgs \
         ros-${ROS_DISTRO}-navigation2 \
         ros-${ROS_DISTRO}-nav2-bringup \
         ros-${ROS_DISTRO}-ros-core \
         ros-${ROS_DISTRO}-teleop-twist-keyboard \
         ros-${ROS_DISTRO}-ros2-control \
         ros-${ROS_DISTRO}-ros2-controllers \
         ros-${ROS_DISTRO}-rviz2* \
         ros-${ROS_DISTRO}-rosbag2* \
         ros-${ROS_DISTRO}-rqt* \
         ros-${ROS_DISTRO}-turtlesim \
         ros-dev-tools \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

################################################################################
## (#9) Install ROS and the ROS2 development tools
## -- want to upgrade before installing ROS2
RUN  apt update \
  && apt install -y -q \
         ros-${ROS_DISTRO}-demo-nodes-cpp \
         ros-${ROS_DISTRO}-demo-nodes-py \
         ros-${ROS_DISTRO}-joint-state-publisher \
         ros-${ROS_DISTRO}-joint-state-publisher-gui \
         ros-${ROS_DISTRO}-joy* \
         ros-${ROS_DISTRO}-ros-gz \
         ros-${ROS_DISTRO}-ros-gz-bridge \
         ros-${ROS_DISTRO}-ros-gz-sim \
         ros-${ROS_DISTRO}-xacro \
         ros-dev-tools \
         ros-${ROS_DISTRO}-gz-ros2-control \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*


################################################################################
## setup colcon mixin and metadata
RUN  colcon mixin add default \
       https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml \
  && colcon mixin update default \
  && colcon metadata add default \
       https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml \
  && colcon metadata update


################################################################################
## Build and Install Dynamixel SDK 
WORKDIR /tmp/sdk
RUN git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git \
  && cd DynamixelSDK/c++/build/linux64 \
  && make \
  && make install


################################################################################
## Install ROS humble specific packages
## NOTE:
##   - debugpy - is installed using PIP3.
##
RUN if [ "${ROS_DISTRO}" = "humble" ] ; then \
        pip3 install debugpy ;\
        apt update ; \
        apt install -y -q \
              ros-${ROS_DISTRO}-nav2-minimal-tb* \
              ros-${ROS_DISTRO}-gazebo-ros-pkgs; \
              ros-${ROS_DISTRO}-gazebo-plugins \
              ros-${ROS_DISTRO}-ros-ign-bridge \
         apt autoremove -y ; \
        apt clean ; \
        rm -rf /var/lib/apt/lists/* ; \
    fi


################################################################################
## Install ROS jazzy specific packages
## NOTE:
##   - debugpy install as Linux package.
##
RUN if [ "${ROS_DISTRO}" = "jazzy" ] ; then \
        apt-get update ; \
        apt-get install -y -q \
                python3-debugpy \
                ros-${ROS_DISTRO}-gz-control; \
                ros-${ROS_DISTRO}-ros-gz-sim-controllers \
        apt autoremove -y ; \
        apt clean ; \
        rm -rf /var/lib/apt/lists/* ; \
    fi


################################################################################
## Build and Install plotjuggler, from source
##
RUN  apt update \
  && apt install -y -q \
                 binutils-dev \
                 cmake \
                 protobuf-compiler \
                 liblua5.1-0-dev \
                 libmosquittopp-dev \
                 liblz4-dev \
                 libprotoc-dev \
                 libzmq3-dev \
                 libqt5opengl5-dev \
                 libqt5svg5-dev \
                 libqt5websockets5-dev \
                 libqt5x11extras5-dev \
                 libzstd-dev \
                 nlohmann-json3-dev \
                 qtbase5-dev \
                 ros-${ROS_DISTRO}-ament-cmake \
                 ros-${ROS_DISTRO}-ament-cmake-core \
                 ros-${ROS_DISTRO}-ament-cmake-export-dependencies \
                 ros-${ROS_DISTRO}-ament-cmake-libraries \
                 ros-${ROS_DISTRO}-ament-cmake-python  \
                 ros-${ROS_DISTRO}-ament-cmake-ros \
                 ros-${ROS_DISTRO}-ament-cmake-target-dependencies \
                 ros-${ROS_DISTRO}-ament-package \
                 ros-${ROS_DISTRO}-rclcpp \
                 ros-${ROS_DISTRO}-rclcpp-components \
                 ros-${ROS_DISTRO}-rosidl-default-generators \
                 ros-${ROS_DISTRO}-rosidl-default-runtime \
     && apt autoremove -y \
     && apt clean  \
     && rm -rf /var/lib/apt/lists/* \
     && rosdep init && rosdep update  \
     && mkdir -p /opt/plotjuggler/src  \
     && cd /opt/plotjuggler/src  \
     && git clone --branch 0.2.3  https://github.com/PlotJuggler/plotjuggler_msgs.git  \
     && git clone --branch 3.10.9 https://github.com/facontidavide/PlotJuggler.git  \
     && git clone --branch 2.3.1  https://github.com/PlotJuggler/plotjuggler-ros-plugins.git  \
     && cd /opt/plotjuggler  \
     && . /opt/ros/${ROS_DISTRO}/setup.sh  \
     && export AMENT_PREFIX_PATH=/opt/ros/${ROS_DISTRO}  \
     && export CMAKE_PREFIX_PATH=/opt/ros/${ROS_DISTRO} \
     && export ROS_VERSION=2  \
     && export ROS_PYTHON_VERSION=3  \
     && rosdep install --from-paths src --ignore-src -y  \
     && colcon build \
            --cmake-args \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DROS_DISTRO=${ROS_DISTRO} \
            -DROS_VERSION=2 \
            -DCMAKE_PREFIX_PATH="/opt/ros/${ROS_DISTRO}"


########################################################################
# setup libgpiod v2.1.3
# Using commit SHA --> 96bdfc1071b3c59afdd87779c8d4d50284cfbed9
# URL -->   https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/commit/?h=v2.1.3&id=96bdfc1071b3c59afdd87779c8d4d50284cfbed9
#
##
RUN  apt update -y -q \
  && git clone https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git \
  && cd libgpiod \
  && git checkout 96bdfc1071b3c5 \
  && ./autogen.sh \
       --enable-tools=yes \
       --enable-bindings-cxx \
       --prefix=/usr/local/ \
  && make \
  && make install \
  && apt autoremove -y \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*


# Copy dds config files
#RUN  mkdir -p ${DDS_CONFIG_DIR}
COPY ${DDS_CONFIG_SOURCE_DIR}  ${DDS_CONFIG_DIR}

################################################################################
## Update the user skeleton ".bashrc" file for all new users 
##
RUN  sed -i s/"\${debian_chroot:+(\$debian_chroot)}"/"docker-\${debian_chroot:+(\$debian_chroot)}"/g  /etc/skel/.bashrc
RUN  echo "export ROS_DISTRO=$ROS_DISTRO"                                                                   >> /etc/skel/.bashrc \
  && echo "export ROS_DOMAIN_ID=0                                                                           >> /etc/skel/.bashrc \
  && echo "export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET                                                      >> /etc/skel/.bashrc \
  && echo "export FASTRTPS_DEFAULT_PROFILES_FILE=${FASTRTPS_PROFILES_FILE}"                                 >> /etc/skel/.bashrc \
  && echo "export CYCLONEDDS_URI=${CYCLONEDDS_URI}"                                                         >> /etc/skel/.bashrc \
  && echo "export RMW_IMPLEMENTATION=\${USE_DDS:-$RMW_IMPLEMENTATION}"                                      >> /etc/skel/.bashrc \
  && echo "source /opt/ros/${ROS_DISTRO}/setup.bash"                                                        >> /etc/skel/.bashrc \
  && echo "[[ -f /opt/plotjuggler/install/setup.sh ]] && source /opt/plotjuggler/install/setup.sh"          >> /etc/skel/.bashrc \
  && echo "SETUP=\"\$(find /${WORKING_DIR} -name setup.bash)\""                                             >> /etc/skel/.bashrc \
  && echo "[ -n \"\${SETUP}\" ] && source \${SETUP}"                                                        >> /etc/skel/.bashrc \
  && echo "[[ \$LD_LIBRARY_PATH != */usr/local/lib* ]] && export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib"  >> /etc/skel/.bashrc \
  && echo "[[ \$LD_LIBRARY_PATH != */opt/plotjuggler/install/plotjuggler/lib/plotjuggler* ]] && export LD_LIBRARY_PATH=/opt/plotjuggler/install/plotjuggler/lib/plotjuggler:\$LD_LIBRARY_PATH"  >> /etc/skel/.bashrc \
  && echo "[[ \$PATH != */opt/plotjuggler/install/plotjuggler/lib/plotjuggler* ]] && export PATH=/opt/plotjuggler/install/plotjuggler/lib/plotjuggler:\$PATH"   >> /etc/skel/.bashrc


################################################################################
## Add the default user and group to the image:
##
RUN  mkdir -m 777 /${WORKING_DIR}
RUN  groupadd --gid ${GID} ${USERNAME}
RUN  useradd  -m \
       -s /bin/bash \
       -c "${USERNAME}" \
       --uid ${UID} \
       --gid ${GID} \
       -G users,nogroup,dialout,sudo \
       ${USERNAME} \
  && passwd -d ${USERNAME}

RUN cp /etc/skel/.bash*  ${HOME}/  \
  && cp /etc/skel/.profile  ${HOME}/  \
  && mkdir -p /${WORKING_DIR} \
  && ln -s /${WORKING_DIR} ${HOME}/${WORKING_DIR} \
  && chown -R ${UID}:${GID} ${HOME}/.*  ${HOME}/*

## Remove the Ubuntu user, if present
RUN  userdel -r ubuntu || exit 0


################################################################################
USER ${USERNAME}
