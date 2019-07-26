<template>
  <v-navigation-drawer
    id="app-drawer"
    v-model="inputValue"
    app
    dark

    width=300
    clipped
  >

      <v-list
        nav
        
      class="py-0"
      >

        <v-list-item v-if="responsive">
          <v-text-field class="purple-input search-input" label="Search..." color="primary" />
        </v-list-item>
        
        <v-list-item 
          v-for="(link, i) in links"
          :key="i" :to="link.to" :active-class="color"
          v-if="link.roles.includes($auth.user().role)">
          
          <v-list-item-icon>
            <v-icon>{{ link.icon }}</v-icon>
          </v-list-item-icon>
          <v-list-item-content>
              <v-list-item-title v-text="link.text" />
          </v-list-item-content>

        </v-list-item>
        
      </v-list>


    <!--/v-img-->
  </v-navigation-drawer>
</template>

<script>

// Utilities
import { mapMutations, mapState } from 'vuex'

export default {
  data: () => ({
    logo: '/img/ramode_logo.gif',
    responsive: false,
    color: "primary white--text",
  }),
  computed: {
    // ...mapState('app', ['image', 'color']),
    inputValue: {
      get () {
        return this.$store.state.app.drawer
      },
      set (val) {
        this.setDrawer(val)
      }
    },
    items () {
      return this.$t('Layout.View.items')
    },
    sidebarOverlayGradiant () {
      return `${this.$store.state.app.sidebarBackgroundColor}, ${this.$store.state.app.sidebarBackgroundColor}`
    },

    links: function() {
      return [
      {
        // to: '/dashboard',
        to: { name: "dashboard" },
        icon: 'mdi-view-dashboard',
        text: this.$t('Menu.dashboard'),
        roles: ["super", "admin", "manager"],
      },
      {
        // to: '/users',
        to: { name: "users" },
        icon: 'mdi-account',
        text: this.$t('Menu.users'),
        roles: ["super", "admin"],
      },
      {
        // to: '/profiles',
        to: { name: "profiles" },
        icon: 'mdi-tune',
        text: this.$t('Menu.profiles'),
        roles: ["super", "admin", "manager"],
      },
      {
        to: { name: "auth_types" },
        icon: 'mdi-phone-plus',
        text: this.$t('Menu.auth_types'),
        roles: ["super", "admin"],
      },
      {
        to: { name: "nases" },
        icon: 'mdi-access-point-network',
        text: this.$t('Menu.nases'),
        roles: ["super", "admin", "manager"],
      },
      {
        to: { name: "client_devices" },
        icon: "mdi-cellphone",
        text: this.$t('Menu.client_devices'),
        roles: ["super", "admin", "manager"],
      },
      {
        to: { name: "accounting" },
        // icon: "mdi-coin",
        icon: "mdi-counter",
        text: this.$t('Menu.accounting'),
        roles: ["super", "admin", "manager"],
      },
      {
        to: { name: "settings" },
        icon: 'mdi-settings',
        text: this.$t('Menu.settings'),
        roles: ["super","admin"],
      },

    ]},

  },
  mounted () {
    this.onResponsiveInverted()
    window.addEventListener('resize', this.onResponsiveInverted)
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.onResponsiveInverted)
  },
  methods: {
    ...mapMutations('app', ['setDrawer', 'toggleDrawer']),
    onResponsiveInverted () {
      if (window.innerWidth < 991) {
        this.responsive = true
      } else {
        this.responsive = false
      }
    }
  }
}
</script>

<style lang="scss">

</style>
