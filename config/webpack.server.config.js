const WebpackNodeExternals = require('webpack-node-externals');
const path = require('path');

module.exports = {
  target: 'node',
  entry: { server: './server.js' },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, '../server'),
  },
  // externals: [WebpackNodeExternals()],
};
