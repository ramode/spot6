<template>
  <v-content>
    <core-toolbar />
      <v-fade-transition mode="out-in">
        <router-view />
      </v-fade-transition>
    <core-footer v-if="$route.name !== 'Maps'" />
  </v-content>
</template>

<script>
export default {

}
</script>

<style>

</style>
