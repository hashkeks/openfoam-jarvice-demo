# Based on Ubuntu 21.04
FROM ubuntu:21.04

# Update, upgrade and prerequisite installation
RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y \
											vim \
											ssh \
											sudo \
											wget \
											software-properties-common ; \
											rm -rf /var/lib/apt/lists/*

# Create OpenFoam user
RUN useradd --user-group --create-home --shell /bin/bash foam ; \
		echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install OpenFoam v9 with ParaView
RUN sh -c "wget -O - https://dl.openfoam.org/gpg.key | apt-key add -" ; \
		add-apt-repository http://dl.openfoam.org/ubuntu ; \
		apt-get update -y ; \
		apt-get upgrade -y ; \
		apt-get install --no-install-recommends -y openfoam9 ; \
		rm -rf /var/lib/apt/lists/* ; \
		echo "source /opt/openfoam9/etc/bashrc" >> ~foam/.bashrc ; \
		echo "export OMPI_MCA_btl_vader_single_copy_mechanism=none" >> ~foam/.bashrc

# Set foam to default container user
# USER foam
