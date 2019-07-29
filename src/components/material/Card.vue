<template>
  <v-card

    class="v-card--material-stats"
    v-bind="$attrs"
    :style="styles"
    v-on="$listeners"
  >
    <v-progress-linear
      :indeterminate="loading===true"
      :value="(loading===true)? 0: ((loading===false)?100:loading)"
      style="paddind:0;margin:0 -16px -16px 0"
      :color="color"
      
    />

<v-toolbar
 :color="color"
 dark 
 flat
 tile
 style="height: auto;paddind:0;margin-top:4px"

 v-if="title || $slots.topActions "
>    

    <v-app-bar-nav-icon v-if="icon">
      <v-icon>
        {{ icon }}
      </v-icon>
    </v-app-bar-nav-icon>

    <v-toolbar-title>
        <v-tooltip right>
          <template v-slot:activator="{ on }">
            <span
              v-on="on"
              v-text="title"
            />
          </template>
          <span
            class="category font-weight-thin"
            v-text="text"
          />
        </v-tooltip>
    </v-toolbar-title>
    <v-spacer></v-spacer>



    <slot name="topactions"/>


</v-toolbar>


    <v-card-text>
      <slot />
    </v-card-text>

    <v-divider
      v-if="$slots.actions"
    />

    <v-card-actions v-if="$slots.actions">
      <slot name="actions" />
    </v-card-actions>
  </v-card>
</template>

<script>
export default {
  inheritAttrs: false,

  props: {
    icon : {
      type: String,
    },
    color: {
      type: String,
      default: 'secondary'
    },
    elevation: {
      type: [Number, String],
      default: 10
    },
    inline: {
      type: Boolean,
      default: false
    },
    fullWidth: {
      type: Boolean,
      default: false
    },
    offset: {
      type: [Number, String],
      default: 0
    },
    title: {
      type: String,
      default: undefined
    },
    text: {
      type: String,
      default: undefined
    },
    loading: {
      type: [Number, Boolean],
      default: 100
    }
  },

  computed: {
    hasOffset () {
      return this.$slots.header ||
        this.$slots.offset ||
        this.title ||
        this.text
    },
    styles () {
      if (!this.hasOffset) return null

      return {
        marginBottom: `${this.offset}px`,
        marginTop: `${this.offset * 2}px`
      }
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

  .v-card__actions {
    flex: 1 0 100%;
  }
}
</style>

