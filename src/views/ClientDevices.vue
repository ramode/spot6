<template>
  <v-container
    fill-height
    fluid
    grid-list-xl
  >
    <v-layout
      justify-center
      wrap
    >
      <v-flex md12>
        <material-card
          color="green"
          :title="$t('ClientDevices.title')"
          :text="$t('ClientDevices.small_text')"
          :loading="loading"
        >



          <template slot="topactions">

              <v-menu
                ref="period_menu"
                v-model="period_menu"
                :close-on-content-click="false"
                :nudge-right="40"
                :return-value.sync="start_date"
                offset-y
                full-width
                max-width="290px"
                min-width="290px"
              >
                <template v-slot:activator="{ on }">
                  <v-text-field
    
rounded
    
    single-line
    
                    v-model="start_date"
                    :label="$t('Accounting.period')"
                    prepend-inner-icon="mdi-calendar-range"
                    readonly
                    v-on="on"
                    hide-details
                    style="max-width:15em"
                  />
                </template>
                <v-date-picker
                  v-model="start_date"
                  type="month"
                  no-title
                  scrollable
                >
                  <v-spacer />
                  <v-btn
                    text
                    color="primary"
                    @click="$refs.period_menu.save(start_date); getData()"
                  >
                    OK
                  </v-btn>
                </v-date-picker>
              </v-menu>

              <v-text-field
    
                        style="max-width:15em"
rounded
single-line
autofocus
                v-model="search"
                prepend-inner-icon="mdi-filter"
                :label="$t('Form.filter')"
                single-line
                hide-details
              />

          </template>

          
          
          <v-data-table
            :headers="headers"
            :items="items"
            :search="search"
      hide-default-footer
      disable-pagination
          >

            <template
              slot="item.time_registred"
              slot-scope="{ item }"
            >
              {{ item.time_registred| moment("YYYY‑MM‑DD, HH:mm") }}
            </template>


            <template
              slot="item.time_seen"
              slot-scope="{ item }"
            >
              {{ item.time_seen| moment("YYYY‑MM‑DD, HH:mm") }}
            </template>

            <template
              slot="item.profile_seen"
              slot-scope="{ item }"
            >
                <router-link :to="{name:'profile_edit', params: {id: item.profile_id} }">
                  {{ profiles[item.profile_id] }}
                </router-link>
            </template>



            <template
              slot="items"
              slot-scope="{ index, item }"
            >
              <!-- <td>{{ index + 1 }}</td> -->
              <td>{{ item.username }}</td>
              <td>{{ item.phone }}</td>
              <td>{{ item.mac }}</td>
              <td>{{ item.time_registred | moment("YYYY-MM-DD, HH:mm") }}</td>
              <td>{{ item.time_seen | moment("YYYY-MM-DD, HH:mm") }}</td>
              <td>
                <router-link :to="{name:'profile_edit', params: {id: item.profile_id} }">
                  {{ profiles[item.profile_id] }}
                </router-link>
              </td>
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
    profiles: {},
    period_menu: false,
    loading: false,

    // Search field in DB: time_seen or time_registred
    date_field: 'time_seen',

    menu_start_date: false,
    menu_end_date: false,

    start_date: null,

    pagination: {},

    search: '',

    items: []

  }),

  computed: {
    end_date: function () {
      var d = new Date(this.start_date + '-01')
      d.setMonth(d.getMonth() + 1)
      d = d.toISOString().substr(0, 7)
      return d
    },
    headers: function () {
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
          value: 'time_registred'
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
        }
      ]
    }

  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      // В computed нельзя совать, т.к. иначе потому не сетится, только читается:
      this.start_date = (function () {
        var d = new Date()
        d = d.toISOString().substr(0, 7)
        return d
      })()

      // TODO есть смысл переделать на http://postgrest.org/en/v5.2/api.html#resource-embedding
      API.getProfiles().then(
        res => {
          res.data.forEach((item, i) => {
            this.profiles[ item['id'] ] = item['label']
          })
          this.loading = 15
          this.getData()
        },
        err => this.$store.commit('error', err)
      )
    },

    getData () {
      this.loading = true

      // get Devices list:
      API.getClientDevices(this.start_date + '-01', this.end_date + '-01').then(
        res => {
          console.log(res);
          this.items = res.data
          this.loading = false
        },
        err => {
          this.$store.commit('error', err)
          this.loading = false
        }
      )
    }

  }

}

</script>

<style>

</style>
