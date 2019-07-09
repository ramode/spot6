<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout justify-center wrap>
      <v-flex md12>

        <material-card color="grey" :title="$t('Nases.nas_list')" :text="$t('Nases.nas_list_small')" :loading="loading">
        <!-- <material-card color="grey" :title="$t('Nases.nas_list')" :text="$t('Nases.nas_list_small')"> -->
          <v-data-table :headers="headers" :items="items" hide-actions>
            
            <template slot="headerCell" slot-scope="{ header }">
              <span
                class="subheading text-info text--darken-3" v-text="header.text" />
            </template>
            
            <template slot="items" slot-scope="{ item }">
              <td>{{ item.label }}</td>
              <td>{{ item.nastype }}</td>
              <td>{{ item.ident }}</td>
              <td class="text-xs-right">

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon :to="{ name: 'nas_edit', params: {id: item.id} }">
                    <v-icon color="success">mdi-pencil</v-icon>
                  </v-btn>
                  <span>Edit</span>
                </v-tooltip>

                <v-tooltip top content-class="top">
                  <v-btn slot="activator" class="v-btn--simple" icon @click="change_item(item)">
                    <v-icon :color="item.disabled ? 'pink' : 'grey'" >mdi-block-helper</v-icon>
                  </v-btn>
                  <span>Disable</span>
                </v-tooltip>

              </td>
            </template>

          </v-data-table>
        </material-card>

        <v-btn color="primary" class="right" :to='{ name: "nas_add" }'>{{ $t('Common.add') }}</v-btn>

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

    computed: {

      headers: function() {
        return [
          { text: this.$t("DB.label"), value: 'label', sortable: true, },
          { text: this.$t("Nases.nas_type"), value: 'nastype', sortable: false, },
          { text: this.$t("Nases.nas_ident"), value: 'ident', sortable: false, },
          // { text: this.$t("Nases.nas_location_id"), value: 'location_id', sortable: false, },
          // { text: this.$t("Nases.nas_location_name"), value: 'location_name', sortable: false, },
          {}
        ];
      },

    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        API.getNases().then(
          res => {
            // console.log(res);
            this.items = res.data;
            this.loading = false;
          },
          err => {
            this.$store.commit("error", err);
            this.loading = false;
          }
        );

      },

      change_item(item) {

        if ( item.disabled == false ) {
          item.disabled = true;
        } else {
          item.disabled = false;
        };

        var data = {
          id: item.id,
          disabled: item.disabled
        };

        API.updateNas(data).then(
          res => {},
          err => this.$store.commit("error", err)
        );

      },


    }
 
  }

</script>
