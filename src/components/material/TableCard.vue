<template>
  <material-card
    :color="color"
    :title="title"
    :text="text"
    :loading="loading"
  >

    <v-fab-transition v-if="addRoles && addRoles.includes($auth.user().role)">
      <v-tooltip
        top
        content-class="top"
      >
        <template v-slot:activator="{ on }">
          <v-btn
     fab
        large
        dark
        bottom
        right
fixed
            color="primary"
            :to="{ name: addItem }"
            v-on="on"
          >
            <v-icon>mdi-plus</v-icon>

          </v-btn>
        </template>
        <span>{{ $t('Common.add') }}</span>
      </v-tooltip>
    </v-fab-transition>

    <v-data-table
      :headers="headers"
      :items="items"
      hide-default-footer
      disable-pagination
    >
      <template
        v-for="(_, slot) of $scopedSlots"
        v-slot:[slot]="scope"
      >
        <slot
          :name="slot"
          v-bind="scope"
        />
      </template>

      <template
        v-if="editRoles && editRoles.includes($auth.user().role)"
        slot="item.actions"
        slot-scope="{ item }"
      >
        <v-layout
          justify-end
          row
        >
          <v-tooltip
            top
            content-class="top"
          >
            <template v-slot:activator="{ on }">
              <v-btn
                small
                icon
                :to="{name: editItem, params: {id: item.id}}"
                v-on="on"
              >
                <v-icon color="primary">
                  mdi-pencil
                </v-icon>
              </v-btn>
            </template>
            <span>{{ $t('Form.edit') }}</span>
          </v-tooltip>

          <v-tooltip
            top
            content-class="top"
          >
            <template v-slot:activator="{ on }">
              <v-btn
                small
                icon
                v-on="on"
                @click="disableItem(item)"
              >
                <v-icon :color="item.disabled ? 'warning' : 'grey'">
                  mdi-block-helper
                </v-icon>
              </v-btn>
            </template>
            <span>{{ $t('Form.disable') }}</span>
          </v-tooltip>
        </v-layout>
      </template>
    </v-data-table>



  </material-card>

</template>

<script>

export default {

  props: {
    color: String,
    title: String,
    text: String,
    loading: [Boolean, Number],
    headers: Array,
    items: Array,
    addItem: String,
    editItem: String,
    disableItem: Function,
    addRoles: Array,
    editRoles: Array
  }
}

</script>
