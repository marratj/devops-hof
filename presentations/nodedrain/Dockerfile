FROM node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

ENV PATH=$PATH:/home/node/.npm-global/bin 

USER node

COPY . /home/node/app

WORKDIR /home/node/app

RUN npm install -g reveal-md

ENTRYPOINT ["reveal-md"]

CMD ["slides.md", "--theme", "theme.css"]