<template>
  <material-card
    v-bind="$attrs"
    class="v-card--material-stats"
    v-on="$listeners"
    :color="color"
  >
    <v-card-title
      slot="offset"
      :color="color"
      class=""
      dark
    >

      <v-icon
        :color="color"
        size="40"
      >
        {{ icon }}
      </v-icon>

<v-spacer></v-spacer>
        

      <span
        :class=" color+'--text text--darken-3 title font-weight-light'"
        v-text="title"
      />

    </v-card-title>
    <div class="text-xs-right">

      <span
        class="display-1  font-weight-light">
        {{ value }} <small>{{ smallValue }}</small>
      </span>
    </div>

    <template slot="actions">
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
.v-card--material-stats {
  display: flex;
  flex-wrap: wrap;
  position: relative;

  .v-offset {
    display: inline-block;
    flex: 0 1;
    margin-top: 0;
    margin-left: 0;
    margin-right: auto;
    margin-bottom: 0 !important;
    max-width: auto;
    padding: 0 16px 0;
  }

  .v-card {
    flex: 0 1 auto;
  }

    .v-card__title {
        padding-bottom:0;
        padding-top:24px;
        
    }

  .v-card__t-ext {
    display: inline-block;
    position: absolute;
    top: 0;
    right: 0;
    width: 100%;
  }

  .v-card__actions {
    flex: 1 0 100%;
  }
}
</style>
