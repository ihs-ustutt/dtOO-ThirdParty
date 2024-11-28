FROM alpine/git AS repo
WORKDIR /
RUN git clone https://github.com/ihs-ustutt/dtOO-ThirdParty.git
COPY . /dtOO-ThirdParty.local
WORKDIR /dtOO-ThirdParty
ARG GIT_REV=main
RUN git checkout ${GIT_REV}
WORKDIR /

FROM opensuse/leap:15.5 AS base
ARG CBASE=
COPY --from=repo /dtOO-ThirdParty${CBASE} /dtOO-ThirdParty

RUN zypper --non-interactive \
  addrepo \
  https://download.opensuse.org/repositories/science/15.5/science.repo
RUN zypper --non-interactive \
  addrepo \
  https://download.opensuse.org/repositories/devel:tools:building/15.5/devel:tools:building.repo
RUN zypper --non-interactive \
  addrepo \
  https://download.opensuse.org/repositories/devel:libraries:c_c++/15.5/devel:libraries:c_c++.repo
RUN zypper --gpg-auto-import-keys refresh

RUN zypper -n install \
  openssh git \ 
  cmake make automake cmake-gui autogen autoconf libtool patch \
  libQt5Core-devel libQt5Xml-devel \
  gsl-devel libboost_system1_66_0-devel libboost_timer1_66_0-devel \
  libboost_filesystem1_66_0-devel libboost_program_options1_66_0-devel \
  libboost_regex1_66_0-devel libboost_thread1_66_0-devel \
  swig-4.3.0 \
  gzip \
  freetype2-devel tk-devel Mesa-libGL-devel fontconfig-devel \
  libXext-devel libXmu-devel libXi-devel \
  python311 python311-devel python311-numpy \
  python311-pip  \
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
  openfoam2312-tutorials \
  nlohmann_json-devel

ENV CC=/usr/bin/gcc-12
ENV CXX=/usr/bin/g++-12
ENV FC=/usr/bin/gfortran-12

RUN git clone https://github.com/ihs-ustutt/foamFine.git

WORKDIR /dtOO-ThirdParty
ENV DTOO_EXTERNLIBS=/dtOO-install
ARG NCPU=2
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o cgns -tee
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o openmesh -tee
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o openvolumemesh -tee
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o gmsh -tee
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o moab -tee

WORKDIR /foamFine/of
RUN . /usr/lib/openfoam/openfoam2312/etc/bashrc && wmake all
RUN ln -s /root/OpenFOAM/user-2312 /root/OpenFOAM/root-2312

RUN touch /root/.bashrc
RUN echo "source /usr/lib/openfoam/openfoam2312/etc/bashrc" >> /root/.bashrc
ENV FOAMFINE_DIR=/foamFine

RUN pip3.11 install pyfoam
RUN pip3.11 install oslo.concurrency 
RUN pip3.11 install scikit-learn

ENV PATH=/dtOO-install/bin:$PATH

FROM base AS base-prod
COPY --from=base /bin             /bin
COPY --from=base /boot            /boot
COPY --from=base /dev             /dev
COPY --from=base /dtOO-install    /dtOO-install
COPY --from=base /etc             /etc
COPY --from=base /foamFine        /foamFine
COPY --from=base /home            /home
COPY --from=base /lib             /lib
COPY --from=base /lib64           /lib64
COPY --from=base /mnt             /mnt
COPY --from=base /opt             /opt
COPY --from=base /proc            /proc
COPY --from=base /root            /root
COPY --from=base /run             /run
COPY --from=base /sbin            /sbin
COPY --from=base /selinux         /selinux
COPY --from=base /srv             /srv
COPY --from=base /sys             /sys
COPY --from=base /tmp             /tmp
COPY --from=base /usr             /usr
COPY --from=base /var             /var

FROM base AS ext
COPY --from=base / /
RUN zypper -n install \
  libQt5OpenGL-devel libQt5Widgets-devel libQt5Network-devel \
  libQt5Svg-devel libqt5-qtxmlpatterns-devel libqt5-qttools-devel

WORKDIR /dtOO-ThirdParty
ARG NCPU
RUN sh buildDep -i ${DTOO_EXTERNLIBS} -n ${NCPU} -o paraview -tee
WORKDIR /

FROM ext AS ext-prod
COPY --from=base /bin             /bin
COPY --from=base /boot            /boot
COPY --from=base /dev             /dev
COPY --from=base /dtOO-install    /dtOO-install
COPY --from=base /etc             /etc
COPY --from=base /foamFine        /foamFine
COPY --from=base /home            /home
COPY --from=base /lib             /lib
COPY --from=base /lib64           /lib64
COPY --from=base /mnt             /mnt
COPY --from=base /opt             /opt
COPY --from=base /proc            /proc
COPY --from=base /root            /root
COPY --from=base /run             /run
COPY --from=base /sbin            /sbin
COPY --from=base /selinux         /selinux
COPY --from=base /srv             /srv
COPY --from=base /sys             /sys
COPY --from=base /tmp             /tmp
COPY --from=base /usr             /usr
COPY --from=base /var             /var
WORKDIR /
