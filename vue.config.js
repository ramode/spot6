const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin')

module.exports = {

  configureWebpack: {
    plugins: [
      new VuetifyLoaderPlugin()
    ]
  },

  /*
configureWebpack: { module: {
  rules: [
    {
      test: /\.s(c|a)ss$/,
      use: [
        'vue-style-loader',
        'css-loader',
        {
          loader: 'sass-loader',
          options: {
            implementation: require('sass'),
            fiber: require('fibers')
          }
        }
      ]
    }
  ]
}},
*/

  devServer: {
    disableHostCheck: true,
    proxy: {
      '/api/v1/': {
        target: 'http://localhost:5000',
        // target: 'https://hs1.eri.su',
        ws: true,
        pathRewrite: {
          '^/api/v1': ''
        }
      },
      '/uam/': {
        // target: 'http://localhost:8017',
        target: 'https://hs1.eri.su',
        ws: true
      }
    },
    disableHostCheck: true

  }
}
