import Vue from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.use(VueAxios, axios)

export default {

	Registration(data) {
		// return this.addUser(data);
		if ( data.pass2 ) {
			delete data.pass2;
		};
		return axios.post('/rpc/reg', data);
	},

	getRoles() {
		return axios.get('/roles');
	},

	getUsers() {
		return axios.get('/user_users');
	},
	getGroups() {
		return axios.get('/user_groups');
	},

	getUser(user_id) {
		return axios.get(`/user_users?id=eq.${user_id}`);
	},


    passwdUser(user_id, password) {
        var data = {
            user_id:user_id,
            newpassword: password
        }
        return axios.post("/rpc/passwd", data);
    },

	addUser(data) {
		// var config = {
		// 	headers: {
		// 		"Prefer": "return=minimal",
		// 	},
		// };
		// return axios.post("/users", data, config);
		if ( data.pass2 ) {
			delete data.pass2;
		};
		return axios.post("/user_users", data, {headers:{Prefer: 'return=representation'}});
	},

	updateUser(data) {
		var user_id = data.id;
		return axios.patch(`/user_users?id=eq.${user_id}`, data, {headers:{Prefer: 'return=representation'}});
	},

	getProfiles() {
		return axios.get("/hotspot_profiles");
	},

	getProfile(profile_id) {
		return axios.get(`/hotspot_profiles?id=eq.${profile_id}`);
	},

	getAuthTypes() {
		return axios.get('/auth_types_list');
	},

	getMyAuthTypes() {
		return axios.get('/auth_types');
	},

	getMyAuthType(auth_type_id) {
		return axios.get(`/auth_types?id=eq.${auth_type_id}`);
	},

	addAuthType(data) {
		delete data.id;
		return axios.post('/auth_types', data);
	},

	updateAuthType(data) {
		var auth_type_id = data.id;
		delete data.web_hook;
		return axios.patch(`/auth_types?id=eq.${auth_type_id}`, data);
	},

	getAuthDrivers() {
		return axios.get('/auth_drivers');
	},

	addProfile(data) {
		// data._session_time = data.session_time;
		// delete data.session_time;

		return axios.post("/hotspot_profiles", data);
	},

	updateProfile(data) {
		// data._session_time = data.session_time;
		// delete data.session_time;

		var profile_id = data.id;
		return axios.patch(`/hotspot_profiles?id=eq.${profile_id}`, data);
	},

	createInvite() {
	},

	getSettings() {
		return axios.get('/user_settings');
	},

	updateSettings(data) {
		return axios.patch('/user_settings', data);
	},

	getThemes() {
		return axios.get('/hotspot_themes');
	},

	getClientDevices(start_date, end_date) {
		var config = {
			headers: {
				// "Range-Unit": "items",
				// "Range": "0-19",
			},
		};
		// return axios.get(`/hotspot_devices?time_seen=ov.[${start_date},${end_date}]`, config);
		// return axios.get(`/hotspot_devices?time_seen=gte.${start_date}&time_seen=lte.${end_date}`, config);

		return axios.get(`/hotspot_devices?or=(and(time_seen.gte.${start_date},time_seen.lte.${end_date}),and(time_registred.gte.${start_date},time_registred.lte.${end_date}))`, config);
	},

	Dashboard() {
		return axios.get('/dashboard');
	},

	getStatClDevByMonth() {
		var config = {
			headers: {
				// "Range-Unit": "items",
				"Range": "0-11",
			},
		};
		return axios.get('/stat_cl_devices_cnt_by_month', config);
	},

	getStatClDevRegsByMonth() {
		var config = {
			headers: {
				// "Range-Unit": "items",
				"Range": "0-11",
			},
		};
		return axios.get('/stat_cl_devices_regs_cnt_by_month', config);
	},

	getStatMonthTrafic() {
		return axios.get('/stat_month_trafic');
	},

	getNases() {
		return axios.get('/hotspot_nases')
	},

	getNas(nas_id) {
		return axios.get(`/hotspot_nases?id=eq.${nas_id}`)
	},

	getNasTypes() {
		return axios.get('/hotspot_nastypes')
	},

	addNas(data) {
		return axios.post('/hotspot_nases', data);
	},

	updateNas(data) {
		var nas_id = data.id;
		return axios.patch(`/hotspot_nases?id=eq.${nas_id}`, data);
	},

	// getAccounting(start_date, end_date) {
	// 	return axios.get(`/accounting?and=(
	// 		time_end.gte.${start_date},
	// 		time_end.lte.${end_date}
	// 	)`);
	// },

	getAccounting(start_date, end_date) {
		return axios.get(`/accounting?
			or=(
				and(
					time_start.gte.${start_date},
					time_start.lte.${end_date}
				),
				and(
					time_end.gte.${start_date},
					time_end.lte.${end_date}
				)
			)
		`);
	},

}
