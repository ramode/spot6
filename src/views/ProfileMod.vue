<template>
  <v-container
    fill-height
    fluid
    grid-list-xl
  >
    <v-form
      ref="form"
      v-model="valid"
    >
      <v-container py-0>
        <v-layout wrap>
          <v-flex
            xs12
            lg6
          >
            <material-card
              color="blue-grey"
              :title="form.label? $t('Profile.edit_profile')+': '+ form.label: $t('Profile.add_profile')"
              :text="$t('Profile.edit_profile_small')"
              :loading="loading"
            >
              <v-container py-0>
                <v-layout wrap>
                  <v-flex
                    xs12
                    md6
                  >
                    <v-text-field
                      v-model="form.label"
                      :label="$t('DB.label')"
                      required
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md6
                  >
                    <v-text-field
                      v-model="form.profile"
                      :label="$t('DB.profile')"
                      :rules="nameRules"
                      required
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <span class="subheading">{{ $t('Profile.authorization') }}:</span>
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <v-select
                      v-model="form.auth_types"
                      :label="$t('DB.auth_types')"
                      :items="auth_types"
                      item-text="label"
                      item-value="id"
                      multiple
                      chips
                      required
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <v-checkbox
                      v-model="form.mac_auth"
                      :label="$t('DB.mac_auth')"
                      required
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <span class="subheading">{{ $t('Profile.limits') }}:</span>
                  </v-flex>

                  <v-flex
                    xs9
                    md4
                  >
                    <v-text-field
                      v-model="form.limit_speed"
                      :label="$t('DB.limit_speed')"
                      type="number"
                    />
                  </v-flex>
                  <v-flex
                    xs2
                    md1
                  >
                    <v-select
                      v-model="speed_unit"
                      :label="$t('Profile.speed_unit')"
                      :items="speed_units"
                      item-text="name"
                      item-value="id"
                      style="margin-left:-24px"
                    />
                  </v-flex>

                  <v-flex
                    xs9
                    md4
                    offset-md2
                  >
                    <v-text-field
                      v-model="form.limit_bytes"
                      :label="$t('DB.limit_bytes')"
                      type="number"
                    />
                  </v-flex>

                  <v-flex
                    xs2
                    md1
                  >
                    <v-select
                      v-model="traffic_unit"
                      :label="$t('Profile.traffic_unit')"
                      :items="traffic_units"
                      item-text="name"
                      item-value="id"
                      style="margin-left:-24px"
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md4
                  >
                    <v-text-field
                      v-model="form.limit_ports"
                      :label="$t('DB.limit_ports')"
                      required
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md5
                    offset-md3
                  >
                    <v-text-field
                      v-model="form.limit_time"
                      :label="$t('DB.limit_time')"
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <span class="subheading">{{ $t('Profile.http_redirects') }}:</span>
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <v-text-field
                      v-model="form.redirect_url"
                      :label="$t('DB.redirect_url')"
                    />
                  </v-flex>

                  <v-flex
                    xs12
                    md12
                  >
                    <v-text-field
                      v-model="form.ad_url"
                      :label="$t('DB.ad_url')"
                    />
                  </v-flex>

                <!--v-flex xs12 text-xs-right>
                  <v-btn class="" color="primary" @click="submit">{{ $t('Form.save') }}</v-btn>
                </v-flex-->
                </v-layout>
              </v-container>
            </material-card>
          </v-flex>
          <v-flex
            xs12
            lg6
          >
            <material-card
              color="blue-grey"
              :title="$t('Profile.template_params')+': '+ (form.label||'')"
              :loading="loading"
            >
              <v-container py-0>
                <v-layout column>
                  <v-flex
                    xs12
                    md6
                  >
                    <!-- <v-text-field label="Skin Folder Name"  v-model="form.skin" :rules="skinRules" required /> -->
                    <v-select
                      v-model="form.theme"
                      :label="$t('DB.theme')"
                      :items="themes"
                      item-text="label"
                      item-value="name"
                      required
                      @input="renewThemeVars"
                    />
                  </v-flex>

                  <v-flex
                    v-for="v in theme_var_list"
                    xs12
                    md12
                  >
                    <v-textarea
                      v-if="v.type=='html'"
                      v-model="form.template[v.name]"
                      auto-grow
                      clearable
                      :label="v.label"
                      required
                      type="html"
                    />
                    <v-textarea
                      v-if="v.type=='textarea'"
                      v-model="form.template[v.name]"
                      auto-grow
                      clearable
                      :label="v.label"
                      required
                    />
                    <v-text-field
                      v-if="v.type=='text'"
                      v-model="form.template[v.name]"
                      :label="v.label"
                      required
                    />
                  </v-flex>
                <!--v-flex xs12 text-xs-right>
                  <v-btn class="" color="primary" @click="submit">{{ $t('Form.save') }}</v-btn>
                </v-flex-->
                </v-layout>
              </v-container>
            </material-card>
          </v-flex>

          <v-flex
            xs12
            lg6
          >
            <material-card
              color="blue-grey"
              :title="$t('Profile.preview')+': '+ (form.label||'')"
              :text="$t('Profile.preview_small')"
              :loading="loading"
              v-if="form.id"
            >

            <template slot="topactions">

                <v-btn icon @click="reload+=1">
                    <v-icon v-text="'mdi-refresh'"/>
                </v-btn>
            </template>

              <div>
                <iframe
                  :key="reload"
                  frameborder="0"
                  :src="'/uam/register/?mac=02:00:00:00:00:01&linklogin=%2Fuam%2Ffakelogin&linkorig=http%3A%2F%2Fya.ru&called='+form.profile"
                  height="640"
                  width="100%"
                />
              </div>
            </material-card>
          </v-flex>
        </v-layout>
      </v-container>

      <v-fab-transition>
        <v-btn
          dark
          fab
          fixed
          bottom
          right
          color="primary"
          :title="$t('Form.save')"
          @click="submit"
        >
          <v-icon>mdi-content-save</v-icon>
        </v-btn>
      </v-fab-transition>
    </v-form>
  </v-container>
