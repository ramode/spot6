<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="green" :title="$t('Users.title')" :text="$t('Users.title_small')">
          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading text-info text--darken-3"  v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ item }">
              <td>{{ item.label }}</td>
              <td>{{ item.login }}</td>
              <td>{{ item.phone }}</td>
              <td>{{ item.email }}</td>
              <td>{{ item.role }}</td>
              <td class="text-xs-right">

                <!--v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon :to="{name: 'user_passwd', params: {id: item.id}}">
                    <v-icon color="success">mdi-lock-reset</v-icon>
                  </v-btn>
                  <span>Passwd</span><!- установка пароля через функцию api.passwd(uid,password) !->
                </v-tooltip-->

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" icon :to="{name: 'user_edit', params: {id: item.id}}">
                    <v-icon color="primary">mdi-pencil</v-icon>
                  </v-btn>
                  <span>{{ $t('Form.edit') }}</span>
                </v-tooltip>

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" icon @click="change_item(item)">
                    <v-icon :color="item.disabled ? 'warning' : 'grey'" >mdi-block-helper</v-icon>
                  </v-btn>
                  <span>{{ $t('Form.disable') }}</span>
                </v-tooltip>

              </td>
            </template>

          </v-data-table>
        </material-card>

    <v-fab-transition>
      <v-btn
        dark
        fab
        fixed
        bottom
        right
        color="primary"
        :to='{ name: "user_add" }'
        v-if="['super', 'admin'].includes($auth.user().role)"
      >
        <v-icon>mdi-plus</v-icon>
      </v-btn>
    </v-fab-transition>



      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({
      
      items: [],

    }),

    computed: {

      headers: function() {
        return [
          { text: this.$t("Users.label"), value: 'label', sortable: true, },
          { text: this.$t("Users.login"), value: 'login', sortable: true, },
          { text: this.$t("Users.phone"), value: 'phone', sortable: true, },
          { text: this.$t("Users.email"), value: 'email', sortable: true, },
          { text: this.$t("Users.role"), value: 'role', sortable: true, },
          { value: null }
        ]
      }
    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {
          API.getUsers().then(
            res => {
              // console.log(res.data);
              this.items = res.data;
            },
            err => console.log(err)
          );
      },

      change_item(item) {

        if ( item.disabled == false ) {
          item.disabled = true;
        } else {
          item.disabled = false;
        };

        var data = {
          id: item.id,
          disabled: item.disabled
        };

        API.updateUser(data).then(
          res => {},
          err => console.log(err)
        );

      },


    }
 
  }

</script>
