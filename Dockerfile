FROM node:16 as base

RUN git clone https://github.com/defund-labs/ts-relayer

WORKDIR /ts-relayer

RUN npm install

RUN npm run build

RUN npm link

CMD ["/bin/bash", "/ts-relayer/scripts/entrypoint.sh"]