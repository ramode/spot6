import '@mdi/font/css/materialdesignicons.css' // Ensure you are using css-loader
import 'material-design-icons-iconfont/dist/material-design-icons.css' // Ensure you are using css-loader

import Vue from 'vue'
import Vuetify, { VListItemIcon } from 'vuetify/lib'

/*
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
*/

import theme from './theme'

import en from 'vuetify/src/locale/en.ts'
import ru from 'vuetify/src/locale/ru.ts'

/*
Vue.use(Vuetify, {
  iconfont: 'mdi',
    lang: {
        locales: { en,ru },
        current: localStorage.getItem('lang') || 'ru'
    },
  theme
})
*/

const vuetifyOptions = {

  icons: {
    iconfont: 'mdi'
    // iconfont: 'mdiSvg',
  },
  lang: {
    locales: { en, ru },
    current: localStorage.getItem('lang') || 'ru'
  },
  theme
}

Vue.use(Vuetify, {
  components: {
    VListItemIcon
  }
})

export default new Vuetify(vuetifyOptions)
