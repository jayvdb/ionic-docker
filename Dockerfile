FROM ubuntu:xenial-20180808
MAINTAINER jayvdb [at] gmail [dot] com

# DBUS_SESSION_BUS_ADDRESS is fix for the issue with Selenium described here:
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    NPM_VERSION=6.4.1 \
    IONIC_VERSION=3.20.0 \
    CORDOVA_VERSION=8.0.0 \
    YARN_VERSION=1.6.0 \
    GRADLE_VERSION=4.10.1 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install basics
RUN apt-get update &&  \
    apt-get install -y git curl unzip build-essential && \
    curl -fsSL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update &&  \
    #  python-software-properties (so you can do add-apt-repository)
    apt-get install -y -qq nodejs python-software-properties software-properties-common \
      fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable libfreetype6 libfontconfig \
    && \
    curl -fsSL -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg --unpack google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y && \
    apt-get clean && \
    rm google-chrome-stable_current_amd64.deb && \
    mkdir /Sources && \
    mkdir -p /root/.cache/yarn/ && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && apt-get -y install --allow-unauthenticated oracle-java8-installer && \
    echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --force-yes expect ant libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g npm@"$NPM_VERSION" cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" yarn@"$YARN_VERSION" && \
    npm install -g pnpm \
    npm cache clear

# Install Android Tools
RUN mkdir  /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
    curl -fsSL -o android-tools-sdk.zip https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip

# Install Gradle
RUN mkdir  /opt/gradle && cd /opt/gradle && \
    curl -fsSL -o gradle.zip https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;25.0.2" "platforms;android-25" "platform-tools"
RUN cordova telemetry off

WORKDIR /Sources
EXPOSE 8100 35729
CMD ["ionic", "serve"]
