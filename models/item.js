const mongoose = require('mongoose');

let item = new mongoose.Schema(
  {
    listId: { type: String },
    task: { type: String },
  },
  { collection: 'items' }
);

module.exports = mongoose.model('items', item);
