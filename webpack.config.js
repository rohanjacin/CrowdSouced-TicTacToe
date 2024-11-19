const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const path = require('path');

module.exports = env => {
    console.log("env.admin:", env.admin);
    return {
    entry: env.admin ? __dirname + "/index-admin.js" : (env.player1 ? __dirname + "/index-player1.js" : env.player2 ? __dirname + "/index-player2.js" : __dirname + "/index.js"),
    mode: 'development',
    output: {
      path: path.resolve(__dirname, './dist'),
      filename: 'index_bundle.js',
    },
    target: 'web',
    devServer: {
      port: env.admin ? '5000' : (env.player1 ? '5001' : env.player2 ? '5002' : '5003'),
      static: {
        directory: path.join(__dirname, 'public')
      },
      open: true,
      hot: true,
      liveReload: true,
    },
    resolve: {
      extensions: ['.js', '.jsx', '.json'],
    },
    module: {
      rules: [
        {
          test: /\.(js|jsx)$/, 
          exclude: /node_modules/, 
          use: 'babel-loader', 
        },
        {
          test: /\.css$/i,
          use: ["style-loader", "css-loader"],
        },
      ],
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.join(__dirname, 'public', 'index.html')
      }),

      new webpack.DefinePlugin({
        //process: {env: {}}
      })    
    ]
  };
}
