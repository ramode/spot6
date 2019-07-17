<template>
	

	    <v-container fluid fill-height >

		    <v-layout align-center justify-center >

			    <v-flex xs12 sm8 md4>
				    <v-form @submit.prevent="logIn">
                   <material-card color="primary" title="Login form" :loading="p.loading">

	

						    <v-text-field
							    prepend-icon="person"
							    name="login"
							    label="Login"
							    type="text"
							    v-model="user.username">
						    </v-text-field>

						    <v-text-field
							    id="password"
							    prepend-icon="lock"
							    name="password" label="Password"
							    type="password"
							    v-model="user.password">
						    </v-text-field>




					    <slot slot="actions">
						    <v-btn flat :to="{ name: 'Registration' }">Регистрация</v-btn>
						    <v-spacer></v-spacer>
						    <v-btn color="primary" type="submit" >Login</v-btn>
					    </slot>

				    </material-card>
					    </v-form>

				    <v-alert
					    :value="p.login_error"
					    type="error"
				    >
					    Ошибка входа<br />
					    <small>{{ p.response }}</small>
				    </v-alert>

			    </v-flex>
		    </v-layout>
		</v-container>

</template>


<script>

	import API from '@/lib/API'

	export default {

		data() {
			return {
				user: {},
				res: {},
				p: {
					loading: false,
					login_error: false,
				},
			}
		},

		props: {
			source: String
		},

		mounted () {
			this.load();
		},

		methods: {

			load() {
				// Чтобы затерся токен, и запрос к API шел под ролью web_anon, т.к. другим ролям нет полного доступа к таблице users
				this.$auth.logout();
			},

			logIn(event) {
				this.p.login_error = false;
				this.p.loading = true;
				this.$auth.login({
					data: this.user,
					// success: res => console.log(res),
					error: error => {
						this.p.loading = false;
						this.p.login_error = true;
						this.p.response = `${error.response.data.message}, (code: ${error.response.data.code})`;
					},
				})
			},

		},

	};


</script>
