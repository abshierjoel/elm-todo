const express = require('express');
const app = express();

app.use(express.static('public'));
app.use(express.json());

/********* MOCK *********/

const lists = {
  joel: ['work', 'cook', 'dig'],
  kendall: ['work', 'cook', 'dig'],
  chris: ['work', 'cook', 'dig'],
  fred: ['work', 'cook', 'dig'],
  adam: ['work', 'cook', 'dig'],
  shahn: ['work', 'cook', 'dig'],
  sam: ['work', 'cook', 'dig'],
  amy: ['work', 'cook', 'dig'],
};

/********* ROUTES *********/

app.get('/', (req, res) => {
  res.sendFile('/index.html');
});

var router = express.Router();

router.get('/items/:list_id', (req, res) => {
  if (!lists.hasOwnProperty(req.params.list_id)) res.status(404).send();
  else res.json(lists[req.params.list_id]);
});

router.post('/item', (req, res) => {
  if (req.body.list_id) {
    lists[req.body.list_id].push(req.body.item);
    res.status(204).send();
  } else {
    res.status(400).send();
  }
});

app.use('/api', router);

/********* START *********/

app.listen(8080);
