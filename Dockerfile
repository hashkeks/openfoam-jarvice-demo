# Based on Nimbix Ubuntu version
FROM ubuntu:18.04

# Update, upgrade and prerequisite installation
RUN apt-get update -y 

RUN apt-get install -y \
											vim \
											ssh \
											sudo \
											wget \
											curl \
											software-properties-common ; \

# Create OpenFoam user
RUN useradd --user-group --create-home --shell /bin/bash foam ; \
		echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install OpenFoam v9 with ParaView
RUN sh -c "wget -O - https://dl.openfoam.org/gpg.key | apt-key add -" ; \
		add-apt-repository http://dl.openfoam.org/ubuntu ; \
		apt-get update -y ; \
		apt-get install --no-install-recommends -y openfoam9 ; \
		echo "source /opt/openfoam9/etc/bashrc" >> ~foam/.bashrc ; \
		echo "export OMPI_MCA_btl_vader_single_copy_mechanism=none" >> ~foam/.bashrc

# Set foam to default container user
# USER foam

# Make the Ubuntu Image JARVICE-ready
RUN curl -H 'Cache-Control: no-cache' \
		https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
    | bash 

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22
