module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  query:
  {
    plugins: ['transform-decorators-legacy' ],
    presets: ['es2015', 'stage-0', 'react']
  }
}
