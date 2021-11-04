# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.
FROM python:3.8-buster

MAINTAINER Anthony Castanza <acastanza@cloud.ucsd.edu>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN mkdir /src

# install system dependencies
RUN apt-get update --yes
RUN apt-get install build-essential --yes
RUN apt-get install libcurl4-gnutls-dev --yes
RUN apt-get install libhdf5-serial-dev --yes
# RUN apt-get install libigraph0-dev --yes #This should install automatically with python-igraph as the repo version fails
RUN apt-get install libxml2-dev --yes

# Install samtools
RUN apt-get install samtools --yes

# install python with conda
RUN mkdir /conda && \
    cd /conda && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda
ENV PATH="/opt/conda/bin:${PATH}"

# install R dependencies

# install python dependencies
RUN pip install numpy
RUN pip install scipy
RUN pip install cython
RUN pip install numba
RUN pip install matplotlib
RUN pip install scikit-learn
RUN pip install h5py
RUN pip install click
RUN pip install pysam
RUN pip install velocyto

# copy module files
COPY src/* /src/
RUN chmod a+x /src/preprocess.sh

# display software versions
RUN python --version
RUN pip --version

# default command
CMD ["velocyto --version"]
