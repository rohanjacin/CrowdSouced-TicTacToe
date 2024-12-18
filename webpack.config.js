const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const path = require('path');

module.exports = env => {
    console.log("env.admin:", env.admin);
    return {
    entry: env.admin ? __dirname + "/index-admin.js" : __dirname + "/index-player.js",
    mode: 'development',
    output: {
      path: path.resolve(__dirname, './dist'),
      filename: 'index_bundle.js',
    },
    target: 'web',
    devServer: {
      //port: env.admin,
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
