ARG PULL_IMAGE="qwen2.5vl:3b"

# Use an official base image with your desired version
FROM ollama/ollama:0.9.0

# Define the model to pull (using the ARG passed during build)
ARG PULL_IMAGE

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

# Pre-pull the Gemma model:
# 1. Start ollama serve in the background (&)
# 2. Wait a few seconds for the server to start (sleep 5)
# 3. Run ollama pull
# 4. (Optional but good practice) Kill the background server process
#    We use 'ps | grep ollama | grep -v grep | awk '{print $1}' | xargs kill' to find and kill the server process
#    Note: Error during kill is ignored (|| true) in case the server exited quickly.
RUN ollama serve & \
    sleep 5 && \
    ollama pull ${PULL_IMAGE} && \
    (ps | grep ollama | grep -v grep | awk '{print $1}' | xargs kill || true)

# Override Ollama's entrypoint
ENTRYPOINT ["bin/bash", "start.sh"]