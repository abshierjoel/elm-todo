#node image
FROM node


#working directory
WORKDIR /usr/src/todo-api

#Clone Git Repo
#RUN apt-get update
#RUN apt-get install -y git
#RUN git clone https://github.com/abshierjoel/elm-todo.git .
COPY . . 

#setup node
RUN npm install

#setup elm
RUN npm i elm
RUN npm i elm-test

#EXPOSE
EXPOSE 8080

#RUN
CMD ["node", "app.js"]
