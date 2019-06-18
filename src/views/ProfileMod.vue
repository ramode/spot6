<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex xs12 md12 xl8>
        
        <material-card color="orange" title="Edit Profile" text="Profile for your hotspots">
          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout column>
                
                <v-flex xs12 md7>
                  <v-text-field label="Profile Name" class="purple-input" v-model="form.profile" :rules="nameRules" required />
                  <v-text-field label="Label" class="purple-input" v-model="form.label" required />
                </v-flex>
                
                <v-flex xs12 md5>
                  <!-- <v-text-field label="Skin Folder Name" class="purple-input" v-model="form.skin" :rules="skinRules" required /> -->
                  <v-select label="Theme" class="purple-input" :items="themes" item-text="label" item-value="name" v-on:input="renewThemeVars" v-model="form.theme" required></v-select>
                </v-flex>

                <v-flex xs12 md12 v-if="form.theme">
                  <span class="subheading">Template params:</span>
                </v-flex>

                <v-flex xs12 md12 v-for="v in theme_var_list">
                  <v-textarea auto-grow clearable :label="v.label" v-model="form.template[v.name]" required v-if="v.type=='html'" type="html" />
                  <v-textarea auto-grow clearable :label="v.label" v-model="form.template[v.name]" required v-if="v.type=='textarea'" />
                  <v-text-field :label="v.label" v-model="form.template[v.name]" required v-if="v.type=='text'" />
                </v-flex>

                <v-flex xs12 md12>
                  <span class="subheading">Authorization:</span>
                </v-flex>
                <v-flex xs12 md12>
                  <v-select label="Auth Types" class="purple-input" :items="auth_types" item-text="label" item-value="id" v-model="form.auth_types" multiple chips required></v-select>
                </v-flex>

                <v-flex xs12 md3>
                  <v-checkbox label="MAC Auth" v-model="form.mac_auth" required />
                </v-flex>

                <v-flex xs12 md12>
                  <span class="subheading">Limits:</span>
                </v-flex>

                <v-flex xs12 md3>
                  <v-text-field label="Port Limit" v-model="form.limit_ports" required />
                </v-flex>
               
                <v-flex xs12 md3>
 <v-layout row>
                
                <v-flex xs8 md4>
                  <v-text-field label="Traffic Limit" class="purple-input" v-model="form.limit_bytes" />
                </v-flex>
                <v-flex xs4 md2>
                  <v-select label="Unit" class="purple-input" :items="traffic_units" item-text="name" item-value="id" v-model="traffic_unit" />
                </v-flex>
 </v-layout>                </v-flex>
