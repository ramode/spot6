<template>
  <v-app-bar
    elevate-on-scroll
    color="blue-grey lighten-5 grey--text text--darken-1 font-weight-light"
  >
    <v-app-bar-nav-icon >
      <v-btn
        icon
        @click.stop="onClickBtn"
      >
        <v-icon>mdi-view-list</v-icon>
      </v-btn>
    </v-app-bar-nav-icon>

    <v-toolbar-title>
      <v-avatar color="white" v-if="logo">
        <v-img
          :src="logo"
          contain
        />
      </v-avatar>

      <span class="title">
        {{ $t('Common.title') }} 
      </span>

      <span >
        {{ title }} 
      </span>

    </v-toolbar-title>

    <v-spacer />

    <v-menu
      transition="slide-y-transition"
      bottom
      offset-y
      left
    >
      <template v-slot:activator="{ on }">
        <v-btn
          icon
          v-on="on"
        >
          <v-icon>mdi-flag</v-icon>
        </v-btn>
      </template>

      <v-list>
        <!-- <v-list-item v-for="(item, i) in langs" :key="i" @click="$i18n.locale = item.lang"> -->
        <v-list-item
          v-for="(item, i) in langs"
          :key="i"
          @click="changeLocale(item.lang)"
        >
          <v-list-item-title>{{ item.title }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>

    <v-menu
      bottom
      left
      offset-y
      transition="slide-y-transition"
    >
      <template v-slot:activator="{ on }">
        <v-btn
          icon
          v-on="on"
        >
          <v-badge
            color="error"
            overlap
          >
            <template
              v-if="notifications.length > 0"
              slot="badge"
            >
              {{ notifications.length }}
            </template>
            <v-icon >
              mdi-bell
            </v-icon>
          </v-badge>
        </v-btn>
      </template>

      <v-list dense>
        <v-list-item>
          <v-list-item-title @click="clear_notifys">
            <small><i>{{ $t('Common.clear') }}</i></small>
          </v-list-item-title>
        </v-list-item>
        <!-- <v-list-item v-for="notification in notifications" :key="notification" @click="onClick"> -->
        <v-list-item v-for="notification in notifications">
          <v-list-item-title v-text="notification" />
        </v-list-item>
      </v-list>
    </v-menu>




    <v-menu
      bottom
      left
      content-class="dropdown-menu"
      offset-y
      transition="slide-y-transition"
      allow-overflow
      v-if="['super','admin'].includes($auth.user().role)"
    >
      <template v-slot:activator="{ on }">
        <v-btn
          icon
          v-on="on"
            :title="group.label"
        >
            <v-icon >
              mdi-account-multiple
            </v-icon>
        </v-btn>

            

      </template>
      <v-list>
        <v-list-item v-for="g in groups"  @click="relogin(g.id)">
          <v-list-item-icon  >
            <v-icon v-if="g.id == $auth.user().group_id">mdi-check</v-icon>
            <v-icon v-else-if="g.id == $auth.user().user_id">mdi-account</v-icon>
          </v-list-item-icon>
            
            <v-list-item-content>
                <v-list-item-title v-html="g.label"></v-list-item-title>
            </v-list-item-content>


</v-list-item>
      </v-list>
    </v-menu>


    <v-menu
      bottom
      left
      content-class="dropdown-menu"
      offset-y
      transition="slide-y-transition"
      allow-overflow
    >
      <template v-slot:activator="{ on }">
        <v-btn
          icon
          v-on="on"
            :title="$auth.user().profile.login"
        >
          <v-badge
            color="error"
            overlap
          >
            <!--
                <template slot="badge">
                {{ user_menu.length }}
              </template> -->
            <v-icon >
              mdi-account
            </v-icon>
          </v-badge>
        </v-btn>
      </template>
      <v-list>
        <v-list-item>{{ $auth.user().profile.full_name || $auth.user().profile.login }}</v-list-item>
        <v-list-item @click="LogOut">
          <v-list-item-title>Log Out</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
  </v-app-bar>
</template>

<script>
import API from '@/lib/API'

import {
  mapMutations
} from 'vuex'

export default {

  data: () => ({
    logo: false, //'/img/ramode_logo.gif',

    groups: [],
    group: 'group',

    responsive: false,
    responsiveInput: false,

    title: null,

    langs: [
      {
        lang: 'en',
        title: 'English'
      },
      {
        lang: 'ru',
        title: 'Русский'
      }
    ]

  }),

  computed: {
    notifications () {
      return this.$store.state.notifications
    }
  },

  watch: {
    '$route' (val) {
      this.title = this.$t('Menu.'+ val.name)
      document.title = this.$t('Common.title') + ' — ' + this.$t('Menu.'+ val.name)
    }
  },

  mounted () {
    this.onResponsiveInverted()
    window.addEventListener('resize', this.onResponsiveInverted)
    this.changeLocale(localStorage.getItem('lang') || 'ru')
    
    this.title = this.$t('Menu.'+ this.$route.name)
    document.title = this.$t('Common.title') + ' — ' + this.$t('Menu.'+ this.$route.name)
    this.load()

  },
  beforeDestroy () {
    window.removeEventListener('resize', this.onResponsiveInverted)
  },

  methods: {
    ...mapMutations('app', ['setDrawer', 'toggleDrawer']),


    load() {
        API.getGroups().then( (r) => {
            this.groups = r.data
            this.group = this.groups.filter( o => o.id == this.$auth.user().group_id )[0]
        } )
    },

    relogin(id) {

        this.$auth.refresh({
            data: {group_id:id},
            success: function () {
                //this.$auth.fetch() //не нужно тк go рефрешит всю страницу
                this.$router.go()
                //console.log(this.$router);
                //this.$router.replace({path: this.$router.currentRoute.path, params: this.$router.currentRoute.params})

            },
            error: function () {},
        });
    },

    onClickBtn () {
      this.setDrawer(!this.$store.state.app.drawer)
    },
    onClick () {
      //
    },
    onResponsiveInverted () {
      if (window.innerWidth < 1264) {
        this.responsive = true
        this.responsiveInput = false
      } else {
        this.responsive = false
        this.responsiveInput = true
      }
    },

    LogOut () {
      this.$auth.logout({
        redirect: '/login'
      })
    },

    clear_notifys () {
      this.$store.commit('clearNotifys')
    },

    changeLocale (lang) {
      // console.log(lang);
      this.$i18n.locale = lang
      this.$moment.locale(lang)
      this.$vuetify.lang.current = lang
      localStorage.setItem('lang', lang)
    }

  }
}
</script>

<style>

</style>
