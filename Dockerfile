FROM python:3.15-slim

# Changes daily in CI so the cached apt/pip layers are rebuilt and pick up security updates.
ARG CACHE_BUST

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends openssh-client sshpass git; \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" "msgpack>=1.2.1"

RUN pip install --no-cache-dir ansible-core

WORKDIR /ansible

COPY ansible.cfg requirements.yml playbook.yml ./
COPY roles ./roles

RUN ansible-galaxy install -r requirements.yml

CMD [ "tail", "-f", "/dev/null" ]
