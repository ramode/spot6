<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <v-btn color="success" @click="test_notify">Tetst notify</v-btn>

      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>

  // import API from '@/lib/API'

  export default {

    data: () => ({
  }),

    mounted () {
      this.load();
    },

    methods: {
     
      load() {
      },

      test_notify() {
        this.$store.commit("addNotify", "aa");
      },

    }
 
  }

</script>