<v-flex xs12 md3>
 <v-layout row>
                <v-flex xs8 md4>
                  <v-text-field label="Speed" class="purple-input" v-model="form.limit_speed" />
                </v-flex>
                <v-flex xs4 md2>
                  <v-select label="Unit" class="purple-input" :items="speed_units" item-text="name" item-value="id" v-model="speed_unit" />
                </v-flex>
 </v-layout>                </v-flex>

                <v-flex xs12 md2>
                  <v-text-field label="Session time" class="purple-input" v-model="form.limit_time" />
                </v-flex>




                <v-flex xs12 md12>
                  <v-text-field label="redirect_url" class="purple-input" v-model="form.redirect_url" />
                </v-flex>

                <v-flex xs12 md12>
                  <v-text-field label="ad_url" class="purple-input" v-model="form.ad_url" />
                </v-flex>
                

                <v-flex xs12 text-xs-right>
                  <!-- <v-btn class="mx-0 font-weight-light" color="success" :disabled="valid" @click="submit">Submit</v-btn> -->
                  <v-btn class="mx-0 font-weight-light" color="success" @click="submit">Submit</v-btn>
                </v-flex>

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

    data() {

      return {

        form: {},
        v_edit: false,
        valid: false,
        themes: [],
        theme_var_list: [],
        auth_types: [],

        traffic_units: [
          { id: 1, name: "GB", ratio: 1073741824 },
          { id: 2, name: "MB", ratio: 1048576 },
        ],
        traffic_unit: 1,

        speed_units: [
          { id: 1, name: "Mbit/s", ratio: 1048576 },
          { id: 2, name: "kbit/s", ratio: 1024 },
        ],
        speed_unit: 1,

        nameRules: [
          v => !!v || 'Required',
        ],
        skinRules: [
          v => !!v || 'Required',
        ],
        minutesRules: [
          v => !!v || 'Required',
        ],
        limitRules: [
          v => !!v || 'Required',
        ],
        speedRules: [
          v => !!v || 'Required',
        ],

      }

    },

    computed: {
    },

    mounted () {
      this.load();
    },

    methods: {

      convert_to_bits_bytes(data) {
        
        var
          traffic_unit_ratio = this.traffic_units.filter( obj => obj.id == this.traffic_unit )[0].ratio,
          speed_unit_rario = this.speed_units.filter( obj => obj.id == this.speed_unit )[0].ratio;

        console.log(traffic_unit_ratio);
        console.log(speed_unit_rario);

        data.limit_bytes = data.limit_bytes * traffic_unit_ratio;
        data.limit_speed = data.limit_speed * speed_unit_rario;
        

        return data;

      },

      convert_from_bits_bytes(data) {

        // Если меньше 1 Gb:
        if ( data.limit_bytes < this.traffic_units.filter( obj => obj.id == 1)[0].ratio ) {
          this.traffic_unit = 2;
        // Если больше 1 Gb:
        } else {
          this.traffic_unit = 1;
        }
        var traffic_unit_ratio = this.traffic_units.filter( obj => obj.id == this.traffic_unit )[0].ratio;
        data.limit_bytes = data.limit_bytes / traffic_unit_ratio;
        
        // Если меньше 1 Mbit/sec:
        if ( data.limit_speed < this.speed_units.filter( obj => obj.id == 1)[0].ratio ) {
          this.speed_unit = 2;
        } else {
          this.speed_unit = 1;
        }
        var speed_unit_ratio = this.speed_units.filter( obj => obj.id == this.speed_unit)[0].ratio;
        data.limit_speed = data.limit_speed / speed_unit_ratio;

        return data;

      },

      load() {
            
            self=this;

          API.getAuthTypes().then(
            res => {
              // console.log(res);
              res.data.forEach((item, i) => {
                self.auth_types.push(item);
              });
            },
            err => {
              // console.log(err);
              // this.$store.commit("addNotify", `${err.response.status}: ${err.response.data.message}`);
              self.$store.commit("error", err);
            }
          );

          API.getThemes().then(
            res => {
              self.themes = res.data;

              if ( self.form.theme ) {

                self.renewThemeVars(self.form.theme);
              };
            },
            err => this.$store.commit("error", err)
          );


          // For EDIT action:
          if ( self.$route.params.id ) {
            self.v_edit = true
          };

          if ( self.v_edit ) {

            API.getProfile(self.$route.params.id).then(
              res => {
                self.form = self.convert_from_bits_bytes(res.data[0]);
                if (this.themes) {
                    self.renewThemeVars(self.form.theme);
                }
              },
              err => self.$store.commit("error", err)
            )

          } else {
            self.form.template = {};
          };

      },


      renewThemeVars(theme) {
        
        this.themes.forEach( (item, i) => {
          if ( item.name == theme ) {
            this.theme_var_list = item.variables;
          };
        });

      },


      submit() {

        // Костыль, чтобы склонирвоать переменную, чтобы в полях формы не отрисовывались большие числа байтов:
        var data = Object.assign({}, this.form);

        data = this.convert_to_bits_bytes(data);

        var ApiMethod;
          // If "add":
          if ( ! this.v_edit ) {
            ApiMethod = API.addProfile;
          // if "edit"
          } else {
            ApiMethod = API.updateProfile;
          }

        if (this.$refs.form.validate()) {
          ApiMethod(data).then(
            res => {
             this.$router.push({name: "profiles"})
            },
            err => this.$store.commit("error", err)
          )
        }

      },

    }


  }
</script>
