<template>
  <v-card
    v-bind="$attrs"
    :style="styles"
    v-on="$listeners"

    
  >

    <v-progress-linear
        :indeterminate="loading===true"
        :value="(loading===true)? 0: ((loading===false)?100:loading)"
        style="paddind:0;margin:0 -16px -16px 0"
        :color="color"/>

    <v-card-title :color="color" v-if="!$slots.offset">
        <slot
          v-if="!title && !text"
          name="header"
        />
        <span v-else >
        <v-tooltip right>
        <template v-slot:activator="{ on }">
          <h3 v-on="on"
            v-text="title"
          />
        </template>
          <span
            class="category font-weight-thin"
            v-text="text"
          />
        </v-tooltip>
        </span>

        <slot name="top-actions" />

    </v-card-title>

      <slot
        v-else
        name="offset"
      />
 <v-divider v-if="!$slots.offset"/>

    <v-card-text>
      <slot />
    </v-card-text>

    <v-divider
      v-if="$slots.actions"
      class="mx-3"
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
      type: [Number,Boolean] ,
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

</style>
