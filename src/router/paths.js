/**
 * Define all of your application routes here
 * for more information on routes, see the
 * official documentation https://router.vuejs.org/en/
 */
export default [

  {
    path: '/403',
    view: '403',
    name: '403',
  },
  {
    path: '/404',
    view: '404',
    name: '404',
  },

  {
    path: '/dashboard',
    view: 'Dashboard',
    name: 'dashboard',
    meta: {
      auth: true,
    },
  },

  {
    path: '/users',
    view: 'Users',
    name: 'users',
    meta: {
      auth: {
        roles: ['super','admin'],
      }
    },
  },
  {
    path: '/users/add',
    view: "UserMod",
    name: 'user_add',
    meta: {
      auth: {
        roles: ['super','admin'],
      }
    },
  },
  {
    path: '/users/:id',
    view: "UserMod",
    name: 'user_edit',
    meta: {
      auth: {
        roles: ['super','admin'],
      }
    },
  },

  {
    path: '/settings',
    view: 'Settings',
    name: 'settings',
    meta: {
      auth: {
        roles: ['super'],
      }
    },
  },

  {
    path: '/profiles',
    view: 'Profiles',
    name: 'profiles',
    meta: {
      auth: true,
    },
  },
  {
    path: '/profiles/add',
    view: 'ProfileMod',
    name: 'profile_add',
    meta: {
      auth: {
        roles: ['super', 'admin'],
      }
    },
  },
  {
    path: '/profiles/:id',
    view: 'ProfileMod',
    name: 'profile_edit',
    meta: {
      auth: {
        roles: ['super', 'admin', 'manager'],
      }
    },
  },

]
