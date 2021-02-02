const mongoose = require('mongoose');

let todoList = new mongoose.Schema(
  {
    owner: { type: String },
    isDark: { type: Boolean },
  },
  { collection: 'todoLists' }
);

module.exports = mongoose.model('todoLists', todoList);
