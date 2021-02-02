#node image
FROM node

#working directory
WORKDIR /usr/src/todo-api

#Clone Git Repo
COPY . . 

#setup node
RUN npm install

#setup elm
RUN npm i elm
RUN npm i elm-test

#build
RUN npm run build

#EXPOSE
EXPOSE 8080

#RUN
CMD ["node", "app.js"]
