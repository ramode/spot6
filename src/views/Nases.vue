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
          color="grey darken-1"
          :title="$t('Nases.nas_list')"
          :text="$t('Nases.nas_list_small')"
          :loading="loading"
          :headers="headers"
          :items="items"
          :disable-item="change_item"
          add-item="nas_add"
          edit-item="nas_edit"
          :add-roles="['super', 'admin']"
          :edit-roles="['super', 'admin']"
        />
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

import API from '@/lib/API'

export default {

  data: () => ({

    loading: true,
    items: []

  }),

  computed: {

    headers: function () {
      return [
        { text: this.$t('DB.label'), value: 'label', sortable: true },
        { text: this.$t('Nases.nas_type'), value: 'nastype', sortable: false },
        { text: this.$t('Nases.nas_ident'), value: 'ident', sortable: false },
        { text: this.$t('Nases.nas_location_id'), value: 'location_id', sortable: false },
        // { text: this.$t("Nases.nas_location_name"), value: 'location_name', sortable: false, },
        { text: '', value: 'actions', align: 'end' }
      ]
    }

  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      API.getNases().then(
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
    },

    change_item (item) {
      if (item.disabled == false) {
        item.disabled = true
      } else {
        item.disabled = false
      };

      var data = {
        id: item.id,
        disabled: item.disabled
      }

      API.updateNas(data).then(
        res => {},
        err => this.$store.commit('error', err)
      )
    }

  }

}

</script>
