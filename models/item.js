const mongoose = require('mongoose');

let item = new mongoose.Schema(
  {
    listId: { type: String },
    task: { type: String, default: '' },
    description: { type: String, default: '' },
    complete: { type: Boolean, default: false },
  },
  { collection: 'items' }
);

module.exports = mongoose.model('items', item);
