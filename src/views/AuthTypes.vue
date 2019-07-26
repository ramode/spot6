<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>


        <material-table-card 
            color="blue darken-1" 
            :title="$t('AuthTypes.title')" 
            :text="$t('AuthTypes.title_small')" 
            :loading="loading" 
            :headers="headers" 
            :items="items" 
            :change_item="change_item" 
            add_item="auth_types_add" 
            edit_item="auth_types_edit" 
            :add_roles="['super', 'admin']" 
            :edit_roles="['super', 'admin']"
        >
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

    }),

    mounted () {
      this.load();
    },

    computed: {

      headers: function() {
        return [
          { text: this.$t("AuthTypes.label"), value: 'label', sortable: true, },
          { text: this.$t("AuthTypes.driver"), value: 'driver', sortable: false, },
          { text: '', value: 'actions', align: 'end' }
        ];
      },

    },

    methods: {
     
      load() {

        this.loading = 0

        API.getMyAuthTypes().then(
          res => {this.items = res.data; this.loading = 100},
          err => this.$store.commit("error", err)
        );

      },

      change_item(item) {
          this.loading = true;

          if ( item.disabled == false ) {
            item.disabled = true;
          } else {
            item.disabled = false;
          };

          var data = {
            id: item.id,
            disabled: item.disabled
          };

          API.updateAuthType(data).then(
            res => this.loading = 100,
            err => this.$store.commit("error", err)
          );

        },

    },
 
  }

</script>
