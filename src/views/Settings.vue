<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>

      <v-flex xs12 md12 xl6 v-if="['super'].includes($auth.user().role)">
        
        <material-card color="blue darken-3" :title="$t('Settings.settings')" :text="$t('Settings.settings_small')">
          <v-form ref="settings_form" v-model="valid">
            <v-container py-0>
              
              <v-layout column>
                

                
                <v-flex xs12 md12>
                  <v-text-field  v-model="settings_form.session_time" :label="'Remember login for time'"></v-text-field >
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
                
                <v-flex xs12 text-xs-right>
                  <!-- <v-btn class="mx-0 font-weight-light" color="success" :disabled="valid" @click="submit">Save</v-btn> -->
                  <v-btn color="primary" @click="save_settings">{{ $t('Common.save') }}</v-btn>
                </v-flex>

              </v-layout>

            </v-container>
          </v-form>
        </material-card>

      </v-flex>

      <!--v-flex xs12 md12 xl6 v-if="['super', 'admin'].includes($auth.user().role)">
        
        <material-card color="blue darken-1" :title="$t('Settings.auth_types')" :text="$t('Settings.auth_types_small')">

          <v-form ref="auth_type_form" v-model="valid">
            <v-container py-0>
              
              <v-layout wrap>

                <v-flex xs12 md12>
                  <v-switch v-model="v_add" :label="$t('Common.add')" v-on:change="v_add_Change"></v-switch>
                </v-flex>
                

                <v-flex xs12 md12 v-if="!v_add">
                  <v-select :label="$t('DB.auth_types')" class="purple-input" :items="auth_types" v-on:input="renewAuthTypeObj"
                    item-text="label" item-value="id"
                    required
                  ></v-select>
                </v-flex>


                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_label')" class="purple-input" v-model="auth_type_form.label" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-select :label="$t('Settings.auth_driver')" class="purple-input" v-model="auth_type_form.driver"
                    :items="auth_drivers"
                    item-text="label" item-value="module"
                    required
                    :disabled="!v_add"
                  />
                </v-flex>


                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_key1')" class="purple-input" v-model="auth_type_form.key1" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_key2')" class="purple-input" v-model="auth_type_form.key2" required />
                </v-flex>


                <v-flex xs12 md12>
                  <template v-if="!v_add">
                    <span class="body-2">{{ $t('Settings.web_hook') }}</span>: {{ auth_type_form.web_hook }}
                  </template>
                  <template v-else>
                    <v-text-field :label="$t('Settings.web_hook')" class="purple-input" :value="'/'+ auth_type_form.driver + '/'+ auth_type_form.id" disabled />
                  </template>
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_button_title')" class="purple-input" v-model="auth_type_form.button" required />
                </v-flex>

               
                <v-flex xs12 text-xs-right>
                  <v-btn color="blue darken-1" @click="save_auth_type">
                    <template v-if="v_add">
                      {{ $t('Common.add') }}
                    </template>
                    <template v-else>
                      {{ $t('Common.save') }}
                    </template>
                  </v-btn>
                </v-flex>

                <v-progress-linear :indeterminate="true" v-if="loading"></v-progress-linear>

              </v-layout>

            </v-container>
          </v-form>
        </material-card-->

      </v-flex>
      
      

    

    </v-layout>
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

        API.getMyAuthTypes().then(
          res => {
            // console.log(res);
            // res.data.forEach((item, i) => {
            //   this.auth_types.push(item);
            // });
            this.auth_types = res.data;
          },
          err => this.$store.commit("error", err)
        );

        API.getAuthDrivers().then(
          res => {
            // console.log(res);
            this.auth_drivers = res.data;
          },
          err => this.$store.commit("error", err)
        );

      },


      renewAuthTypeObj(auth_type_id) {
        this.v_add = false;
        this.auth_type_form = this.auth_types.find( obj => obj.id == auth_type_id );
      },

      v_add_Change(v_add) {
        if ( v_add ) {
          this.auth_type_form = {};
        };
      },


      save_settings() {
          API.updateSettings(this.settings_form).then(
            res => {
              // console.log(res);
            },
            err => this.$store.commit("error", err)
          )
      },


      save_auth_type() {

        this.loading = true;
        
        var ApiMethod;
        if ( this.v_add ) {
          ApiMethod = API.addAuthType;
        } else {
          ApiMethod = API.updateAuthType;
        };

        ApiMethod(this.auth_type_form).then(
          res => this.loading = false,
          err => {
            this.$store.commit("error", err);
            this.loading = false;
          }
        )

      }

    }
 
  }

</script>
