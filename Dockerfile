FROM jenkins/ssh-agent:latest-jdk21

USER root

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    unzip

RUN apt-get update && apt-get install -y iputils-ping

# Crear un entorno virtual
RUN python3 -m venv /opt/venv

# Activar el entorno virtual y luego instalar requirements
COPY ./requirements.txt ./
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install -r requirements.txt

# Agregar el entorno virtual al PATH
ENV PATH="/opt/venv/bin:$PATH"
