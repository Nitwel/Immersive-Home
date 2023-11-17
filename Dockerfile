# Barichello godot CI image, modified to work with Godot 4.
FROM ubuntu:kinetic
LABEL author="https://github.com/aBARICHELLO/godot-ci/graphs/contributors"

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    python3 \
    python3-openssl \
    unzip \
    wget \
    zip \
    adb \
    openjdk-11-jdk-headless \
    rsync \
# Added for https://github.com/godotengine/godot/issues/55317 - remove to shrink binaries later.
    libxcursor-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxi6 \
    libgl1 \
# End Bugfix Extras
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN wget -P /opt/butler/ https://gitlab.com/barichello/godot-ci/-/raw/master/getbutler.sh
RUN bash /opt/butler/getbutler.sh
RUN /opt/butler/bin/butler -V

ENV PATH="/opt/butler/bin:${PATH}"

# Download and setup android-sdk
ENV ANDROID_HOME="/usr/lib/android-sdk"
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip \
    && unzip commandlinetools-linux-*_latest.zip -d cmdline-tools \
    && mv cmdline-tools $ANDROID_HOME/ \
    && rm -f commandlinetools-linux-*_latest.zip

ENV PATH="${ANDROID_HOME}/cmdline-tools/cmdline-tools/bin:${PATH}"

RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529"

# Adding android keystore and settings
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    && mv debug.keystore /root/debug.keystore

ARG GODOT_VERSION="4.1.3"
ARG RELEASE_NAME="stable"

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip

RUN mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip

RUN godot -e --quit --display-driver headless
RUN echo 'export/android/android_sdk_path = "/usr/lib/android-sdk"' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/debug_keystore = "/root/debug.keystore"' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/force_system_user = false' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/timestamping_authority_url = ""' >> ~/.config/godot/editor_settings-4.tres
RUN echo 'export/android/shutdown_adb_on_exit = true' >> ~/.config/godot/editor_settings-4.tres
