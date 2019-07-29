import Vue from 'vue'

// Lib imports
import axios from 'axios'
import VueAxios from 'vue-axios'

//Vue.prototype.$http = axios

// https://github.com/websanova/vue-auth/blob/master/docs/Installation.md
Vue.use(VueAxios, axios)

// https://github.com/websanova/vue-auth/blob/master/docs/StepByStepGuide.md
Vue.axios.defaults.baseURL = '/api/v1/'
axios.defaults.headers.common['Prefer'] = 'return=representation'
