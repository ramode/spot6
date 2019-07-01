<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex xs12 md12 xl8>
        
        <material-card color="green" :title="'Edit User: '+form.label" text="Complete your profile">
          <v-form ref="form" v-model="valid">
            <v-container py-0>
              
              <v-layout column>


                <v-flex xs12 md4>
                  <v-text-field label="Label" class="purple-input" v-model="form.label" :rules="labelRules" required />
                </v-flex>                

                <v-flex xs12 md4>
                  <v-text-field label="Username" class="purple-input" v-model="form.login" :rules="identRules" required />
                </v-flex>

                <v-flex xs12 md4>
                  <v-text-field label="Password" class="purple-input" v-model="password.pass1"/>
                </v-flex>

                <v-flex xs12 md4>
                  <v-text-field label="Repeat password" class="purple-input" v-model="password.pass2" :rules="pass2Rules"/>
                </v-flex>

                <v-flex xs12 md8>
                  <v-text-field label="Full Name" class="purple-input" v-model="form.full_name" />
                </v-flex>

                <v-flex xs12 md4>
                  <v-text-field label="E-Mail" class="purple-input" v-model="form.email" :rules="emailRules"/>
                </v-flex>
                
                <v-flex xs12 md4>
                  <v-text-field label="Phone" class="purple-input" v-model="form.phone" />
                </v-flex>
                

                <v-flex xs12 md6>
                  <v-checkbox v-model="form.disabled" label="Disabled"></v-checkbox>
                </v-flex>

                <!-- <v-flex xs12 md6 v-if="$auth.user().role === 'su'"> -->
                <v-flex xs12 md6 v-if="['admin','super'].indexOf($auth.user().role) >= 0">
                  <v-select label="Role" class="purple-input" :items="roles" v-model="form.role" required  ></v-select>
                </v-flex>

                 <v-flex xs12 md6 v-if="['admin', 'super'].indexOf($auth.user().role) >= 0">
                  <v-select label="Group" class="purple-input" :items="groups" v-model="form.group_id" item-value="id" item-text="label"></v-select>
                </v-flex>               

                

                <v-flex xs12 text-xs-right>
                  <!-- <v-btn class="mx-0 font-weight-light" color="success" :disabled="valid" @click="submit">Save</v-btn> -->
                  <v-btn class="mx-0 font-weight-light" color="success" @click="submit">Save</v-btn>
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
        form: {
            disabled: false //for insert
        },
        v_edit: false,
        valid: false,
        roles: [],
        groups: [],

        password: {
            pass1:"",
            pass2:""
        },

        emailRules: [
          v =>  (!v || !!v.match(/^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i)) || 'Invalid'
        ],

        labelRules: [
          v => !!v || 'Required',
        ],

        identRules: [
          v => !!v || 'Required',
        ],
        pass2Rules: [
          // v => !!v || 'Required',
          v => {
            if ( this.password.pass1 && v != this.password.pass1 ) {
              return 'Passwords do not match'
            } else {
              return true
            }
          },
        ],
      }

    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

          API.getRoles().then(
            res => {
              // console.log(res);
              res.data.forEach((item, i) => {
                this.roles.push(item.rolname);
              });
            },
            // err => console.log(err)
            err => this.$store.commit("error", err)
          );



          API.getGroups().then(
            res => {
              // console.log(res);
              res.data.forEach((item, i) => {
                  this.groups.push(item);
              });

            },
            // err => console.log(err)
            err => this.$store.commit("error", err)
          );

          // For EDIT action:
          if ( this.$route.params.id ) {
            this.v_edit = true
          };

          if ( this.v_edit ) {
            API.getUser(this.$route.params.id).then(
              res => {

                this.form = res.data[0];
                delete this.form.pass;

                // Backend не даст проапдейтить role для не суперадминов:
                // if ( this.$auth.user().role != 'su' ) {
                //   delete this.form.role;
                // };

                // Переписываем рульз на необходимость пароля
                // Если поле пароля пустое - то не изменять пароль
                this.passRules = [
                  v => {

                    // Если поле с паролем пустое:
                    if ( !v ) {
                      delete this.form.pass;
                    };
                    return true;

                  },
                ];

              },
              // err => console.log(err)
              err => this.$store.commit("error", err)
            )
          } ;

      },

      submit() {
        if (this.$refs.form.validate()) {
          delete this.form.pass2;

          // TEMP for current API:
          // delete this.form.full_name;


          // Native form submission is not yet supported

          var ApiMethod;
          // If "add":
          if ( ! this.v_edit ) {
            ApiMethod = API.addUser;
          // if "edit"
          } else {
            ApiMethod = API.updateUser;
          }

          ApiMethod(this.form).then(
              res => {
                console.log(res)
                console.log(this.password.pass1)
                console.log(!!this.password.pass1 && this.password.pass1==this.password.pass2 && res.data.id)
                if (!!this.password.pass1 && this.password.pass1==this.password.pass1 && res.data[0].id){
                    
                    API.passwdUser(res.data[0].id, this.password.pass1).then(res=>this.$router.push({name: "users"}))
                } else {

                    this.$router.push({name: "users"})
                }
              },
              // err => console.log(err)
              err => this.$store.commit("error", err)
            )
        }

      },

    }


  }
</script>
