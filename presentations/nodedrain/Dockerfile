FROM node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

ENV PATH=$PATH:/home/node/.npm-global/bin 

USER node

WORKDIR /home/node/app

RUN npm install -g reveal-md

COPY . /home/node/app

ENTRYPOINT ["reveal-md"]

CMD ["slides.md", "--theme", "theme.css"]