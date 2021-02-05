// const { CleanWebpackPlugin } = require('clean-webpack-plugin');
// const HtmlWebpackPlugin = require('html-webpack-plugin');
// const WebpackNodeExternals = require('webpack-node-externals');
// const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// const path = require('path');
// const fs = require('fs');

// module.exports = {
//   entry: { index: './src/index.js', app: './server.js' },
//   target: 'node',
//   output: {
//     filename: '[name].bundle.js',
//     path: path.resolve(__dirname, 'public/dist'),
//   },
//   resolve: {
//     extensions: ['.js', '.jsx', '.elm'],
//   },
//   plugins: [
//     new CleanWebpackPlugin(),
//     new HtmlWebpackPlugin({
//       title: 'Output Management',
//     }),
//   ],
//   module: {
//     rules: [
//       {
//         test: /\.(js|jsx)$/,
//         exclude: /node_modules/,
//         use: {
//           loader: 'babel-loader',
//         },
//       },
//       {
//         test: /\.html$/,
//         use: [{ loader: 'html-loader' }],
//       },
//       {
//         test: /\.elm$/,
//         exclude: [/elm-stuff/, /node_modules/],
//         use: {
//           loader: 'elm-webpack-loader',
//           options: {},
//         },
//       },
//       {
//         test: /\.(scss|css)$/i,
//         use: ['style-loader', 'css-loader', 'sass-loader'],
//       },
//       {
//         test: /\.(png|svg|jpg|jpeg|gif)$/i,
//         type: 'asset/resource',
//       },
//       {
//         test: /\.(woff|woff2|eot|ttf|otf)$/i,
//         use: {
//           loader: 'url-loader',
//         },
//       },
//     ],
//   },
// };
