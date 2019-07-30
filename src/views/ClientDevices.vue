<template>

        <material-data-card
          color="green"
          :title="$t('ClientDevices.title')"
          :text="$t('ClientDevices.small_text')"
          :headers="headers"
          :get-data="getData"
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
                  {{ item.profile_label }}
                </router-link>
            </template>

        </material-data-card>

</template>

<script>

import API from '@/lib/API'

export default {

  data: () => ({
    profiles: {},
    loading: false,
    items: [],
    getData: API.getClientDevices,
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

  },

  methods: {


  }

}

</script>

<style>

</style>
