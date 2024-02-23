FROM opensuse/leap:15.5

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/science/15.5/science.repo
RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/devel:tools:building/15.5/devel:tools:building.repo
RUN zypper --gpg-auto-import-keys refresh

RUN zypper -n install \
  openssh git \ 
  cmake make automake cmake-gui autogen autoconf libtool patch \
  libQt5Core-devel libQt5Xml-devel \
  gsl-devel libboost_system1_66_0-devel libboost_timer1_66_0-devel \
  libboost_filesystem1_66_0-devel libboost_program_options1_66_0-devel \
  libboost_regex1_66_0-devel libboost_thread1_66_0-devel \
  swig-4.1.1 \
  gzip \
  freetype2-devel tk-devel Mesa-libGL-devel fontconfig-devel \
  libXext-devel libXmu-devel libXi-devel \
  python3 python3-devel python3-numpy \
  python python-devel \
  vim \
  gcc12-fortran gcc12-c++ gcc12 \
  gmp-devel \
  root6 root6-devel Minuit2-devel \
  muparser-devel \
  cgal-devel \
  occt-devel \
  openfoam2312 openfoam2312-common openfoam2312-default \
  openfoam2312-devel openfoam2312-doc openfoam2312-tools \
  openfoam2312-tutorials

ENV CC=/usr/bin/gcc-12
ENV CXX=/usr/bin/g++-12
ENV FC=/usr/bin/gfortran-12

ENV NCPU=2

WORKDIR /
RUN git clone https://github.com/ihs-ustutt/dtOO-ThirdParty.git 
RUN git clone https://github.com/ihs-ustutt/foamFine.git

WORKDIR /dtOO-ThirdParty
ENV DTOO_EXTERNLIBS=/dtOO-install
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o cgns
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o openmesh
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o openvolumemesh
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o gmsh
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o moab
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o nlohmann_json

WORKDIR /foamFine/of
RUN . /usr/lib/openfoam/openfoam2312/etc/bashrc && wmake all
RUN ln -s /root/OpenFOAM/user-2312 /root/OpenFOAM/root-2312

RUN touch /root/.bashrc
RUN echo "source /usr/lib/openfoam/openfoam2312/etc/bashrc" >> /root/.bashrc
ENV FOAMXDOGBALL_DIR=/foamFine

WORKDIR /
