module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  query:
  {
    plugins: [
      'transform-decorators-legacy',
      'babel-plugin-transform-runtime',
      ['contracts', {
        'env': {
          'production': {
            'strip': true
          }
        }
      }]
    ],
    presets: ['es2015', 'stage-1', 'react']
  }
}
