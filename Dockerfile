FROM microsoft/dotnet:2.0-sdk

# get add-apt-repository
RUN apt-get update
RUN apt-get -y --no-install-recommends install software-properties-common curl apt-transport-https

# add nodejs ppa
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# update apt cache
RUN apt-get update

# vscode dependencies
RUN apt-get -y --no-install-recommends install libc6-dev libgtk2.0-0 libgtk-3-0 libpango-1.0-0 \
  libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module \
  libgl1-mesa-glx curl build-essential gettext libstdc++6 software-properties-common \
  wget git xterm automake libtool autogen nodejs libnotify-bin aspell aspell-en htop git \
  emacs mono-complete gvfs-bin libxss1 rxvt-unicode-256color x11-xserver-utils sudo vim \
  adwaita-icon-theme at-spi2-core colord colord-data dbus \
  dconf-gsettings-backend dconf-service gconf-service gconf2-common \
  glib-networking glib-networking-common glib-networking-services \
  gsettings-desktop-schemas init-system-helpers libasound2 libasound2-data \
  libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libavahi-client3 \
  libavahi-common-data libavahi-common3 libcanberra-gtk3-0 \
  libcanberra-gtk3-module libcanberra0 libcap-ng0 libcolord2 libcolorhug2 \
  libcups2 libdbus-1-3 libdbus-glib-1-2 libdconf1 libfile-copy-recursive-perl \
  libgconf-2-4 libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgtk-3-0 \
  libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2 libieee1284-3 \
  libjson-glib-1.0-0 libjson-glib-1.0-common libnotify4 libnspr4 libnss3 \
  libogg0 libpam-systemd libpolkit-agent-1-0 libpolkit-backend-1-0 \
  libpolkit-gobject-1-0 libproxy1 librest-0.7-0 libsane libsane-common \
  libsane-extras libsane-extras-common libsoup-gnome2.4-1 libsoup2.4-1 libtdb1 \
  libusb-1.0-0 libv4l-0 libv4lconvert0 libvorbis0a libvorbisfile3 \
  libwayland-client0 libwayland-cursor0 libxcomposite1 libxcursor1 libxdamage1 \
  libxfixes3 libxi6 libxinerama1 libxkbcommon0 libxkbfile1 libxrandr2 libxtst6 \
  notification-daemon policykit-1 sane-utils update-inetd xkb-data && \
  apt-get clean -qq -y && \
  apt-get autoclean -qq -y && \ 
  apt-get autoremove -qq -y && \ 
  rm -rf /var/lib/apt/lists/* && \ 
  rm -rf /tmp/*

# update npm
RUN npm install npm -g

# install vscode
RUN wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868
RUN dpkg -i vscode-amd64.deb
RUN rm vscode-amd64.deb

# install flat plat theme
RUN curl -sL https://github.com/nana-4/Flat-Plat/archive/v20170515.tar.gz | tar xz
RUN cd Flat-Plat-20170515 && ./install.sh
RUN cd .. && rm -rf Flat-Plat*
RUN mv /usr/share/themes/Default /usr/share/themes/Default.bak
RUN ln -s /usr/share/themes/Flat-Plat /usr/share/themes/Default

# install hack font
RUN wget 'https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip'
RUN unzip Hack*.zip
RUN mkdir /usr/share/fonts/truetype/Hack
RUN mv Hack* /usr/share/fonts/truetype/Hack
RUN fc-cache -f -v

# create our developer user
workdir /root
RUN groupadd -r developer -g 1000
RUN useradd -u 1000 -r -g developer -d /developer -s /bin/bash -c "Software Developer" developer
COPY /developer /developer
WORKDIR /developer

# default browser firefox
RUN ln -s /developer/.local/share/firefox/firefox /bin/xdg-open

# enable sudo for developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# fix developer permissions
RUN chmod +x /developer/bin/*
RUN chown -R developer:developer /developer
USER developer

# install firefox
RUN mkdir Applications
#run wget "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US" -O firefox.tar.bz2
RUN wget "https://ftp.mozilla.org/pub/firefox/nightly/latest-date/firefox-55.0a1.en-US.linux-x86_64.tar.bz2" -O firefox.tar.bz2
RUN tar -xf firefox.tar.bz2
RUN mv firefox .local/share
RUN rm firefox.tar.bz2

# links for firefox
RUN ln -s /developer/.local/share/firefox/firefox /developer/bin/x-www-browser
RUN ln -s /developer/.local/share/firefox/firefox /developer/bin/gnome-www-browser

# copy in test project
COPY project /developer/project
WORKDIR /developer/project

# setup our ports
EXPOSE 5000
EXPOSE 3000
EXPOSE 3001

# set environment variables
ENV PATH /developer/.npm/bin:$PATH
ENV NODE_PATH /developer/.npm/lib/node_modules:$NODE_PATH
ENV BROWSER /developer/.local/share/firefox/firefox-bin
ENV SHELL /bin/bash

# mount points
VOLUME ["/developer/.config/Code"]
VOLUME ["/developer/.vscode"]
VOLUME ["/developer/.ssh"]
VOLUME ["/developer/project"]

# start vscode
ENTRYPOINT ["/developer/bin/start-shell"]

