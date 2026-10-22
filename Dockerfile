FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git pkg-config ca-certificates \
    libprotobuf-dev protobuf-compiler libleveldb-dev libsnappy-dev \
    libhdf5-serial-dev libboost-all-dev libopenblas-dev \
    libgflags-dev libgoogle-glog-dev liblmdb-dev libopencv-dev \
    python3-dev python3-numpy python3-scipy python3-skimage \
    python3-matplotlib python3-h5py python3-pandas python3-networkx \
    python3-yaml python3-protobuf python3-six python3-dateutil \
    python3-pil python3-nose python3-gflags \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 https://github.com/BVLC/caffe.git
WORKDIR /opt/caffe

RUN cp Makefile.config.example Makefile.config \
 && sed -i 's/^# CPU_ONLY := 1/CPU_ONLY := 1/' Makefile.config \
 && sed -i 's/^# OPENCV_VERSION := 3/OPENCV_VERSION := 3/' Makefile.config \
 && sed -i 's/^# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/' Makefile.config \
 && sed -i 's/^BLAS := atlas/BLAS := open/' Makefile.config \
 && printf '%s\n' \
    'PYTHON_INCLUDE := /usr/include/python3.8 /usr/lib/python3/dist-packages/numpy/core/include' \
    'PYTHON_LIBRARIES := boost_python38 python3.8' \
    'INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial /usr/include/opencv4' \
    'LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu/hdf5/serial' \
    >> Makefile.config

RUN sed -i 's/catch (bp::error_already_set)/catch (bp::error_already_set\&)/' \
      tools/caffe.cpp src/caffe/layer_factory.cpp \
 && grep -rlE 'CV_LOAD_IMAGE_(COLOR|GRAYSCALE|ANYDEPTH|UNCHANGED)' src include tools \
    | xargs sed -i -E 's/CV_LOAD_IMAGE_(COLOR|GRAYSCALE|ANYDEPTH|UNCHANGED)/cv::IMREAD_\1/g'

RUN make all -j"$(nproc)" && make pycaffe -j"$(nproc)"
RUN echo "/opt/caffe/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

ENV PYTHONPATH=/opt/caffe/python
ENV PATH=/opt/caffe/build/tools:$PATH
WORKDIR /work
CMD ["bash"]
