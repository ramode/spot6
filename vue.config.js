module.exports = {
  devServer: {
    disableHostCheck: true,
    proxy: {
      '/api/v1/': {
        // target: 'http://localhost:5000',
        target: 'https://hs1.eri.su',
        ws: true,
        // pathRewrite: {
        //   '^/api/v1':""
        // }
      },
      '/uam/': {
        // target: 'http://localhost:8017',
        target: 'https://hs1.eri.su',
        ws: true
      },
    },
    disableHostCheck: true

  }
}
