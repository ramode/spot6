<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="blue darken-1" :title="$t('AuthTypes.title')" :text="$t('AuthTypes.title_small')" :loading="loading">

          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading text-info text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ item }">
              <td>{{ item.label }}</td>
              <td>{{ item.driver }}</td>
              
              <td class="text-xs-right">

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon :to="{name: 'auth_types_edit', params: {id: item.id}}">
                    <v-icon color="primary">mdi-pencil</v-icon>
                  </v-btn>
                  <span>{{ $t('Form.edit') }}</span>
                </v-tooltip>

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon @click="change_item(item)">
                    <v-icon :color="item.disabled ? 'warning' : 'grey'" >mdi-block-helper</v-icon>
                  </v-btn>
                  <span>{{ $t('Form.disable') }}</span>
                </v-tooltip>

              </td>
            </template>



          </v-data-table>



        </material-card>

    <v-fab-transition>
      <v-btn dark fab fixed bottom right color="primary" :to='{ name: "auth_types_add" }' v-if="['super', 'admin'].includes($auth.user().role)">
        <v-icon>mdi-plus</v-icon>
      </v-btn>
    </v-fab-transition>



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
          { value: null }
        ];
      },

    },

    methods: {
     
      load() {

        this.loading = 0

        API.getMyAuthTypes().then(
          res => this.items = res.data,
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
