import Vue from 'vue'
import Vuetify from 'vuetify'
import theme from './theme'
import 'vuetify/dist/vuetify.min.css'
import '@mdi/font/css/materialdesignicons.css'


import en from 'vuetify/src/locale/en.ts'
import ru from 'vuetify/src/locale/ru.ts'



Vue.use(Vuetify, {
  iconfont: 'mdi',
    lang: {
        locales: { en,ru },
        current: localStorage.getItem('lang') || 'ru'
    },
  theme
})


