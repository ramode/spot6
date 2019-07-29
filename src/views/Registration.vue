<template>
  <v-content>
    <v-container
      fluid
      fill-height
    >
      <v-layout
        align-center
        justify-center
      >
        <v-flex
          xs12
          sm8
          md6
        >
          <material-card
            color="primary"
            title="Registraion"
            :loading="p.loading"
          >
            <v-form
              ref="form"
              v-model="valid"
            >
              <v-text-field
                v-model="form.login"
                prepend-icon="person"
                label="Login"
                type="text"
                :rules="emailRules"
                required
              />

              <v-text-field
                v-model="form.pass"
                prepend-icon="lock"
                label="Password"
                type="password"
                :rules="passRules"
                required
              />
              <v-text-field
                v-model="form.pass2"
                prepend-icon="lock"
                label=" Repeat Password"
                type="password"
                :rules="pass2Rules"
                required
              />

              <v-text-field
                v-model="form.email"
                prepend-icon="mdi-at"
                label="E-Mail"
                type="text"
              />

              <v-text-field
                v-model="form.phone"
                prepend-icon="mdi-phone-classic"
                label="Phone"
                type="text"
              />

              <v-text-field
                v-if="show_reg_secret"
                v-model="form.reg_secret"
                prepend-icon="mdi-alphabetical"
                label="Registration Secret"
                type="text"
                :rules="regSecretRules"
              />
            </v-form>

            <slot slot="actions">
              <v-spacer />
              <v-btn
                color="primary"
                @click="Reg"
              >
                Registration
              </v-btn>
            </slot>
          </material-card>

          <v-alert
            :value="p.reg_error"
            type="error"
          >
            Registration Error:<br>
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

  props: {
    source: String
  },

  data () {
    return {
      form: {
        email: null,
        phone: null
      },
      show_reg_secret: true,
      valid: false,
      res: {},
      p: {
        loading: false,
        login_error: false
      },

      emailRules: [
        v => !!v || 'Required'
      ],
      passRules: [
        v => !!v || 'Required'
      ],
      pass2Rules: [
        v => !!v || 'Required'
        // v => {
        // 	console.log(v);
        // 	console.log(this.form.pass);
        // 	if ( v != this.form.pass ) {
        // 		return 'Passwords do not match'
        // 	} else {
        // 		return true
        // 	}
        // },
      ],
      regSecretRules: [
        v => !!v || 'Required'
      ]

    }
  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      // Чтобы затерся токен, и запрос к API шел под ролью web_anon, т.к. другим ролям нет полного доступа к таблице users
      // this.$auth.logout();

      if (this.$route.params.reg_secret) {
	            	this.form.reg_secret = this.$route.params.reg_secret
	            	this.show_reg_secret = false
          		};
    },

    Reg (event) {
      if (this.$refs.form.validate()) {
        // Now delete in API:
        // delete this.form.pass2;

        this.p.reg_error = false
        this.p.loading = true

        API.Registration(this.form).then(
          res => {
            // console.log(res);
            this.p.loading = false
            this.$router.push({ name: 'Login' })
          },
          err => {
            console.log(err)
            this.p.loading = false
            this.p.response = `${err.response.data.message}, (code: ${err.response.data.code})`
            this.p.reg_error = true
          }
        )
      };
    }

  }

}

</script>
