<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

          404 Not found

      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data: () => ({
    }),

    mounted () {
      this.load();
    },

    methods: {
     
      load() {
      },

    }
 
  }

</script>
