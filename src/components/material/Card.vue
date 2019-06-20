<template>
  <v-card
    v-bind="$attrs"
    :style="styles"
    v-on="$listeners"
  >

    <v-progress-linear
        :indeterminate="loading===true"
        :value="(loading===true)? 0: loading"
        style="paddind:0;margin:-16px -16px -16px 0"
        :color="color"/>
    <v-card-title :color="color" v-if="!$slots.offset">

        <slot
          v-if="!title && !text"
          name="header"
        />
        <span v-else>
          <h3
            class=""
            v-text="title"
          />
          <p
            class="category font-weight-thin"
            v-text="text"
          />
        </span>
    </v-card-title>
      <slot
        v-else
        name="offset"
      />
 <v-divider v-if="!$slots.offset"/>

    <!--helper-offset
      v-if="hasOffset"
      :inline="inline"
      :full-width="fullWidth"
      :offset="offset"
    >
      <!--v-card
        v-if="!$slots.offset"
        :color="color"
        :class="`elevation-${elevation}`"
        class="v-card--material__header"
        dark
      >
        <!--slot
          v-if="!title && !text"
          name="header"
        />
        <span v-else>
          <h4
            class="title font-weight-light mb-2"
            v-text="title"
          />
          <p
            class="category font-weight-thin"
            v-text="text"
          />
        </span>
      </v-card>
      <slot
        v-else
        name="offset"
      /-->
    </helper-offset-->

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
  .v-card--material {
    &__header {
      &.v-card {
        border-radius: 4px;
      }
    }
  }
</style>
