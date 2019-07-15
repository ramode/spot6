<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="blue darken-1" :title="title_add" :text="$t('AuthTypes.title_small')">

          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout wrap>

                <!-- <v-flex xs12 md12>
                  <v-switch v-model="v_add" :label="$t('Common.add')" v-on:change="v_add_Change"></v-switch>
                </v-flex> -->
                
                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_label')" class="purple-input" v-model="form.label" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-select :label="$t('Settings.auth_driver')" class="purple-input" v-model="form.driver"
                    :items="auth_drivers"
                    item-text="label" item-value="module"
                    required
                    :disabled="!v_add"
                  />
                </v-flex>


                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_key1')" class="purple-input" v-model="form.key1" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_key2')" class="purple-input" v-model="form.key2" required />
                </v-flex>


                <v-flex xs12 md12>
                  <template v-if="v_add">
                    <v-text-field :label="$t('Settings.web_hook')" class="purple-input" :value="'/'+ form.driver + '/'+ form.id" disabled />
                  </template>
                  <template v-else>
                    <span class="body-2">{{ $t('Settings.web_hook') }}</span>: {{ form.web_hook }}
                  </template>
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Settings.auth_type_button_title')" class="purple-input" v-model="form.button" required />
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

      form: {
        id:     "_future_id_", // Чтобы при Add не писался undefined
        driver: "_driver_", // Чтобы при Add не писался undefined
      },
      v_add: true,
      valid: false,

      auth_drivers: [],

    }),

    computed: {

      title_add: function() {
        if ( this.v_add ) {
          return this.$t('AuthTypes.title_add')
        } else {
          return `${this.$t('AuthTypes.title')}: ${this.form.label}`
        };
      },

    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        this.loading = 0

        API.getAuthDrivers().then(
          res => {
            // console.log(res);
            this.auth_drivers = res.data;
          },
          err => this.$store.commit("error", err)
        );

        // For EDIT action:
        if ( this.$route.params.id ) {
          // this.v_edit = true;
          this.v_add = false;
        };

        if ( ! this.v_add ) {
          API.getMyAuthType(this.$route.params.id).then(
            res => {
              console.log(res);
              this.form = res.data[0];
            },
            err => this.$store.commit("error", err)
          );
        };

      },

      save_auth_type() {

        this.loading = true;
        
        var ApiMethod;
        if ( this.v_add ) {
          ApiMethod = API.addAuthType;
        } else {
          ApiMethod = API.updateAuthType;
        };

        ApiMethod(this.form).then(
          res => {
            this.loading = false;
            if ( this.v_add ) {
              this.$router.push({name: "auth_types"});
            };
          },
          err => {
            this.$store.commit("error", err);
            this.loading = false;
          }
        )

      }

    },
 
  }

</script>
