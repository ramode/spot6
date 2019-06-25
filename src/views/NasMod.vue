<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex xs12 md12 xl8>
        <material-card color="blue-grey" :title="$t('Nases.edit_nas')" :text="$t('Nases.edit_nas_small')">
          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout wrap>
                
                <v-flex xs12 md12>
                  <v-text-field :label="$t('DB.label')" class="purple-input" v-model="form.label" required />
                </v-flex>

                <v-flex xs12 md12>
                  <v-text-field :label="$t('Nases.nas_ident')" class="purple-input" v-model="form.ident" required />
                </v-flex>


                <v-flex xs12 md12>
                  <v-select :label="$t('Nases.nas_type')" class="purple-input" :items="nas_types" v-model="form.nastype" required></v-select>
                </v-flex>


                <v-flex xs12 md6>
                  <v-text-field :label="$t('Nases.nas_location_id')" class="purple-input" v-model="form.location_id" required />
                </v-flex>

                <v-flex xs12 md6>
                  <v-text-field :label="$t('Nases.nas_location_name')" class="purple-input" v-model="form.location_name" required />
                </v-flex>

                <v-flex xs12 md12>
                  <v-checkbox :label="$t('Common.disabled')" v-model="form.disabled" required />
                </v-flex>


                <v-flex xs12 text-xs-right>
                  <!-- <v-btn class="mx-0 font-weight-light" color="success" :disabled="valid" @click="submit">Submit</v-btn> -->
                  <v-btn class="mx-0 font-weight-light" color="success" @click="submit">{{ $t('Form.save') }}</v-btn>
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

        loading: true,

        form: {},
        v_edit: false,
        valid: false,

        nas_types: [],
        

        // nameRules: [
        //   v => !!v || 'Required',
        // ],
        // skinRules: [
        //   v => !!v || 'Required',
        // ],
        // minutesRules: [
        //   v => !!v || 'Required',
        // ],
        // limitRules: [
        //   v => !!v || 'Required',
        // ],
        // speedRules: [
        //   v => !!v || 'Required',
        // ],

      }

    },

    computed: {
    },

    mounted () {
      this.load();
    },

    methods: {

      load() {

        API.getNasTypes().then(
          res => {
            console.log(res);
            res.data.forEach( (item, i) => {
              this.nas_types.push(item.nastype);
            });
          },
          err => this.$store.commit("error", err)
        );

        // For EDIT action:
        if ( this.$route.params.id ) {
          this.v_edit = true
        };

        if ( this.v_edit ) {

          API.getNas(this.$route.params.id).then(
            res => {
              console.log(res);
              this.form = res.data[0];
              this.loading = false;
            },
            err => this.$store.commit("error", err)
          );

        }

      },

      submit() {

        var ApiMethod;
          // If "add":
          if ( ! this.v_edit ) {
            ApiMethod = API.addNas;
          // if "edit"
          } else {
            ApiMethod = API.updateNas;
          }

        if (this.$refs.form.validate()) {

          this.loading = true;

          ApiMethod(this.form).then(
            res => {
              this.loading = false;
              if ( ! this.v_edit ) {
                this.$router.push({name: "nases"})
              }
            },
            err => this.$store.commit("error", err)
          )

        }

      },

    }


  }
</script>
