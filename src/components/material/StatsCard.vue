<template>
  <material-card
    v-bind="$attrs"
    class="v-card--material-stats"
    :color="color"
    v-on="$listeners"
    :title="title"
  >




<template slot="topactions" v-if="addItem" >

    <v-fab-transition v-if="addRoles && addRoles.includes($auth.user().role)">
      <v-tooltip
        top
        content-class="top"
      >
        <template v-slot:activator="{ on }">
          <v-btn
            icon
            :to="{ name: addItem }"
            v-on="on"
          >
            <v-icon>mdi-plus</v-icon>

          </v-btn>
        </template>
        <span>{{ $t('Common.add') }}</span>
      </v-tooltip>
    </v-fab-transition>

</template>


      <template
        v-for="(_, slot) of $scopedSlots"
        v-slot:[slot]="scope"
      >
        <slot
          :name="slot"
          v-bind="scope"
        />
      </template>


<v-card-text
        class="display-1  font-weight-light text-right"
      >

<v-icon v-text="icon" left :color="color" large/> 

        {{ value }} <small>{{ smallValue }}</small>


</v-card-text>
    <template slot="actions" v-if="subText">
      <v-icon
        :color="subIconColor"
        size="20"
        class="mr-2"
      >
        {{ subIcon }}
      </v-icon>
      <span
        :class="subTextColor"
        class="caption font-weight-light"
        v-text="subText"
      />
    </template>
  </material-card>
</template>

<script>
import Card from './Card'

export default {
  inheritAttrs: false,

  props: {
    ...Card.props,

    addItem: {
        type: String,
    },

    addRoles: {
        type: Array,
        default: () => ['super','admin','manager']
    },

    icon: {
      type: String,
      required: true
    },
    subIcon: {
      type: String,
      default: undefined
    },
    subIconColor: {
      type: String,
      default: undefined
    },
    subTextColor: {
      type: String,
      default: undefined
    },
    subText: {
      type: String,
      default: undefined
    },
    title: {
      type: String,
      default: undefined
    },
    value: {
      type: String,
      default: undefined
    },
    smallValue: {
      type: String,
      default: undefined
    }
  }
}
</script>

<style lang="scss">

</style>
