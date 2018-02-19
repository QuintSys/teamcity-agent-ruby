FROM jetbrains/teamcity-minimal-agent:latest

ENV RUBY_VERSION=2.4.3 \
    RUBYGEMS_VERSION=2.7.5 \
    BUNDLER_VERSION=1.16.1 

ENV SOURCE_RVM="source /usr/share/rvm/scripts/rvm" \
    RUBY_INSTALL="rvm install ${RUBY_VERSION}" \
    GEM_UPDATE="gem update --system ${RUBYGEMS_VERSION}" \
    BUNDLER_INSTALL="gem install bundler --version ${BUNDLER_VERSION} --force"

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \   
    && apt-add-repository -y ppa:rael-gc/rvm \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        rvm \
        nodejs \ 
        yarn \
	&& rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/ \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /etc/gemrc \ 
    && (grep -q -E '^mesg n$' /root/.profile && sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile) || exit 0 \
    && /bin/bash -l -c "${SOURCE_RVM} && ${RUBY_INSTALL}" \ 
    && /bin/bash -l -c "${GEM_UPDATE}" \ 
    && /bin/bash -l -c "${SOURCE_RVM} && ${BUNDLER_INSTALL}"

CMD /bin/bash -c "${SOURCE_RVM} && source run-services.sh"