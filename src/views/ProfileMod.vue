<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex xs12 md12 xl8>
        
        <material-card color="teal" title="Edit Profile" text="Profile for your Wi-Fi access devices">
          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout wrap>
                
                <v-flex xs12 md7>
                  <v-text-field label="Profile Name" class="purple-input" v-model="form.name" :rules="nameRules" required />
                </v-flex>
                
                <v-flex xs12 md5>
                  <!-- <v-text-field label="Skin Folder Name" class="purple-input" v-model="form.skin" :rules="skinRules" required /> -->
                  <v-select label="Theme" class="purple-input" :items="themes" item-text="name" item-value="id" v-on:input="renewThemeVars" v-model="form.theme_id" required></v-select>
                </v-flex>

                <v-flex xs12 md12 v-if="form.theme_id">
                  <span class="subheading">Theme params:</span>
                </v-flex>

                <v-flex xs12 md12 v-for="v in theme_var_list">
                  <!-- <v-text-field :label="v['label']" v-model="form.theme_vars[v.name]" required /> -->
                  <v-text-field :label="v.label" v-model="form.theme_vars[v.name]" required />
                </v-flex>



                <!-- <v-flex xs12 md12>
                  <span class="subheading font-weight-light mr-1">{{ form.session_time | mf_time_human_duration }}</span>
                  <v-slider label="Time Limit" v-model="form.session_time" :max="86400" step="300"></v-slider>
                </v-flex> -->

                <v-flex xs12 md3>
                  <v-text-field label="Time Limit" v-model="form.session_time" required />
                </v-flex>
               

                <v-flex xs11 md2>
                  <v-text-field label="Traffic Limit" class="purple-input" v-model="form.traffic_limit" />
                </v-flex>
                <v-flex xs1 md1>
                  <v-select label="Unit" class="purple-input" :items="traffic_units" item-text="name" item-value="id" v-model="traffic_unit" />
                </v-flex>

                <v-flex xs10 md2>
                  <v-text-field label="Speed" class="purple-input" v-model="form.data_rate" />
                </v-flex>
                <v-flex xs2 md2>
                  <v-select label="Unit" class="purple-input" :items="speed_units" item-text="name" item-value="id" v-model="speed_unit" />
                </v-flex>


                <v-flex xs12 md2>
                  <v-text-field label="port_limit" class="purple-input" v-model="form.port_limit" />
                </v-flex>

                <v-flex xs12 md12>
                  <v-select label="Auth Types" class="purple-input" :items="auth_types" item-text="name" item-value="id" v-model="form.auth_types" multiple chips required></v-select>
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
          { id: 1, name: "Gb", ratio: 1073741824 },
          { id: 2, name: "Mb", ratio: 1048576 },
        ],
        traffic_unit: 1,

        speed_units: [
          { id: 1, name: "Mbit/sec", ratio: 1048576 },
          { id: 2, name: "kbit/sec", ratio: 1024 },
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

        data.traffic_limit = data.traffic_limit * traffic_unit_ratio;
        data.data_rate = data.data_rate * speed_unit_rario;
        

        return data;

      },

      convert_from_bits_bytes(data) {

        // Если меньше 1 Gb:
        if ( data.traffic_limit < this.traffic_units.filter( obj => obj.id == 1)[0].ratio ) {
          this.traffic_unit = 2;
        // Если больше 1 Gb:
        } else {
          this.traffic_unit = 1;
        }
        var traffic_unit_ratio = this.traffic_units.filter( obj => obj.id == this.traffic_unit )[0].ratio;
        data.traffic_limit = data.traffic_limit / traffic_unit_ratio;
        
        // Если меньше 1 Mbit/sec:
        if ( data.data_rate < this.speed_units.filter( obj => obj.id == 1)[0].ratio ) {
          this.speed_unit = 2;
        } else {
          this.speed_unit = 1;
        }
        var speed_unit_ratio = this.speed_units.filter( obj => obj.id == this.speed_unit)[0].ratio;
        data.data_rate = data.data_rate / speed_unit_ratio;

        return data;

      },

      load() {

          API.getAuthTypes().then(
            res => {
              // console.log(res);
              res.data.forEach((item, i) => {
                this.auth_types.push(item);
              });
            },
            err => {
              // console.log(err);
              // this.$store.commit("addNotify", `${err.response.status}: ${err.response.data.message}`);
              this.$store.commit("error", err);
            }
          );

          API.getThemes().then(
            res => {
              // console.log(res);
              this.themes = res.data;

              // if ( this.form.theme_vars == null ) {
              //   this.form.theme_vars = {};
              // };
              // this.renewThemeVars(this.form.theme_id);

            },
            err => this.$store.commit("error", err)
          );


          // For EDIT action:
          if ( this.$route.params.id ) {
            this.v_edit = true
          };

          if ( this.v_edit ) {

            API.getProfile(this.$route.params.id).then(
              res => {
                this.form = this.convert_from_bits_bytes(res.data[0]);
                this.renewThemeVars(this.form.theme_id);
              },
              err => this.$store.commit("error", err)
            )

          } else {
            this.form.theme_vars = {};
          };

      },


      renewThemeVars(theme_id) {
        
        // console.log(theme_id);
        // console.log(this.themes);
        // console.log("renewThemeVars");

        this.themes.forEach( (item, i) => {
          if ( item.id == theme_id ) {
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
