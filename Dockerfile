# Copyright (C) Vaclav Petras.
# Distributed under the terms of the BSD 2-Clause License.

FROM jupyter/scipy-notebook:1386e2046833

MAINTAINER Vaclav Petras <wenzeslaus@gmail.com>

USER root

RUN apt-get update && apt-get install -y \
    software-properties-common curl \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update \
    && apt-get install -y grass grass-dev \
    && apt-get autoremove \
    && apt-get clean

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
