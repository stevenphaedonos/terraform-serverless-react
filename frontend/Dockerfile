FROM node

COPY package.json package-lock.json ./
RUN npm install

ADD ./ /frontend
WORKDIR /frontend
ENV PATH /node_modules/.bin:$PATH

EXPOSE 3000