</template>

<script>

import API from '@/lib/API'

export default {

  data () {
    return {
      loading: true,
      reload: 0,

      form: {},
      v_edit: false,
      valid: false,
      themes: [],
      theme_var_list: [],
      auth_types: [],

      traffic_units: [
        { id: 1, name: 'GB', ratio: 1073741824 },
        { id: 2, name: 'MB', ratio: 1048576 }
      ],
      traffic_unit: 1,

      speed_units: [
        { id: 1, name: 'Mbit/s', ratio: 1048576 },
        { id: 2, name: 'kbit/s', ratio: 1024 }
      ],
      speed_unit: 1,

      nameRules: [
        v => !!v || 'Required'
      ],
      skinRules: [
        v => !!v || 'Required'
      ],
      minutesRules: [
        v => !!v || 'Required'
      ],
      limitRules: [
        v => !!v || 'Required'
      ],
      speedRules: [
        v => !!v || 'Required'
      ]

    }
  },

  mounted () {
    this.load()
  },

  methods: {

    convert_to_bits_bytes (data) {
      var
        traffic_unit_ratio = this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio
      var speed_unit_rario = this.speed_units.filter(obj => obj.id == this.speed_unit)[0].ratio

      // console.log(traffic_unit_ratio);
      // console.log(speed_unit_rario);

      data.limit_bytes = data.limit_bytes * traffic_unit_ratio
      data.limit_speed = data.limit_speed * speed_unit_rario

      return data
    },

    convert_from_bits_bytes (data) {
      if (data.limit_bytes == null) {
      } else
      // Если меньше 1 Gb:
      if (data.limit_bytes < this.traffic_units.filter(obj => obj.id == 1)[0].ratio) {
        this.traffic_unit = 2
        // Если больше 1 Gb:
      } else {
        this.traffic_unit = 1
      }
      var traffic_unit_ratio = this.traffic_units.filter(obj => obj.id == this.traffic_unit)[0].ratio

      if (data.limit_bytes != null) {
        data.limit_bytes /= traffic_unit_ratio
      }

      if (data.limit_speed == null) {} else
      // Если меньше 1 Mbit/sec:
      if (data.limit_speed < this.speed_units.filter(obj => obj.id == 1)[0].ratio) {
        this.speed_unit = 2
      } else {
        this.speed_unit = 1
      }
      var speed_unit_ratio = this.speed_units.filter(obj => obj.id == this.speed_unit)[0].ratio
      if (data.limit_speed != null) {
        data.limit_speed /= speed_unit_ratio
      }
      return data
    },

    load () {
      this.loading = 0
      API.getAuthTypes().then(
        res => {
          // console.log(res);
          this.loading += 30
          res.data.forEach((item, i) => {
            this.auth_types.push(item)
          })
        },
        err => {
          // console.log(err);
          // this.$store.commit("addNotify", `${err.response.status}: ${err.response.data.message}`);
          this.$store.commit('error', err)
        }
      )

      API.getThemes().then(
        res => {
          this.themes = res.data
          this.loading += 30

          if (this.form.theme) {
            this.renewThemeVars(this.form.theme)
          };
        },
        err => this.$store.commit('error', err)
      )

      // For EDIT action:
      if (this.$route.params.id) {
        this.v_edit = true
      };

      if (this.v_edit) {
        API.getProfile(this.$route.params.id).then(
          res => {
            this.loading += 40
            this.form = this.convert_from_bits_bytes(res.data[0])
            if (this.themes) {
              this.renewThemeVars(this.form.theme)
            }
          },
          err => this.$store.commit('error', err)
        )
      } else {
        this.loading += 40
        this.form.template = {}
      };
    },
    renewThemeVars (theme) {
      this.themes.forEach((item, i) => {
        if (item.name == theme) {
          this.theme_var_list = item.variables
        };
      })
    },

    set_nulls (data) {
      if (data.limit_bytes <= 0) {
        data.limit_bytes = null
      }

      if (data.limit_speed <= 0) {
        data.limit_speed = null
      }

      if (data.limit_ports <= 0) {
        data.limit_ports = null
      }

      for (var key in data) {
        console.log(key)
        console.log(data[key])
        if (data[key] === '') {
          data[key] = null
        }
      }

      return data
    },

    submit () {
      // Костыль, чтобы склонирвоать переменную, чтобы в полях формы не отрисовывались большие числа байтов:
      var data = Object.assign({}, this.form)

      data = this.convert_to_bits_bytes(data)
      data = this.set_nulls(data)

      var ApiMethod
      // If "add":
      if (!this.v_edit) {
        ApiMethod = API.addProfile
        // if "edit"
      } else {
        ApiMethod = API.updateProfile
      }

      if (this.$refs.form.validate()) {
        this.loading = true
        ApiMethod(data).then(
          res => {
            this.loading += 40
            this.form = this.convert_from_bits_bytes(res.data[0])
            if (this.themes) {
              this.renewThemeVars(this.form.theme)
            }
            if (res.data[0].id) this.v_edit = true
            this.loading = 100
            this.reload += 1
            // this.$router.push({name: "profiles"})
          },
          err => this.$store.commit('error', err)
        )
      }
    }

  }

}
</script>
