module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  query: {
    plugins: ['transform-decorators-legacy', 'babel-plugin-transform-runtime' ],
    presets: ['es2015', 'stage-1', 'react']
  }
}
