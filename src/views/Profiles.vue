<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="teal" title="Profiles" text="Profiles for your Wi-Fi access devices">
          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading font-weight-light text-success text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ item }">
              <td>{{ item.name }}</td>
              <td>{{ item.skin }}</td>
              <td>{{ item.tarif_min }}</td>
              <td>{{ item.tarif_mb }} Mb</td>
              <td>{{ item.tarif_speed }} Mbps</td>
              <td>{{ item.auth_type }}</td>
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

        <v-btn color="success" class="right" :to='{ name: "profile_add" }' v-if="['su', 'admin'].includes($auth.user().role)">Add</v-btn>

      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({

      headers: [
        { text: 'Name', value: 'name', sortable: true, },
        { text: 'Skin Dir', value: 'skin', sortable: false, },
        { text: 'Minutes', value: 'tarif_min', sortable: false, },
        { text: 'Traffic Limit', value: 'tarif_mb', sortable: false, },
        { text: 'Speed', value: 'tarif_speed', sortable: false, },
        { text: 'Auth Type', value: 'auth_type', sortable: false, },
        {}
      ],

      items: [],
      auth_types: {},

    }),

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        // Для замены в таблице ID'шников аутх-типа на буквенное название:
        API.getAuthTypes().then(
          res => {

            res.data.forEach((item, i) => {
              this.auth_types[ item['id'] ] = item['name'];
            });

            // После того, как справочник auth_types заполнен, получаем список с севрака и заеняем ID на NAME:
            // Не делал JOIN на серваке, чтобы можно было UDPATE'ить VIEW'ху
            API.getProfiles().then(
              res => {
                res.data.forEach((item, i) => {
                  item['auth_type'] = this.auth_types[ item['auth_type'] ];
                  this.items.push(item);
                });
              },
              err => this.$store.commit("error", err)
            );

          },
          err => this.$store.commit("error", err)
        )

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

        API.updateProfile(data).then(
          res => {},
          err => this.$store.commit("error", err)
        );

      },

    }
 
  }

</script>
