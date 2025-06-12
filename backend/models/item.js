const mongoose = require('mongoose');

const itemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  quantity: Number
});

module.exports = mongoose.model('Item', itemSchema);

