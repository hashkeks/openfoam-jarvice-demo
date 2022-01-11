### Based on OpenFOAM 7 JARVICE Dockerfile

# Based on Ubuntu 18:04
FROM ubuntu:bionic
LABEL maintainer="Casper/Kaftan"

# Update SERIAL_NUMBER to not cache and force rebuild all layers
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20220111.1000}

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp


# Update, upgrade and prerequisite installation
RUN apt-get update && apt-get install -y \
	vim \
	ssh \
	sudo \
	ffmpeg \
	curl \
	wget \
	software-properties-common


# Install Nimbix Desktop
RUN curl -H 'Cache-Control: no-cache' \
  https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
	| bash -s -- --setup-nimbix-desktop


# Install OpenFoam v8 with ParaView
RUN sh -c "wget -O - https://dl.openfoam.org/gpg.key | apt-key add -" ; \
	add-apt-repository http://dl.openfoam.org/ubuntu ; \
	apt-get update -y && apt-get install -y openfoam8 \
	&& rm -rf /var/lib/apt/lists/*


##appdef config
COPY scripts /usr/local/scripts
COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/gzuz135135.png /etc/NAE/screenshot.png
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


# Modify .bashrc to include OpenFoam binaries.
# Ran as cronjob at startup.
#RUN touch /etc/init.d/prepare_openfoam.sh && \
#	echo "echo -e \"source /opt/openfoam8/etc/bashrc\nexport OMPI_MCA_btl_vader_single_copy_mechanism=none\" >> /home/nimbix/.bashrc" >> /etc/init.d/prepare_openfoam.sh && \
#	chmod +x /etc/init.d/prepare_openfoam.sh && \
#	echo "@reboot nimbix /bin/bash /etc/init.d/prepare_openfoam.sh" >> /etc/cron.d/prepare_openfoam

# Set foam to default container user
# USER foam
