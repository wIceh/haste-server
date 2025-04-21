FROM node:16-stretch

RUN mkdir -p /usr/src/app && \
    chown node:node /usr/src/app

USER node:node

WORKDIR /usr/src/app

COPY --chown=node:node . .

RUN npm install && \
    npm install redis@0.8.1 && \
    npm install pg@8.11.3 && \
    npm install memcached@2.2.2 && \
    npm install aws-sdk@2.814.0 && \
    npm install rethinkdbdash@2.3.31

ENV STORAGE_TYPE=sqlite \
    STORAGE_FILEPATH=/usr/src/app/hastebin.db \
    LOGGING_LEVEL=verbose \
    LOGGING_TYPE=Console \
    LOGGING_COLORIZE=true \
    HOST=0.0.0.0 \
    PORT=7777 \
    KEY_LENGTH=10 \
    MAX_LENGTH=400000 \
    STATIC_MAX_AGE=86400 \
    RECOMPRESS_STATIC_ASSETS=true \
    KEYGENERATOR_TYPE=phonetic \
    KEYGENERATOR_KEYSPACE= \
    DOCUMENTS=about=./about.md

EXPOSE ${PORT}
STOPSIGNAL SIGINT
ENTRYPOINT [ "bash", "docker-entrypoint.sh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s \
    --retries=3 CMD [ "sh", "-c", "echo -n 'curl localhost:7777... '; \
    (\ 
        curl -sf localhost:7777 > /dev/null\
    ) && echo OK || (\ 
        echo Fail && exit 2\
    )"]
CMD ["npm", "start"]