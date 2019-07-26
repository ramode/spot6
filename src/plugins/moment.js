import Vue from 'vue'

// https://github.com/brockpetrie/vue-moment
import VueMoment from 'vue-moment'
import moment from 'moment-timezone'

console.log(moment)

// 2019-06-11:
Vue.use(VueMoment, {
	moment,
})
