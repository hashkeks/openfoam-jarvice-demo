# Based on Nimbix Ubuntu version
FROM ubuntu:18.04

# Update, upgrade and prerequisite installation
RUN apt-get update && apt-get install -y \
	vim \
	ssh \
	sudo \
	wget \
	software-properties-common \
	&& rm -rf /var/lib/apt/lists/*


# Make the Ubuntu Image JARVICE-ready
RUN DEBIAN_FRONTEND=noninteractive curl -H 'Cache-Control: no-cache' \
	https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
  | bash 

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# For standalone use
EXPOSE 5901
EXPOSE 443


# Create OpenFoam user
#RUN useradd --user-group --create-home --shell /bin/bash foam ; \
#	echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install OpenFoam v9 with ParaView
RUN sh -c "wget -O - https://dl.openfoam.org/gpg.key | apt-key add -" ; \
	add-apt-repository http://dl.openfoam.org/ubuntu ; \
	apt-get update -y ; \
	apt-get install -y openfoam9 

RUN	echo "source /opt/openfoam9/etc/bashrc" >> /home/nimbix/.bashrc \
	&& echo "export OMPI_MCA_btl_vader_single_copy_mechanism=none" >> /home/nimbix/.bashrc

#RUN touch /prepare_bashrc.sh
#RUN cat >> prepare_bashrc.sh << EOF \
#	echo "source /opt/openfoam9/etc/bashrc" >> /home/nimbix/.bashrc \
#	echo "export OMPI_MCA_btl_vader_single_copy_mechanism=none" >> /home/nimbix/.bashrc \
#EOF
# Set foam to default container user
# USER foam

