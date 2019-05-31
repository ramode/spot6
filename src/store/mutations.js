// https://vuex.vuejs.org/en/mutations.html

export default {

  addNotify(state, data) {
  	state.notifications.unshift(data);
  },
  clearNotifys(state) {
  	state.notifications = [];
  },
  error(state, err) {
  	// console.log(err);
  	var text = `${err.response.status}: ${err.response.data.message}`;
  	state.notifications.unshift(text);
  },
}
