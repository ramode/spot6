<template>
  <v-container
    fill-height
    fluid
    grid-list-xl
  >
    <v-layout
      justify-center
      wrap
    >
      <v-flex
        xs12
        md12
        xl8
      >
        <material-card
          color="orange"
          :title="v_edit ? $t('Users.title_edit') + ': ' + form.label : $t('Users.title_add')"
          :text="$t('Users.title_small_mod')"
        >
          <v-form
            ref="form"
            v-model="valid"
          >
            <v-container py-0>
              <v-layout column>
                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="form.label"
                    :label="$t('Users.label')"
                    class="purple-input"
                    :rules="labelRules"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="form.login"
                    :label="$t('Users.login')"
                    class="purple-input"
                    :rules="identRules"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="password.pass1"
                    :label="$t('Users.pass')"
                    class="purple-input"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="password.pass2"
                    :label="$t('Users.pass_repeat')"
                    class="purple-input"
                    :rules="pass2Rules"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md8
                >
                  <v-text-field
                    v-model="form.full_name"
                    :label="$t('Users.full_name')"
                    class="purple-input"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="form.email"
                    :label="$t('Users.email')"
                    class="purple-input"
                    :rules="emailRules"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md4
                >
                  <v-text-field
                    v-model="form.phone"
                    :label="$t('Users.phone')"
                    class="purple-input"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md6
                >
                  <v-checkbox
                    v-model="form.disabled"
                    :label="$t('Form.disabled')"
                  />
                </v-flex>

                <!-- <v-flex xs12 md6 v-if="$auth.user().role === 'su'"> -->
                <v-flex
                  v-if="['admin','super'].indexOf($auth.user().role) >= 0"
                  xs12
                  md6
                >
                  <v-select
                    v-model="form.role"
                    :label="$t('Users.role')"
                    class="purple-input"
                    :items="roles"
                    required
                  />
                </v-flex>

                <v-flex
                  v-if="['super','admin'].includes($auth.user().role)"
                  xs12
                  md6
                >
                  <v-select
                    v-model="form.group_id"
                    :label="$t('Users.group')"
                    class="purple-input"
                    :items="groups"
                    item-value="id"
                    item-text="label"
                  />
                </v-flex>

                </v-layout>
            </v-container>

      <v-fab-transition>
        <v-btn
          dark
          fab
          fixed
          bottom
          right
          color="primary"
          :title="$t('Form.save')"
          @click="submit"
        >
          <v-icon>mdi-content-save</v-icon>
        </v-btn>
      </v-fab-transition>

          </v-form>
        </material-card>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

import API from '@/lib/API'

export default {

  data () {
    return {
      form: {
        disabled: false // for insert
      },
      v_edit: false,
      valid: false,
      roles: [],
      groups: [],

      password: {
        pass1: '',
        pass2: ''
      },

      emailRules: [
        v => (!v || !!v.match(/^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i)) || 'Invalid'
      ],

      labelRules: [
        v => !!v || 'Required'
      ],

      identRules: [
        v => !!v || 'Required'
      ],
      pass2Rules: [
        // v => !!v || 'Required',
        v => {
          if (this.password.pass1 && v != this.password.pass1) {
            return 'Passwords do not match'
          } else {
            return true
          }
        }
      ]
    }
  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      console.log(this.$route.params)

      API.getRoles().then(
        res => {
          // console.log(res);
          res.data.forEach((item, i) => {
            this.roles.push(item.rolname)
          })
        },
        // err => console.log(err)
        err => this.$store.commit('error', err)
      )

      API.getGroups().then(
        res => {
          // console.log(res);
          res.data.forEach((item, i) => {
            this.groups.push(item)
          })
        },
        // err => console.log(err)
        err => this.$store.commit('error', err)
      )

      // For EDIT action:
      if (!isNaN(this.$route.params.id)) {
        this.v_edit = true
      };

      if (this.v_edit) {
        API.getUser(this.$route.params.id).then(
          res => {
            this.form = res.data[0]
            delete this.form.pass

            // Backend не даст проапдейтить role для не суперадминов:
            // if ( this.$auth.user().role != 'su' ) {
            //   delete this.form.role;
            // };

            // Переписываем рульз на необходимость пароля
            // Если поле пароля пустое - то не изменять пароль
            this.passRules = [
              v => {
                // Если поле с паролем пустое:
                if (!v) {
                  delete this.form.pass
                };
                return true
              }
            ]
          },
          // err => console.log(err)
          err => this.$store.commit('error', err)
        )
      } ;
    },

    submit () {
      if (this.$refs.form.validate()) {
        delete this.form.pass2

        // TEMP for current API:
        // delete this.form.full_name;

        // Native form submission is not yet supported

        var ApiMethod
        // If "add":
        if (!this.v_edit) {
          ApiMethod = API.addUser
          // if "edit"
        } else {
          ApiMethod = API.updateUser
        }

        ApiMethod(this.form).then(
          res => {
            console.log(res)
            console.log(this.password.pass1)
            console.log(!!this.password.pass1 && this.password.pass1 == this.password.pass2 && res.data.id)
            if (!!this.password.pass1 && this.password.pass1 == this.password.pass1 && res.data[0].id) {
              API.passwdUser(res.data[0].id, this.password.pass1).then(res => this.$router.push({ name: 'users' }))
            } else {
              this.$router.push({ name: 'users' })
            }
          },
          // err => console.log(err)
          err => this.$store.commit('error', err)
        )
      }
    }

  }

}
</script>
