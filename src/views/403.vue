<template>
  <v-container
    fill-height
    fluid
    grid-list-xl
  >
    <v-layout
      align-center
      justify-center
      fill-height
      row
    >
      <h3>
        {{ $t('Common.PermissionDenied') }}
      </h3>
    </v-layout>
  </v-container>
</template>

<script>

import API from '@/lib/API'

export default {

  data: () => ({
  }),

  mounted () {
    this.load()
  },

  methods: {

    load () {
    }

  }

}

</script>
