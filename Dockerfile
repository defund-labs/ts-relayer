FROM node:16 as base

RUN git clone https://github.com/defund-labs/ts-relayer

WORKDIR /ts-relayer

COPY ./scripts/entrypoint.sh /

RUN chmod +x /entrypoint.sh

RUN npm install

RUN npm run build

RUN npm link

CMD ["/bin/bash", "/entrypoint.sh"]