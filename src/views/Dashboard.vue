<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="green"
          icon="mdi-store"
          title="Clients"
          :value="dashboard.client_devices"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg4>
        <material-stats-card
          color="orange"
          icon="mdi-content-copy"
          title="Admins/Managers"
          :value="`${dashboard.admins}/${dashboard.managers}`"
          small-value="accs"
          sub-icon="mdi-alert"
          sub-icon-color="error"
          sub-text="Account management"
          sub-text-color="text-primary"
        />
      </v-flex>

      
      <!-- <v-flex md12>
        <v-btn color="success" @click="test_notify">Tetst notify</v-btn>
      </v-flex> -->


    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data () {
      return {

        dashboard: {},

      }
    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        // Maybe on API change to function for GRANT RULE issues:
        API.Dashboard().then(
          res => {
            res.data[0].client_devices = res.data[0].client_devices.toString();
            this.dashboard = res.data[0];
          },
          err => this.$store.commit("error", err)
        );

      },

      test_notify() {
        this.$store.commit("addNotify", "Test Notify");
      },

    },
 
  }

</script>
