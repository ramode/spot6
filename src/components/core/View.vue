<template>
  <v-content column>
    <core-toolbar v-on:coa="coa++" />
    <v-fade-transition mode="out-in">
        <router-view :key="coa"></router-view>
    </v-fade-transition>
    <core-footer v-if="$route.name !== 'Maps'" />
  </v-content>
</template>

<script>
export default {
    data: () => ({ coa:0 })
}
</script>

<style>

</style>
