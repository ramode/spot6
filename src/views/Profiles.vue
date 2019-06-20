<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="blue-grey" :title="$t('Profile.profile_list')" :text="$t('Profile.profile_list_small')" :loading="loading">
          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading font-weight-light text-success text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ item }">
              <td>{{ item.label }}</td>
              <td>{{ item.theme }}</td>
              <!-- <td>{{ item.session_time | mf_time_human_duration }}</td> -->
              <td>{{ item.limit_time }}</td>
              <td>{{ Math.floor(item.limit_speed/1024/1024) }} Mb/s</td>
              <td><v-chip v-for="at in item.auth_types" >{{auth_types[at]}}</v-chip></td>
              <td class="text-xs-right">

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon :to="{name: 'profile_edit', params: {id: item.id}}">
                    <v-icon color="success">mdi-pencil</v-icon>
                  </v-btn>
                  <span>Edit</span>
                </v-tooltip>

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon @click="change_item(item)">
                    <v-icon :color="item.disabled ? 'pink' : 'grey'" >mdi-block-helper</v-icon>
                  </v-btn>
                  <span>Disable</span>
                </v-tooltip>

              </td>
            </template>

          </v-data-table>
        </material-card>

        <v-btn color="success" class="right" :to='{ name: "profile_add" }' v-if="['super', 'admin'].includes($auth.user().role)">Add</v-btn>

      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({
      loading: true,

      items: [],
      auth_types: {},

    }),

    mounted () {
      this.load();
    },

    computed: {

      headers: function() {
        return [
          { text: this.$t("DB.label"), value: 'label', sortable: true, },
          { text: this.$t("DB.theme"), value: 'theme', sortable: false, },
          { text: this.$t("DB.limit_time"), value: 'limit_time', sortable: false, },
          { text: this.$t("DB.limit_speed"), value: 'limit_speed', sortable: false, },
          { text: this.$t("DB.auth_types"), value: 'auth_types', sortable: false, },
          {}
        ];
      },

    },

    methods: {
     
      load() {
        this.loading = 0

        // Для замены в таблице ID'шников аутх-типа на буквенное название:
        API.getAuthTypes().then(
          res => {
            this.loading += 50
            res.data.forEach((item, i) => {
              this.auth_types[ item['id'] ] = item['label'];
            });

            // После того, как справочник auth_types заполнен, получаем список с севрака и заеняем ID на NAME:
            // Не делал JOIN на серваке, чтобы можно было UDPATE'ить VIEW'ху
            API.getProfiles().then(
              res => {
                res.data.forEach((item, i) => {
                  this.items.push(item);
                });
                this.loading += 50
              },
              err => this.$store.commit("error", err)
            );

          },
          err => this.$store.commit("error", err)
        )

      },

      change_item(item) {
        this.loading = true;

        if ( item.disabled == false ) {
          item.disabled = true;
        } else {
          item.disabled = false;
        };

        var data = {
          id: item.id,
          disabled: item.disabled
        };

        API.updateProfile(data).then(
          res => {this.loading = 100},
          err => this.$store.commit("error", err)
        );

      },

    }
 
  }

</script>
