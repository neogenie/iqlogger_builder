ARG UBUNTU_VERSION=ubuntu18

FROM neogenie/v8:$UBUNTU_VERSION

ENV GCC_VERSION 9
ENV BOOST_VERSION "1.71.0"
ENV RAPIDJSON_VERSION "1.1.0"
ENV RAPIDJSON_ROOT /usr/include/rapidjson

ENV BUILD_DIR /tmp/build

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get update && apt-get upgrade -y && apt-get install -y  \
    build-essential \
    gcc-${GCC_VERSION} \
    git \
    g++-${GCC_VERSION} \
    curl \
    cmake \
    wget \
    dpkg \
    debconf \
    debhelper \
    autotools-dev \
    autoconf \
    lintian \
    zlib1g-dev \
    libsystemd-dev \
    libevent-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libiberty-dev \
    liblz4-dev \
    liblzma-dev \
    libsnappy-dev \
    make \
    libtool \
    autoconf \
    automake \
    unzip \
    zlib1g-dev \
    binutils-dev \
    libjemalloc-dev \
    libssl-dev \
    pkg-config \
    ruby \
    ruby-dev \
    rubygems \
    python-dev \
    libcurl4-openssl-dev \
    libtbb-dev \
    python \
    pkg-config && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 60 --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} && \
    update-alternatives --config gcc && \
    rm -rf /var/lib/apt/lists/*

RUN gem install --no-ri --no-rdoc fpm

SHELL ["/bin/bash", "-c"]

RUN mkdir ${BUILD_DIR}

# Boost
RUN cd ${BUILD_DIR} && \
    export BOOST_VERSION_=${BOOST_VERSION//./_} && \
    wget --no-check-certificate --max-redirect 3 https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_}.tar.gz && \
    tar zxf boost_${BOOST_VERSION_}.tar.gz -C . --strip-components=1 && \
    ./bootstrap.sh && ./b2 install

# spdlog
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/gabime/spdlog.git && \
    cd spdlog && mkdir build && cd build && \
    cmake .. && make && make install

# rapidjson
RUN cd ${BUILD_DIR} && \
    git clone -b v${RAPIDJSON_VERSION} https://github.com/Tencent/rapidjson.git && \
    cp -r rapidjson/include/rapidjson ${RAPIDJSON_ROOT}

# concurrentqueue
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/cameron314/concurrentqueue.git && \
    mkdir /usr/include/concurrentqueue && cp -r concurrentqueue/*.h /usr/include/concurrentqueue/

# nlohmann json
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/nlohmann/json.git && \
    cd json && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release .. && \
    make install

# frozen
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/serge-sans-paille/frozen.git && \
    cd frozen && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release .. && \
    make install

# prometheus cpp
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/jupp0r/prometheus-cpp.git && \
    cd prometheus-cpp && \
    git submodule init && \
    git submodule update && \
    mkdir build && cd build && \
    cmake .. -DBUILD_SHARED_LIBS=OFF && \
    make -j $(nproc) && \
    make install

# simdjson
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/lemire/simdjson.git && \
    cd simdjson && \
    mkdir buildstatic && \
    cd buildstatic && \
    cmake -DSIMDJSON_BUILD_STATIC=ON .. && \
    make && \
    make test && \
    make install

RUN rm -rf ${BUILD_DIR}
