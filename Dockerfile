#node image
FROM node

#working directory
WORKDIR /usr/src/app

#Clone Git Repo
RUN apt-get update
RUN apt-get install -y git

RUN git clone https://github.com/abshierjoel/elm-todo.git .

#setup node
RUN npm install

#EXPOSE
EXPOSE 8080

#RUN
CMD ["node", "app.js"]
