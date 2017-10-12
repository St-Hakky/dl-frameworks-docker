# versiion
ARG cuda_version=8.0
ARG cudnn_version=5
ARG ubuntu_version=16.04

# base image
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel-ubuntu${ubuntu_version}

# maintainer
MAINTAINER MAINTAINER_NAME <EMAIL

# miniconda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# install miniconda
RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    apt-get update && \
    apt-get install -y wget git libhdf5-dev g++ graphviz openmpi-bin && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh

# user settings
ENV NB_USER user_name
ENV NB_UID 12345
ENV NB_GID 12345

# permission settings
RUN groupadd -g $NB_GID $NB_USER && \
    useradd -m -s /bin/bash -N $NB_USER -u $NB_UID -g $NB_GID && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src

# user name
USER $NB_USER

# python version : CAUTION!! Do not change this value
ARG python_version=3.5

# Install dependent modules
COPY requirements.txt .
RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    pip install https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.3.0-cp35-cp35m-linux_x86_64.whl && \
    pip install https://cntk.ai/PythonWheel/GPU/cntk-2.1-cp35-cp35m-linux_x86_64.whl && \
    conda install Pillow scikit-learn notebook pandas matplotlib mkl nose pyyaml six h5py && \
    conda install -c mila-udem/label/pre theano libgpuarray pygpu bcolz && \
    pip install sklearn_pandas && \
    pip install keras==2.0.8 && \
    pip install https://github.com/Lasagne/Lasagne/archive/master.zip && \
    pip install -r requirements.txt && \
    conda clean -yt

# theano gpu settings
ADD theanorc /home/$NB_USER/.theanorc

# python path
ENV PYTHONPATH='/src/:$PYTHONPATH'

# working directory
WORKDIR /src

# jupyter notebook port
EXPOSE 8888
CMD jupyter notebook --port=8888 --ip=0.0.0.0
