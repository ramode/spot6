<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="light-green" :title="$t('ClientDevices.title')" :text="$t('ClientDevices.small_text')">
          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span class="font-weight-light" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ index, item }">
              <!-- <td>{{ index + 1 }}</td> -->
              <td>{{ item.username }}</td>
              <td>{{ item.phone }}</td>
              <td>{{ item.mac }}</td>
              <td>{{ item.time_registred | moment("YYYY-mm-DD, HH:MM") }}</td>
              <td>{{ item.time_seen | moment("YYYY-mm-DD, HH:MM") }}</td>
              <td>{{ item.profile_seen }}</td>
            </template>

          </v-data-table>
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
      
      items: [],

    }),

    computed: {

      headers: function() {
        return [
          {
            sortable: false,
            text: this.$t('ClientDevices.username'),
            value: 'username'
          },
          {
            sortable: false,
            text: this.$t('ClientDevices.phone'),
            value: 'phone'
          },
          {
            sortable: false,
            text: this.$t('ClientDevices.mac'),
            value: 'mac'
          },
          {
            sortable: false,
            text: this.$t('ClientDevices.time_register'),
            value: 'time_register'
          },
          {
            sortable: false,
            text: this.$t('ClientDevices.time_seen'),
            value: 'time_seen'
          },
          {
            sortable: false,
            text: this.$t('ClientDevices.profile_seen'),
            value: 'profile_seen'
          },
        ];
      },

    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {
        
        // get Devices list:
        API.getClientDevices().then(
          res => {
            // console.log(res);
            this.items = res.data
          },
          err => this.$store.commit("error", err)
        );

      },

    }
 
  }

</script>
