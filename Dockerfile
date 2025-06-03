ARG PULL_MODEL=qwen2.5vl:7b

# Use an official base image with your desired version
FROM ollama/ollama:0.9.0

ARG PULL_MODEL

ENV PYTHONUNBUFFERED=1 

# Set up the working directory
WORKDIR /

RUN apt-get update --yes --quiet && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    software-properties-common \
    gpg-agent \
    build-essential apt-utils \ 
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install --reinstall ca-certificates

# PYTHON 3.11
RUN add-apt-repository --yes ppa:deadsnakes/ppa && apt update --yes --quiet

RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-lib2to3 \
    python3.11-gdbm \
    python3.11-tk \
    pip
    
RUN whereis python

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 999 \
    && update-alternatives --config python3 && ln -s /usr/bin/python3 /usr/bin/python
    
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

RUN pip install --upgrade pip

# Add your files
ADD start.sh .
ADD runpod_wrapper.py .

RUN pip install runpod

# Override Ollama's entrypoint
ENTRYPOINT ["bin/bash", "start.sh"]

CMD ["qwen2.5vl:7b"]

