<template>
        <material-data-card
          color="deep-purple"
          :title="$t('Accounting.title')"
          :text="$t('Accounting.small_text')"
          :headers="headers"
          :get-data="getData"
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
              slot="item.profile_label"
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
        </material-data-card>
</template>

<script>

import API from '@/lib/API'

export default {

  data: () => ({
     getData: API.getAccounting 
  }),

  computed: {

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
          value: 'profile_label'
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
