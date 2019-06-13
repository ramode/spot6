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

	getProfiles() {
		return axios.get("/profiles");
	},

	getProfile(profile_id) {
		return axios.get(`/profiles?id=eq.${profile_id}`);
	},

	getAuthTypes() {
		return axios.get('/auth_types');
	},

	addProfile(data) {
		data._session_time = data.session_time;
		delete data.session_time;

		return axios.post("/profiles", data);
	},

	updateProfile(data) {
		data._session_time = data.session_time;
		delete data.session_time;

		var profile_id = data.id;
		return axios.patch(`/profiles?id=eq.${profile_id}`, data);
	},

	createInvite() {
	},

	getSettings() {
		return axios.get('/settings');
	},

	updateSettings(data) {
		return axios.patch(`/settings`, data);
	},

	getThemes() {
		return axios.get(`/themes`);
	},

}