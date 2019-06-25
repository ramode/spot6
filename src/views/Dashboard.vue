<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="green"
          icon="mdi-store"
          title="Clients"
          :value="dashboard.client_devices"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg4>
        <material-stats-card
          color="orange"
          icon="mdi-content-copy"
          title="Admins/Managers"
          :value="`${dashboard.admins}/${dashboard.managers}`"
          small-value="accs"
          sub-icon="mdi-alert"
          sub-icon-color="error"
          sub-text="Account management"
          sub-text-color="text-primary"
        />
      </v-flex>


      <v-flex xs12>
        <material-card color="light-green" title="Client Devices" text="Your clients gadgets and sessions /ANDROID COLOR/">
          <v-data-table :headers="client_devices_headers" :items="client_devices" hide-actions>
            
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


      <!-- <v-flex md12>
        <v-btn color="success" @click="test_notify">Tetst notify</v-btn>
      </v-flex> -->


    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data () {
      return {

        dashboard: {},

        client_devices: [],
        client_devices_headers: [
          {
            sortable: false,
            text: 'Name',
            value: 'username'
          },
          {
            sortable: false,
            text: 'Phone',
            value: 'phone'
          },
          {
            sortable: false,
            text: 'MAC',
            value: 'mac'
          },
          {
            sortable: false,
            text: 'Registered',
            value: 'time_register'
          },
          {
            sortable: false,
            text: 'Seen',
            value: 'time_seen'
          },
          {
            sortable: false,
            text: 'Profile',
            value: 'profile_seen'
          },
        ],

      }
    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        // Maybe on API change to function for GRANT RULE issues:
        API.Dashboard().then(
          res => {
            res.data[0].client_devices = res.data[0].client_devices.toString();
            this.dashboard = res.data[0];
          },
          err => this.$store.commit("error", err)
        );


        // get Devices list:
        API.getClientDevices().then(
          res => {
            // console.log(res);
            this.client_devices = res.data
          },
          err => this.$store.commit("error", err)
        );

      },

      test_notify() {
        this.$store.commit("addNotify", "Test Notify");
      },

    },
 
  }

</script>
