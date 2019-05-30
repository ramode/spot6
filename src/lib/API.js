import Vue from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)

export default {

	getRoles() {
		return axios.get('/roles');
	},

	getUsers() {
		return axios.get('/users');
	},

	getUser(user_id) {
		return axios.get(`/users?id=eq.${user_id}`);
	},

	addUser(data) {
		// var config = {
		// 	headers: {
		// 		"Prefer": "return=minimal",
		// 	},
		// };
		// return axios.post("/users", data, config);
		return axios.post("/users", data);
	},

	updateUser(data) {
		var user_id = data.id;
		return axios.patch(`/users?id=eq.${user_id}`, data);
	},

}