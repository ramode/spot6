/**
 * Define all of your application routes here
 * for more information on routes, see the
 * official documentation https://router.vuejs.org/en/
 */
export default [

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
    path: '/nases',
    view: 'Nases',
    name: 'nases',
    meta: {
      auth: {
        roles: ['super'],
      }
    },
  },

  {
    path: '/nases/:id',
    view: 'NasMod',
    name: 'nas_edit',
    meta: {
      auth: {
        roles: ['super'],
      }
    },
  },

  {
    path: '/nases/add',
    view: 'NasMod',
    name: 'nas_add',
    meta: {
      auth: {
        roles: ['super'],
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

  {
    path: '/client_devices',
    view: 'ClientDevices',
    name: 'client_devices',
    meta: {
      auth: true,
    },
  },

  {
    path: '/accounting',
    view: 'Accounting',
    name: 'accounting',
    meta: {
      auth: true,
    },
  },

]
