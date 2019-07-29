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
          color="orange"
          :title="$t('Users.title')"
          :text="$t('Users.title_small')"
          :loading="loading"
          :headers="headers"
          :items="items"
          :disable-item="change_item"
          add-item="user_add"
          edit-item="user_edit"
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
    loading: false,
    items: []

  }),

  computed: {

    headers: function () {
      return [
        { text: this.$t('Users.label'), value: 'label', sortable: true },
        { text: this.$t('Users.login'), value: 'login', sortable: true },
        { text: this.$t('Users.full_name'), value: 'full_name', sortable: true },
        { text: this.$t('Users.phone'), value: 'phone', sortable: true },
        { text: this.$t('Users.email'), value: 'email', sortable: true },
        { text: this.$t('Users.role'), value: 'role', sortable: true },
        { text: '', value: 'actions', align: 'end' }
      ]
    }
  },

  mounted () {
    this.load()
  },

  methods: {

    load () {
      API.getUsers().then(
        res => {
          // console.log(res.data);
          this.items = res.data
        },
        err => console.log(err)
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

      API.updateUser(data).then(
        res => {},
        err => console.log(err)
      )
    }

  }

}

</script>
