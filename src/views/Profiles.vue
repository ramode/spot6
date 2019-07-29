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
        <material-table-card
          color="blue-grey"
          :title="$t('Profile.profile_list')"
          :text="$t('Profile.profile_list_small')"
          :loading="loading"
          :headers="headers"
          :items="items"
          :disable-item="change_item"
          add-item="profile_add"
          edit-item="profile_edit"
          :add-roles="['super', 'admin','manager']"
          :edit-roles="['super', 'admin','manager']"
        >
          <template
            slot="item.limit_speed"
            slot-scope="{ item }"
          >
            {{ Math.floor(item.limit_speed/1024/1024) }} Mb/s
          </template>
          <template
            slot="item.auth_types"
            slot-scope="{ item }"
          >
            <v-chip v-for="at in item.auth_types">
              {{ auth_types[at] }}
            </v-chip>
          </template>
        </material-table-card>
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
    auth_types: {}

  }),

  computed: {

    headers: function () {
      return [
        { text: this.$t('DB.label'), value: 'label', sortable: true },
        { text: this.$t('DB.theme'), value: 'theme', sortable: false },
        { text: this.$t('DB.limit_time'), value: 'limit_time', sortable: false },
        { text: this.$t('DB.limit_speed'), value: 'limit_speed', sortable: false },
        { text: this.$t('DB.auth_types'), value: 'auth_types', sortable: false },
        { text: '', value: 'actions', align: 'end' }
      ]
    }

  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      this.loading = 0

      // Для замены в таблице ID'шников аутх-типа на буквенное название:
      API.getAuthTypes().then(
        res => {
          this.loading += 50
          res.data.forEach((item, i) => {
            this.auth_types[ item['id'] ] = item['label']
          })
          // TODO есть смысл переделать на http://postgrest.org/en/v5.2/api.html#resource-embedding а апдейт без жоина

          // После того, как справочник auth_types заполнен, получаем список с севрака и заеняем ID на NAME:
          // Не делал JOIN на серваке, чтобы можно было UDPATE'ить VIEW'ху
          API.getProfiles().then(
            res => {
              // console.log(res);
              this.items = res.data
              //                res.data.forEach((item, i) => {
              //                  this.items.push(item);
              //                });
              this.loading += 50
            },
            err => this.$store.commit('error', err)
          )
        },
        err => this.$store.commit('error', err)
      )
    },

    change_item (item) {
      this.loading = true

      if (item.disabled == false) {
        item.disabled = true
      } else {
        item.disabled = false
      };

      var data = {
        id: item.id,
        disabled: item.disabled
      }

      API.updateProfile(data).then(
        res => { this.loading = 100 },
        err => this.$store.commit('error', err)
      )
    }

  }

}

</script>
