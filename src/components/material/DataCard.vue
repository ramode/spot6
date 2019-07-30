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
    :color="color"
    :title="title"
    :text="text"
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
                    @click="$refs.period_menu.save(start_date); load()"
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
        v-for="(_, slot) of $scopedSlots"
        v-slot:[slot]="scope"
      >
        <slot
          :name="slot"
          v-bind="scope"
        />
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

  props: {
    color: String,
    title: String,
    text: String,
    headers: Array,
    getData: Function
  },

  data: () => ({
    loading: 0,
    period_menu: false,
    start_date: null,
    search: '',
    items: [],
  }),

  computed: {

    end_date: function () {
      if (this.start_date) {
      var d = new Date(this.start_date + '-01')
      d.setMonth(d.getMonth() + 1)
      d = d.toISOString().substr(0, 7)
      return d
        }
    },

  },

  mounted () {
      this.start_date = (function () {
        var d = new Date()
        d = d.toISOString().substr(0, 7)
        return d
      })()
    this.load()
  },

  methods: {
    load () {
      this.loading = true
      this.getData(this.start_date + '-01', this.end_date + '-01').then(
        res => {
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
