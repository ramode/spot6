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
      <v-flex md12>
        <material-card
          color="blue darken-1"
          :title="title_add"
          :text="$t('AuthTypes.title_small')"
          :loading="loading"
        >
          <v-form
            ref="form"
            v-model="valid"
          >
            <v-container py-0>
              <v-layout wrap>
                <!-- <v-flex xs12 md12>
                  <v-switch v-model="v_add" :label="$t('Common.add')" v-on:change="v_add_Change"></v-switch>
                </v-flex> -->

                <v-flex
                  xs12
                  md6
                >
                  <v-text-field
                    v-model="form.label"
                    :label="$t('Settings.auth_type_label')"
                    class="purple-input"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md6
                >
                  <v-select
                    v-model="form.driver"
                    :label="$t('Settings.auth_driver')"
                    class="purple-input"
                    :items="auth_drivers"
                    item-text="label"
                    item-value="module"
                    required
                    :disabled="!v_add"
                  />
                </v-flex>

                <v-flex
                  xs12
                  md6
                >
                  <v-text-field
                    v-model="form.key1"
                    :label="$t('Settings.auth_type_key1')"
                    class="purple-input"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md6
                >
                  <v-text-field
                    v-model="form.key2"
                    :label="$t('Settings.auth_type_key2')"
                    class="purple-input"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md12
                >
                  <v-text-field
                    :label="$t('Settings.web_hook')"
                    :value="'/uam/callback/'+ form.driver + '/'+ form.id"
                    disabled
                  />
                </v-flex>

                <v-flex
                  xs12
                  md6
                >
                  <v-text-field
                    v-model="form.button"
                    :label="$t('Settings.auth_type_button_title')"
                    class="purple-input"
                    required
                  />
                </v-flex>

                <v-flex
                  xs12
                  md12
                >
                  <v-select
                    v-model="form.group_ids"
                    :label="$t('Users.group')"
                    :items="groups"
                    item-text="label"
                    item-value="id"
                    multiple
                    chips
                    required
                  />
                </v-flex>

                <v-fab-transition>
                  <v-btn
                    dark
                    fab
                    fixed
                    bottom
                    right
                    color="primary"
                    :title="v_add? $t('Common.add') : $t('Common.save')"
                    @click="submit"
                  >
                    <v-icon>{{ v_add? 'mdi-plus':'mdi-content-save' }}</v-icon>
                  </v-btn>
                </v-fab-transition>
              </v-layout>
            </v-container>
          </v-form>
        </material-card>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

import API from '@/lib/API'

export default {

  data: () => ({

    loading: true,
    groups: [],

    form: {
      id: '_future_id_', // Чтобы при Add не писался undefined
      driver: '_driver_' // Чтобы при Add не писался undefined
    },
    v_add: true,
    valid: false,

    auth_drivers: []

  }),

  computed: {

    title_add: function () {
      if (this.v_add) {
        return this.$t('AuthTypes.title_add')
      } else {
        return `${this.$t('AuthTypes.title')}: ${this.form.label}`
      };
    }

  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      this.loading = 0

      API.getGroups().then(
        res => {
          // console.log(res);
          res.data.forEach((item, i) => {
            this.groups.push(item)
            this.loading += 30
          })
        },
        // err => console.log(err)
        err => this.$store.commit('error', err)
      )

      API.getAuthDrivers().then(
        res => {
          // console.log(res);
          this.auth_drivers = res.data
          this.loading += 30
        },
        err => this.$store.commit('error', err)
      )

      // For EDIT action:
      if (this.$route.params.id) {
        // this.v_edit = true;
        this.v_add = false
      };

      if (!this.v_add) {
        API.getMyAuthType(this.$route.params.id).then(
          res => {
            // console.log(res);
            this.form = res.data[0]
            this.loading += 40
          },
          err => this.$store.commit('error', err)
        )
      } else {
        this.loading += 40
      };
    },

    submit () {
      this.loading = true

      var ApiMethod
      if (this.v_add) {
        ApiMethod = API.addAuthType
      } else {
        ApiMethod = API.updateAuthType
      };

      ApiMethod(this.form).then(
        res => {
          this.loading = false
          if (this.v_add) {
            this.$router.push({ name: 'auth_types' })
          };
        },
        err => {
          this.$store.commit('error', err)
          this.loading = false
        }
      )
    }

  }

}

</script>
