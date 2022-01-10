# Based on Nimbix Ubuntu version
FROM nimbix/ubuntu-desktop

# Update, upgrade and prerequisite installation
RUN apt-get update && apt-get install -y \
	vim \
	ssh \
	sudo \
	ffmpeg \
	software-properties-common \
	&& rm -rf /var/lib/apt/lists/*

# Create OpenFoam user
#RUN useradd --user-group --create-home --shell /bin/bash foam ; \
#	echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install OpenFoam v8 with ParaView
RUN sh -c "wget -O - https://dl.openfoam.org/gpg.key | apt-key add -" ; \
	add-apt-repository http://dl.openfoam.org/ubuntu ; \
	apt-get update -y && apt-get install -y openfoam8 \
	&& rm -rf /var/lib/apt/lists/*

# Modify .bashrc to include OpenFoam binaries.
# Ran as cronjob at startup.
RUN touch /etc/init.d/prepare_openfoam.sh && \
	echo "echo -e \"source /opt/openfoam8/etc/bashrc\nexport OMPI_MCA_btl_vader_single_copy_mechanism=none\" >> /home/nimbix/.bashrc" >> /etc/init.d/prepare_openfoam.sh && \
	chmod +x /etc/init.d/prepare_openfoam.sh && \
	echo "@reboot nimbix /bin/bash /etc/init.d/prepare_openfoam.sh" >> /etc/cron.d/prepare_openfoam

# Set foam to default container user
# USER foam
