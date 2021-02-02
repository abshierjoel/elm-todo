require('dotenv').config();

const express = require('express');
const app = express();

const mongoose = require('mongoose');
const todoLists = require('./models/todoList');
const items = require('./models/item');
const { ObjectID } = require('mongodb');

app.use(express.static('public'));
app.use(express.json());

/********* MONGO *********/
const uri = process.env.MONGO_URI;

mongoose.connect(uri, { useUnifiedTopology: true, useNewUrlParser: true });
const connection = mongoose.connection;

connection.once('open', () => console.log('MongoDB is hooked up!'));

/********* ROUTES *********/

app.get('/', (req, res) => {
  res.sendFile('/index.html');
});

var router = express.Router();

// Lists

router.get('/list/:owner', (req, res) => {
  if (!req.params.owner) res.status(400).send();

  todoLists.findOne({ owner: req.params.owner }, (err, result) => {
    if (err) res.send(err);
    else if (result == null) res.status(404).send();
    else res.json(result);
  });
});

router.post('/list/:owner', (req, res) => {
  if (!req.params.owner) res.status(400).send();

  todoLists
    .countDocuments({ owner: req.params.owner }, (err, count) => count > 0)
    .then((exists) => {
      if (exists) {
        res.status(409).send();
      } else {
        const newList = {
          owner: req.params.owner,
          isDark: true,
        };

        todoLists.create(newList, (err, result) => {
          if (err) res.status(500).send();
          else res.status(204).send();
        });
      }
    });
});

router.put('/list/darkmode/:listId', (req, res) => {
  if (!req.params.listId) res.status(400).send();

  const query = { _id: ObjectID(req.params.listId) };
  const update = { isDark: req.body.isDark };

  todoLists.updateOne(query, { $set: update }, (err, result) => {
    if (err) res.send(err);
    else res.status(204).send();
  });
});

//Items

router.get('/items/:listId', (req, res) => {
  if (!req.params.listId) res.status(400).send();

  items.find({ listId: req.params.listId }, (err, result) => {
    if (err) res.send(err);
    else res.json(result);
  });
});

//Item

router.post('/item/:listId', (req, res) => {
  if (!req.params.listId || !req.body.task) res.status(400).send();

  const query = { listId: req.params.listId, task: req.body.task };

  items.create(query, (err, result) => {
    if (err) res.status(500).send();
    else res.status(204).send();
  });
});

router.delete('/item/:itemId', (req, res) => {
  if (!req.params.itemId) res.status(400).send();

  items.deleteOne({ _id: req.params.itemId }, (err, result) => {
    if (err) res.status(500).send();
    else res.status(204).send();
  });
});

router.put('/item/:itemId', (req, res) => {
  if (!req.params.itemId) res.status(400).send();

  const query = { _id: ObjectID(req.params.itemId) };
  const update = { task: req.body.task };

  items.updateOne(query, { $set: update }, (err, result) => {
    if (err) res.send(err);
    else res.status(204).send();
  });
});

app.use('/api', router);

/********* START *********/

app.listen(8080);
