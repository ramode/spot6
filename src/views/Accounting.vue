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
          color="deep-purple"
          :title="$t('Accounting.title')"
          :text="$t('Accounting.small_text')"
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
            dense
            :footer-props="{
              showFirstLastPage: true,
              itemsPerPageOptions : [30, -1]
            }"
            :items-per-page="30"
          >
            <template
              slot="item.time_start"
              slot-scope="{ item }"
            >
              {{ item.time.lower| moment("YYYY‑MM‑DD, HH:mm") }}
            </template>

            <template
              slot="item.time_end"
              slot-scope="{ item }"
            >
              {{ item.time.upper| moment("YYYY‑MM‑DD, HH:mm") }}
            </template>

            <template
              slot="item.nas"
              slot-scope="{ item }"
            >
              {{ [ item.nas, item.nas_ip ].join(' / ') }}
            </template>
            <template
              slot="item.download"
              slot-scope="{ item }"
            >
              ↓&nbsp;{{ item.download || 0 | prettyBytes(1) }}
            </template>
            <template
              slot="item.upload"
              slot-scope="{ item }"
            >
              ↑&nbsp;{{ item.upload || 0 | prettyBytes(1) }}
            </template>

            <template
              slot="item.profile"
              slot-scope="{ item }"
            >
              <router-link
                v-if="item.profile_id"
                :to="{ name: 'profile_edit', params: { id: item.profile_id } }"
              >
                {{ item.profile_label }}
              </router-link>
            </template>

            <template
              slot="item.ip"
              slot-scope="{ item }"
            >
              {{ item.ip }}
              <v-icon v-if="item.termination_cause == null">
                mdi-lan-connect
              </v-icon>

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
          text: this.$t('Accounting.traffic') + '↓',
          value: 'download'
        },
        {
          sortable: false,
          text: '↑',
          value: 'upload'
        },
        {
          sortable: false,
          text: this.$t('Accounting.profile'),
          value: 'profile'
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

      console.log(this.start_date)

      this.getData()
    },

    getData () {
      this.loading = true

      // get Devices list:
      API.getAccounting(this.start_date + '-01', this.end_date + '-01').then(
        res => {
          // console.log(res);
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
