  <template>
      <material-card :color="color" :title="title" :text="text" :loading="loading">

          <v-data-table :headers="headers" :items="items" hide-default-footer disable-pagination>
            
<template v-for="(_, slot) of $scopedSlots" v-slot:[slot]="scope"><slot :name="slot" v-bind="scope"/></template>

             <template slot="item.actions" slot-scope="{ item }" v-if="edit_roles.includes($auth.user().role)">

<v-layout justify-end row>

                <v-tooltip top content-class="top">

            <template  v-slot:activator="{ on }">
          <v-btn small icon v-on="on" :to="{name: edit_item, params: {id: item.id}}">
                    <v-icon color="primary">mdi-pencil</v-icon>
                  </v-btn>            </template>
                  <span>{{ $t('Form.edit') }}</span>
                </v-tooltip>

               <v-tooltip top content-class="top">
                    <template  v-slot:activator="{ on }">
                  <v-btn small icon v-on="on" @click="change_item(item)">
                    <v-icon :color="item.disabled ? 'warning' : 'grey'" >mdi-block-helper</v-icon>
                  </v-btn>            </template>
                  <span>{{ $t('Form.disable') }}</span>
                </v-tooltip>
            </v-layout>
            </template>



          </v-data-table>
            <template name="table" />

    <v-fab-transition  v-if="add_roles.includes($auth.user().role)">
 
    <v-tooltip top content-class="top">
<template v-slot:activator="{ on }">

      <v-btn
        dark
        fab
        fixed
        bottom
        right
        color="primary"
        :to='{ name: add_item }'
        v-on="on"
      >
        <v-icon>mdi-plus</v-icon>
      </v-btn>
      </template>
        <span>{{ $t('Common.add') }}</span>

    </v-tooltip>
    </v-fab-transition>

    </material-card>
</template>

<script>

export default {

    props: {
        color: String,
        title: String,
        text: String,
        loading: [Boolean, Number],
        headers:Array,
        items:Array,
        add_item: String,
        edit_item: String,
        change_item: Function,
        add_roles: Array,
        edit_roles: Array,
    }
}

</script>

