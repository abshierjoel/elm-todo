import express from 'express';
import todoLists from './models/todoList';
import items from './models/item';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { ObjectID } from 'mongodb';

dotenv.config();

const app = express();

app.use(express.static('public'));
app.use(express.json());

/********* MONGO *********/
const uri = process.env.MONGO_URI;

mongoose.connect(uri, { useUnifiedTopology: true, useNewUrlParser: true });
const connection = mongoose.connection;

connection.once('open', () => console.log('MongoDB is hooked up!'));

/********* ROUTES *********/

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

var router = express.Router();

// Lists

router.get('/list/:owner', (req, res) => {
  if (!req.params.owner) {
    res.status(400).send();
    return;
  }

  todoLists.findOne({ owner: req.params.owner }, (err, result) => {
    if (err) res.send(err);
    else if (result == null) res.status(404).send();
    else res.json(result);
  });
});

router.post('/list/:owner', (req, res) => {
  if (!req.params.owner) {
    res.status(400).send();
    return;
  }

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
  if (!req.params.listId) {
    res.status(400).send();
    return;
  }

  const query = { _id: ObjectID(req.params.listId) };
  const update = { isDark: req.body.isDark };

  todoLists.updateOne(query, { $set: update }, (err, result) => {
    if (err) res.send(err);
    else res.status(204).send();
  });
});

//Items

router.get('/items/:listId', (req, res) => {
  if (!req.params.listId) {
    res.status(400).send();
    return;
  }

  items.find({ listId: req.params.listId }, (err, result) => {
    if (err) res.send(err);
    else res.json(result);
  });
});

//Item

router.post('/item/:listId', (req, res) => {
  if (!req.params.listId || !req.body.task || req.body.task === '') {
    res.status(400).send();
    return;
  }

  const query = {
    listId: req.params.listId,
    task: req.body.task,
    description: req.body.description,
  };

  items.create(query, (err, result) => {
    if (err) res.status(500).send();
    else res.status(204).send();
  });
});

router.delete('/item/:itemId', (req, res) => {
  if (!req.params.itemId) {
    res.status(400).send();
    return;
  }

  items.deleteOne({ _id: req.params.itemId }, (err, result) => {
    if (err) res.status(500).send();
    else res.status(204).send();
  });
});

router.put('/item/:itemId', (req, res) => {
  if (!req.params.itemId) {
    res.status(400).send();
    return;
  }

  const getBody = (body) => {
    if (body.task && body.description)
      return { task: body.task, description: body.description };
    else if (body.complete !== undefined) return { complete: body.complete };
    else return null;
  };

  const update = getBody(req.body);

  if (!update) {
    res.status(400).send();
    return;
  }

  const query = { _id: ObjectID(req.params.itemId) };

  items.updateOne(query, { $set: update }, (err, result) => {
    if (err) res.send(err);
    else res.status(204).send();
  });
});

app.use('/api', router);

/********* START *********/

app.listen(8080);
