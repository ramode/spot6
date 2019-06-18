<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      
       <v-flex xs12 md12 xl8>
        
        <material-card color="blue darken-3" title="Settings" text="Your system settings">
          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout wrap>
                
                <v-flex xs12 md12>
                  <v-checkbox v-model="form.reg_enable" label="Registration Enabled"></v-checkbox>
                </v-flex>

                <v-flex xs12 md12>
                  <v-checkbox v-model="form.reg_users_need_activation" label="Require activation for self-reged users?"></v-checkbox>
                </v-flex>

                <v-flex xs12 md12>
                  <v-select label="Default role for self-reged users" class="purple-input" :items="roles" v-model="form.reg_role" required></v-select>
                </v-flex>

                <v-flex xs12 md12>
                  <v-text-field label="Registraion Secret" class="purple-input" v-model="form.reg_secret" required />
                </v-flex>
                
                <v-flex xs12 text-xs-right>
                  <!-- <v-btn class="mx-0 font-weight-light" color="success" :disabled="valid" @click="submit">Submit</v-btn> -->
                  <v-btn class="mx-0 font-weight-light" color="blue darken-3" @click="submit">Submit</v-btn>
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

    data: () => ({
      form: {},
      valid: false,
      roles: [],
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
          // err => console.log(err)
          err => this.$store.commit("error", err)
        );

        API.getSettings().then(
          res => {
            // console.log(res);
            this.form = res.data[0];
          },
          err => this.$store.commit("error", err)
        )
      },

      submit() {
          API.updateSettings(this.form).then(
            res => {
              // console.log(res);
            },
            err => this.$store.commit("error", err)
          )
      },

    }
 
  }

</script>
