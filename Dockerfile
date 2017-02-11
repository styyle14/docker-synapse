FROM ubuntu:latest

ARG username="synapse"
ARG password="${username}"

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get clean && \
	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
		build-essential \
		python2.7-dev \
		libffi-dev \
		python-pip \
		python-setuptools \
		sqlite3 \
		libssl-dev \
		python-virtualenv \
		libjpeg-dev \
		libxslt1-dev \
		wget && \
	pip install --upgrade pip && \
	pip freeze > requirements.txt && \
	pip install --upgrade -r requirements.txt && \
	rm requirements.txt

RUN \
	wget 'https://github.com/matrix-org/synapse/archive/master.tar.gz' && \
	tar -xzvf master.tar.gz && \
	rm -r master.tar.gz && \
	pip install --upgrade ./synapse-master/ && \
	rm -r synapse-master/

RUN \
	apt-get remove -y \
		build-essential \
		wget && \ 
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/* /var/cache/apt/*

RUN \
	useradd \
		--create-home \
		--groups \
			sudo \
		"${username}" && \
	echo "${username}:${password}" | chpasswd

USER "${username}"
VOLUME ["/home/${username}/config"]
WORKDIR "/home/${username}/"
EXPOSE 8448
CMD python -B -m synapse.app.homeserver -c ./config/homeserver.yaml

