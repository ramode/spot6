<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>

      <v-flex xs12 md12 xl8 v-if="['super', 'admin'].includes($auth.user().role)">
        
        <material-card color="blue darken-3" :title="$t('Settings.settings')" :text="$t('Settings.settings_small')">
          <v-form ref="settings_form" v-model="valid">
                
                <v-flex xs12 md12>
                  <v-text-field  v-model="settings_form.session_time" :label="$t('Settings.session_time')"></v-text-field >
                </v-flex>


                <v-flex xs12 md12>
                  <v-checkbox v-model="settings_form.reg_enabled" :label="$t('Settings.reg_enable')"></v-checkbox>
                </v-flex>

                <v-flex xs12 md12>
                  <v-checkbox v-model="settings_form.reg_activation_needed" :label="$t('Settings.reg_users_need_activation')"></v-checkbox>
                </v-flex>

                <v-flex xs12 md6>
                  <v-select :label="$t('Settings.reg_role')" class="purple-input" :items="roles" v-model="settings_form.reg_role" required></v-select>
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.reg_secret')" class="purple-input" v-model="settings_form.reg_secret" required />
                </v-flex>
                
            </v-form>
        </material-card>

      </v-flex>

    </v-layout>

    <!-- Кнопка -->
    <v-fab-transition>
      <v-btn dark fab fixed bottom right color="primary" @click="save_settings">
        <v-icon>mdi-content-save</v-icon>
      </v-btn>
    </v-fab-transition>

  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({
      settings_form: {},
      auth_type_form: {},
      valid: false,
      // v_edit: true,
      v_add: false,
      roles: [],
      auth_types: [],
      auth_drivers: [],

      loading: false,

    }),

    mounted () {
      this.load();
    },

    methods: {
     
      load() {


        API.getRoles().then(
          res => {
            res.data.forEach((item, i) => {
              // TODO: do make check on server side:
              if ( ! ["su", "super"].includes(item.rolname) ) {
                this.roles.push(item.rolname);
              };
            });
          },
          err => this.$store.commit("error", err)
        );

        API.getSettings().then(
          res => {
            // console.log(res);
            this.settings_form = res.data[0];
          },
          err => this.$store.commit("error", err)
        );

        // API.getMyAuthTypes().then(
        //   res => {
        //     // console.log(res);
        //     // res.data.forEach((item, i) => {
        //     //   this.auth_types.push(item);
        //     // });
        //     this.auth_types = res.data;
        //   },
        //   err => this.$store.commit("error", err)
        // );

        // API.getAuthDrivers().then(
        //   res => {
        //     // console.log(res);
        //     this.auth_drivers = res.data;
        //   },
        //   err => this.$store.commit("error", err)
        // );

      },


      // renewAuthTypeObj(auth_type_id) {
      //   this.v_add = false;
      //   this.auth_type_form = this.auth_types.find( obj => obj.id == auth_type_id );
      // },

      // v_add_Change(v_add) {
      //   if ( v_add ) {
      //     this.auth_type_form = {};
      //   };
      // },


      save_settings() {
          API.updateSettings(this.settings_form).then(
            res => {
              // console.log(res);
            },
            err => this.$store.commit("error", err)
          )
      },

    }
 
  }

</script>
