<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="light-green" :title="$t('Accounting.title')" :text="$t('Accounting.small_text')" :loading="loading">

          <v-layout justify-center wrap>
            <v-flex xs12 md2>
              
              <v-menu ref="menu_start_date" v-model="menu_start_date"
                :close-on-content-click="false" nudge-right="40" lazy transition="scale-transition"
                offset-y full-width max-width="290px" min-width="290px"
              >
              
                <template v-slot:activator='{ on }'>
                  
                  <v-text-field v-model="start_date" :label="$t('Accounting.start_date')" prepend-icon="event" v-on="on" readonly type="date"></v-text-field>

                </template>
                
                <v-date-picker v-model="start_date" no-title scrollable show-current  @input="menu_start_date = false">

                </v-date-picker>

              </v-menu>

            </v-flex>

            <v-flex xs12 md2>
              
              <v-menu ref="menu_end_date" v-model="menu_end_date"
                :close-on-content-click="false" nudge-right="40" lazy transition="scale-transition"
                offset-y full-width max-width="290px" min-width="290px"
              >
              
                <template v-slot:activator='{ on }'>
                  
                  <v-text-field v-model="end_date" :label="$t('Accounting.end_date')" readonly type="date" v-on="on"></v-text-field>

                </template>
               
                <v-date-picker v-model="end_date" no-title scrollable show-current  @input="menu_end_date = false">
                </v-date-picker>
              </v-menu>
            </v-flex>

            <v-flex xs12 md2>
              <v-btn @click="getData">{{ $t('Form.search') }}</v-btn>
            </v-flex>

            <v-flex xs12 md3>
              <v-text-field v-model="search" append-icon="mdi-filter" :label="$t('Form.filter')" single-line hide-details></v-text-field>
            </v-flex>
          </v-layout>
          <v-data-table :headers="headers" :items="items" :search="search" loading  :rows-per-page-items="[10]">
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading text-info text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ index, item }">
              <!-- <td>{{ index + 1 }}</td> -->
              <td>{{ item.phone }}</td>
              <td>{{ item.mac }}</td>
              <!-- <td>{{ item.nas }} / {{ item.ip }} / {{ item.called_station_id }}</td> -->
              <td>{{ [ item.nas, item.ip, item.called_station_id ].join(' / ')}}</td>
              <td>{{ item.time_start | moment("YYYY-MM-DD, HH:MM") }}</td>
              <td>{{ item.time_end | moment("YYYY-MM-DD, HH:MM") }}</td>
              <td>{{ item.uptime }}</td>
              <td>{{ item.ip }}</td>
              <td>↓ {{ item.download }} ↑ {{ item.upload }}</td>
              <td>{{ item.profile }}</td>
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
      
      pagination: {},

      search: "",
      
      items: [],

    }),

    computed: {

      headers: function() {
        return [
          {
            sortable: false,
            text: this.$t('Accounting.phone'),
            value: 'phone'
          },
          {
            sortable: false,
            text: this.$t('Accounting.mac'),
            value: 'mac'
          },
          {
            sortable: false,
            text: this.$t('Accounting.nas'),
            value: 'nas'
          },
          {
            sortable: false,
            text: this.$t('Accounting.time_start'),
            value: 'time_start'
          },
          {
            sortable: false,
            text: this.$t('Accounting.time_end'),
            value: 'time_end'
          },
          {
            sortable: false,
            text: this.$t('Accounting.uptime'),
            value: 'uptime'
          },
          {
            sortable: false,
            text: this.$t('Accounting.ip'),
            value: 'ip'
          },
          {
            sortable: false,
            text: this.$t('Accounting.traffic'),
            value: 'download'
          },
          {
            sortable: false,
            text: this.$t('Accounting.profile'),
            value: 'profile'
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
        API.getAccounting(this.start_date, this.end_date).then(
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



</style>
