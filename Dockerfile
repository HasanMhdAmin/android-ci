FROM debian:bookworm-slim

# Environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV GRADLE_USER_HOME=/opt/.gradle
ENV NVM_DIR=/root/.nvm
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$NVM_DIR/versions/node/v20.*/bin

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget unzip curl gnupg gnupg2 git python-is-python3 ca-certificates lsb-release apt-transport-https software-properties-common build-essential

# Install Java 17 (BellSoft)
RUN wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | apt-key add - && \
    echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" > /etc/apt/sources.list.d/bellsoft.list && \
    apt-get update && \
    apt-get install -y bellsoft-java17-lite && \
    java -version

# Install Android SDK command line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget --quiet -O sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    rm sdk.zip && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest/

# Accept Android SDK licenses and install components
RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT --update && \
    yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        "platform-tools"

# Install Google Cloud SDK
RUN wget --quiet -O /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz && \
    mkdir -p /opt && \
    tar -C /opt -xf /tmp/google-cloud-sdk.tar.gz && \
    /opt/google-cloud-sdk/install.sh --quiet && \
    echo "source /opt/google-cloud-sdk/path.bash.inc" >> ~/.bashrc

# Install Firebase CLI using NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 20 && \
    nvm use 20 && \
    npm install -g firebase-tools

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Final confirmation
RUN java -version && node -v && npm -v && firebase --version && gcloud --version && sdkmanager --list
