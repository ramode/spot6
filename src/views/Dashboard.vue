<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>

      <v-flex md12>
        <v-btn color="success" @click="test_notify">Tetst notify</v-btn>
      </v-flex>

      <v-flex sm6 xs12 md6 lg3>
        <material-stats-card
          color="green"
          icon="mdi-store"
          title="Clients"
          value="$34,245"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex sm6 xs12 md6 lg3>
        <material-stats-card
          color="orange"
          icon="mdi-content-copy"
          title="Admins/Managers"
          value="49/50"
          small-value="accs"
          sub-icon="mdi-alert"
          sub-icon-color="error"
          sub-text="Account management"
          sub-text-color="text-primary"
        />
      </v-flex>


      <v-flex md12 lg6>
        <material-card color="purple" title="Invites" text="Secret codes for registrations">
          <v-btn color="purple" @click="create_invite">Create Invite</v-btn>
          <v-data-table :headers="invites_headers" :items="invites" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span class="font-weight-light text-warning text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ index, item }">
              <td>{{ index + 1 }}</td>
              <td>{{ item.name }}</td>
              <td class="text-xs-right">{{ item.salary }}</td>
              <td class="text-xs-right">{{ item.country }}</td>
              <td class="text-xs-right">{{ item.city }}</td>
            </template>

          </v-data-table>
        </material-card>
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
        this.$store.commit("addNotify", "Test Notify");
      },

      create_invite() {

      },

    }
 
  }

</script>
