FROM amazonlinux:2.0.20190228

RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs
RUN npm install -g serverless@1.66.0
COPY package.json package-lock.json ./
RUN npm install

RUN yum install -y gcc python3-devel.x86_64

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

ADD ./ /backend
WORKDIR /backend

ENV PATH /node_modules/.bin:$PATH

EXPOSE 5000
