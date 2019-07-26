<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="light-green" :title="$t('Accounting.title')" :text="$t('Accounting.small_text')" :loading="loading">

          <v-layout wrap>
  <v-flex xs12 md3>
      <v-menu
        ref="period_menu"
        v-model="period_menu"
        :close-on-content-click="false"
        :nudge-right="40"
        :return-value.sync="start_date"
        lazy
        offset-y
        full-width
        max-width="290px"
        min-width="290px"
      >
        <template v-slot:activator="{ on }">
          <v-text-field
            v-model="start_date"
            :label="$t('Accounting.period')"
            append-icon="mdi-calendar-range"
            readonly
            v-on="on"
          ></v-text-field>
        </template>
        <v-date-picker
          v-model="start_date"
          type="month"
          no-title
          scrollable
        >
          <v-spacer></v-spacer>
          <v-btn flat color="primary" @click="$refs.period_menu.save(start_date); getData()">OK</v-btn>
        </v-date-picker>
      </v-menu>
    </v-flex>

            <v-flex xs12 md3>
              <v-text-field v-model="search" append-icon="mdi-filter" :label="$t('Form.filter')" single-line hide-details></v-text-field>
            </v-flex>
          </v-layout>
          <v-data-table :headers="headers" :items="items" :search="search"   dense
:footer-props="{
      showFirstLastPage: true,
      itemsPerPageOptions : [30]
    }">
            


            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading text-info text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ index, item }" selected="true">
              <!-- <td>{{ index + 1 }}</td> -->
              <td><v-icon v-if="item.termination_cause == null">mdi-lan-connect</v-icon></td>
              <td>{{ item.phone }}</td>
              <td>{{ item.mac }}</td>
              <td>{{ item.ip }}</td>
              <!-- <td>{{ item.nas }} / {{ item.ip }} / {{ item.called_station_id }}</td> -->
              <td>{{ [ item.nas, item.nas_ip ].join(' / ')}}</td>
              <td>{{ item.time_start | moment("YYYY‑MM‑DD, HH:mm") }}</td>
              <td>{{ item.time_end | moment("YYYY‑MM‑DD, HH:mm") }}</td>
              <td>{{ item.uptime }}</td>

              <td>↓&nbsp;{{ item.download || 0 | prettyBytes(1) }} ↑&nbsp;{{ item.upload || 0 | prettyBytes(1) }}</td>
              <td><router-link :to="{ name: 'profile_edit', params: { id: item.profile_id } }">{{ item.profile_label }}</router-link></td>
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
      
      period_menu: false,

      start_date: null,
      
      pagination: {},

      search: "",
      
      items: [],

    }),

    computed: {

      end_date:  function() {
            var d = new Date(this.start_date+'-01')
            d.setMonth(d.getMonth()+1)
            d = d.toISOString().substr(0, 7);
            return d
            },

      headers: function() {
        return [
          {
            sortable: false,
            value: null
          },
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
            text: this.$t('Accounting.ip'),
            value: 'ip'
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
          d = d.toISOString().substr(0, 7);
          return d;
        })();

        console.log(this.start_date)

        this.getData() 
        
      },

      getData() {

        this.loading = true;

        // get Devices list:
        API.getAccounting(this.start_date+'-01', this.end_date+'-01').then(
          res => {
            // console.log(res);
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
