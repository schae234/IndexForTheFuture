FROM ubuntu:18.04
LABEL Description "https://github.com/jonahcullen/IndexForTheFuture"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade --yes

# Install zsh
RUN apt-get install zsh --yes
RUN chsh -s $(which zsh)

# Install the necessary packages ontop of base ubuntu installation
RUN apt-get install -y \
    curl \
    lsb-release \
    wget \
    git \
    gcc \
    vim \
    tmux \
    tree \
    htop \
    build-essential \
#    apt-transport-https \
#    python3 \
#    python3-dev \
#    python3-pip \
    s3cmd \
    zlib1g-dev

RUN mkdir -p /home/.local/{bin,src}
WORKDIR /home/.local/src

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN sh miniconda.sh -b -p /home/.conda
ENV PATH=/home/.conda/bin:${PATH}
RUN conda update -n base conda
RUN /home/.conda/bin/conda init zsh

# Install snakemake, STAR, and salmon
RUN conda install -c bioconda -c conda-forge -y \
    snakemake=5.8.1 \
    star=2.6.1 \
    salmon=0.13.1

# Clone SalmonTools and modify path
RUN git clone https://github.com/COMBINE-lab/SalmonTools.git
ENV PATH=/home/.local/src/SalmonTools/scripts:${PATH}

# Install mashmap, gffread, and bedtools
RUN conda install -c bioconda -y \
    mashmap=2.0 \
    gffread=0.11.6 \
    bedtools=2.29.1

# Install minus80 and locuspocus
RUN pip install minus80 locuspocus

COPY . /home/RNAMapping 
WORKDIR /home/RNAMapping

ENTRYPOINT ["/usr/bin/zsh"]
