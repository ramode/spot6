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
                  <v-text-field label="Skin Folder Name" class="purple-input" v-model="form.skin" :rules="skinRules" required />
                </v-flex>
                
                <v-flex xs12 md12>
                  <!-- <v-text-field label="Minutes" class="purple-input" v-model="form.tarif_min" :rules="minutesRules" required /> -->
                  <!-- <v-subheader class="pl-0">Always show thumb label</v-subheader> -->
                  <span class="subheading font-weight-light mr-1">{{ form.session_time | mf_time_human_duration }}</span>
                  <v-slider label="Time Limit" v-model="form.session_time" :max="86400" step="15"></v-slider>
                </v-flex>
               

                <v-flex xs11 md5>
                  <v-text-field label="Traffic Limit" class="purple-input" v-model="form.traffic_limit" :rules="limitRules" required />
                </v-flex>
                <v-flex xs1 md1>
                  <v-select label="Unit" class="purple-input" :items="traffic_units" item-text="name" item-value="id" v-model="traffic_unit" :rules="limitRules" required />
                </v-flex>

                <v-flex xs10 md4>
                  <v-text-field label="Speed" class="purple-input" v-model="form.data_rate" :rules="speedRules" required />
                </v-flex>
                <v-flex xs1 md1>
                  <v-select label="Unit" class="purple-input" :items="speed_units" item-text="name" item-value="id" v-model="speed_unit" :rules="limitRules" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-select label="Auth Type" class="purple-input" :items="auth_types" item-text="name" item-value="id" v-model="form.auth_type" required></v-select>
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
        auth_types: [],

        traffic_units: [
          { id: 1, name: "Mb", ratio: 1048576 },
          { id: 2, name: "Gb", ratio: 1073741824 },
        ],
        traffic_unit: 1,

        speed_units: [
          { id: 1, name: "Mbit/sec", ratio: 1048576 },
          { id: 2, name: "Kbit/sec", ratio: 1024 },
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
        
        data.traffic_limit = data.traffic_limit * this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio;
        data.data_rate = data.data_rate * this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio;

        return data;

      },

      convert_from_bits_bytes(data) {

        data.traffic_limit = data.traffic_limit / this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio;
        data.data_rate = data.data_rate / this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio;

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


          // For EDIT action:
          if ( this.$route.params.id ) {
            this.v_edit = true
          };

          if ( this.v_edit ) {

            API.getProfile(this.$route.params.id).then(
              res => this.form = this.convert_from_bits_bytes(res.data[0]),
              err => this.$store.commit("error", err)
            )

          };

      },

      submit() {

        var data = this.form;
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
