########
# This image compile the dependencies
########
FROM python:3.8-slim as compile-image

ENV VIRTUAL_ENV /srv/venv
ENV PATH "${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR /srv

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    binutils \
    build-essential \
    libpq-dev \
    && apt-get autoremove --purge -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv ${VIRTUAL_ENV}

COPY requirements requirements
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements/base.txt

# TODO(vmttn): install from pypi
COPY ["setup.py", "README.md", "/srv/"]
COPY src /srv/src
RUN pip install --no-cache-dir .

########
# This image is the runtime
########
FROM python:3.8-slim as runtime-image

ARG VERSION_SHA
ARG VERSION_NAME
ENV VERSION_SHA $VERSION_SHA
ENV VERSION_NAME $VERSION_NAME

ENV VIRTUAL_ENV /srv/venv
ENV PATH "${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR /srv

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y git rsync \
    && apt-get autoremove --purge -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy venv with compiled dependencies
COPY --from=compile-image /srv/venv /srv/venv

COPY "docker-entrypoint.sh" "/srv/"
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["/srv/docker-entrypoint.sh"]