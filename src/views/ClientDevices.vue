<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="light-green" :title="$t('ClientDevices.title')" :text="$t('ClientDevices.small_text')" :loading="loading">

          <v-layout justify-center wrap>
            <v-flex xs12 md3>
              
              <v-menu ref="menu_start_date" v-model="menu_start_date"
                :close-on-content-click="false" nudge-right="40" lazy transition="scale-transition"
                offset-y full-width max-width="290px" min-width="290px"
              >
              
                <template v-slot:activator='{ on }'>
                  
                  <v-text-field v-model="start_date" label="Start date" prepend-icon="event" readonly v-on="on"></v-text-field>

                </template>
                
                <v-date-picker v-model="start_date" no-title scrollable>
                  <v-spacer></v-spacer>
                  <v-btn flat color="primary" @click="menu_start_date = false">Cancel</v-btn>
                  <v-btn flat color="primary" @click="$refs.menu_start_date.save(start_date)">OK</v-btn>
                </v-date-picker>

              </v-menu>

            </v-flex>

            <v-flex xs12 md3>
              
              <v-menu ref="menu_end_date" v-model="menu_end_date"
                :close-on-content-click="false" nudge-right="40" lazy transition="scale-transition"
                offset-y full-width max-width="290px" min-width="290px"
              >
              
                <template v-slot:activator='{ on }'>
                  
                  <v-text-field v-model="end_date" label="End date" prepend-icon="event" readonly v-on="on"></v-text-field>

                </template>
                
                <v-date-picker v-model="end_date" no-title scrollable>
                  <v-spacer></v-spacer>
                  <v-btn flat color="primary" @click="menu_end_date = false">Cancel</v-btn>
                  <v-btn flat color="primary" @click="$refs.menu_end_date.save(end_date)">OK</v-btn>
                </v-date-picker>

              </v-menu>

            </v-flex>

            <v-flex xs12 md1>
              <v-btn color="success" @click="getData">{{ $t('Form.search') }}</v-btn>
            </v-flex>

            <v-flex xs12 md6>
              <v-text-field v-model="search" append-icon="search" label="Filter" single-line hide-details></v-text-field>
            </v-flex>

          </v-layout>

            

          

          <v-data-table :headers="headers" :items="items" :search="search" loading>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span class="font-weight-light" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ index, item }">
              <!-- <td>{{ index + 1 }}</td> -->
              <td>{{ item.username }}</td>
              <td>{{ item.phone }}</td>
              <td>{{ item.mac }}</td>
              <td>{{ item.time_registred | moment("YYYY-MM-DD, HH:MM") }}</td>
              <td>{{ item.time_seen | moment("YYYY-MM-DD, HH:MM") }}</td>
              <td>{{ item.profile_seen }}</td>
            </template>

          </v-data-table>

        </material-card>

      </v-flex>
    </v-layout>

    <!-- <v-btn fab dark fixed right bottom>
        <v-icon dark>mdi-arrow-right</v-icon>
    </v-btn> -->

  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({

      loading: false,
      
      menu_start_date: false,
      menu_end_date: false,

      start_date: null,
      end_date: new Date().toISOString().substr(0, 10),
      

      search: "",
      
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

        // В computed нельзя совать, т.к. иначе потому не сетится, только читается:
        this.start_date = ( function() {
          var d = new Date();
          d.setMonth( d.getMonth() - 1 );
          d = d.toISOString().substr(0, 10);
          return d;
        })();

      },

      getData() {

        this.loading = true;

        // get Devices list:
        API.getClientDevices(this.start_date, this.end_date).then(
          res => {
            console.log(res);
            this.items = res.data;
            this.loading = false;
          },
          err => {
            this.$store.commit("error", err);
            this.loading = false;
          }
        );

      },

    }
 
  }

</script>

<style>

  .v-btn__content {
    color: black;
  }

</style>