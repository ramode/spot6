<template>
  <material-card
    v-bind="$attrs"
    v-on="$listeners"
    :loading=loading
  >
    <chartist
      :data="data"
      :event-handlers="eventHandlers"
      :options="options"
      :ratio="ratio"
      :responsive-options="responsiveOptions"
      :type="type"
      v-if="data.labels.length>0"
    />

    <v-card-text v-if="loading" class="display-1  font-weight-light " >
        <v-icon>
         mdi-chart-line
        </v-icon>
        {{$t('Common.Loading')}}
    </v-card-text>

    <v-card-text v-else-if="data.labels.length==0" class="display-1  font-weight-light " >
<v-icon>
 mdi-chart-line
</v-icon>
{{$t('Common.NoData')}}
    </v-card-text>

    <slot />

    <slot
      slot="actions"
      name="actions"
    />
  </material-card>
</template>

<script>
export default {
  inheritAttrs: false,

  props: {
    loading: [Boolean, Number],
    nodata: {
       type: Boolean,
       default: true
    },
    data: {
      type: Object,
      default: () => ({})
    },
    eventHandlers: {
      type: Array,
      default: () => ([])
    },
    options: {
      type: Object,
      default: () => ({})
    },
    ratio: {
      type: String,
      default: 'ct-minor-seventh'
    },
    responsiveOptions: {
      type: Array,
      default: () => ([])
    },
    type: {
      type: String,
      required: true,
      validator: v => ['Bar', 'Line', 'Pie'].includes(v)
    }
  }
}
</script>

<style lang="scss">

</style>
