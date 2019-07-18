module.exports = {
  devServer: {
    disableHostCheck: true,
    proxy: {
      '/api/v1/': {
        target: 'http://localhost:5000',
        ws: true,
        pathRewrite: {
          '^/api/v1':""
        }
      },
      '/uam/': {
        target: 'http://localhost:8017',
        ws: true
      },
    },
    disableHostCheck: true

  }
}
