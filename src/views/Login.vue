<template>
	
	<v-content>
	    <v-container fluid fill-height>

		    <v-layout align-center justify-center>
			    <v-flex xs12 sm8 md4>

                   <material-card color="primary" title="Login form" text="Please log in" :loading="p.loading">

					    <v-form>

						    <v-text-field
							    prepend-icon="person"
							    name="login"
							    label="Login"
							    type="text"
							    v-model="user.login">
						    </v-text-field>

						    <v-text-field
							    id="password"
							    prepend-icon="lock"
							    name="password" label="Password"
							    type="password"
							    v-model="user.pass">
						    </v-text-field>

					    </v-form>


					    <slot slot="actions">
						    <router-link :to="{ name: 'Registration' }">Регистрация</router-link>
						    <v-spacer></v-spacer>
						    <v-btn color="primary" v-on:click="logIn">Login</v-btn>
					    </slot>

				    </material-card>


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
	</v-content>
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
