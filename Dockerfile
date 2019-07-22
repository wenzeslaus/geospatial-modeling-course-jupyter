# Copyright (C) Vaclav Petras.
# Distributed under the terms of the BSD 2-Clause License.

FROM jupyter/scipy-notebook:7a3e968dd212

MAINTAINER Vaclav Petras <wenzeslaus@gmail.com>

USER root

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
    software-properties-common curl \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update \
    && apt-get install -y grass grass-dev \
    && apt-get autoremove \
    && apt-get clean

# Create a Python 2.x environment using conda including
# the ipython kernel # and the kernda utility.
# Add any additional packages to be used in Python 2 notebook should go
# on the second line here after kernda.
# This particular command does not require root, but the ones around
# it do.
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
        ipython ipykernel kernda matplotlib && \
    conda clean --all -f -y

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
$CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json

USER $NB_USER

WORKDIR /home/$NB_USER

RUN mkdir -p /home/$NB_USER/grassdata \
  && curl -SL https://grass.osgeo.org/sampledata/north_carolina/nc_spm_08_grass7.tar.gz > nc_spm_08_grass7.tar.gz \
  && tar -xvf nc_spm_08_grass7.tar.gz \
  && mv nc_spm_08_grass7 /home/$NB_USER/grassdata \
  && rm nc_spm_08_grass7.tar.gz

WORKDIR /home/$NB_USER/work

COPY notebooks/* ./

# there is some problem or bug with permissions
USER root
RUN chown -R $NB_USER:users .
USER $NB_USER
