<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout wrap>

      <v-flex sm12 md12 lg6>
        <material-chart-card
          :data="clientDevicesCntByMonth.data"
          :options="clientDevicesCntByMonth.options"
          :responsive-options="clientDevicesCntByMonth.responsiveOptions"
          color="light-green"
          type="Bar"
        >
          <h4 class="title font-weight-light">{{ $t('Dashboard.cldev_per_month') }}</h4>
          <p class="category d-inline-flex font-weight-light">Last Campaign Performance</p>

          <template slot="actions">
            <v-icon class="mr-2" small>
              mdi-clock-outline
            </v-icon>
            <span class="caption grey--text font-weight-light">updated 10 minutes ago</span>
          </template>
        </material-chart-card>
      </v-flex>

      <v-flex sm12 md12 lg6>
        Здесь будет.. .Что... График траффика?

4 года думал - хз что тут нужно ещё)

добавь пользователей за месяц, за сегодня, пользователей онлайн (по аккаунтингу)

      </v-flex>

      <!-- <v-flex sm12 md12 lg6>
        <material-chart-card
          :data="clientDevicesRegsCntByMonth.data"
          :options="clientDevicesRegsCntByMonth.options"
          :responsive-options="clientDevicesRegsCntByMonth.responsiveOptions"
          color="blue-grey"
          type="Bar"
        >
          <h4 class="title font-weight-light">{{ $t('Dashboard.cldev_regs_per_month') }}</h4>
          <p class="category d-inline-flex font-weight-light">Last Campaign Performance</p>

          <template slot="actions">
            <v-icon class="mr-2" small>
              mdi-clock-outline
            </v-icon>
            <span class="caption grey--text font-weight-light">updated 10 minutes ago</span>
          </template>
        </material-chart-card>
      </v-flex> -->



      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="light-green"
          icon="mdi-store"
          :title="$t('Dashboard.cldev_cnt')"
          :value="dashboard.client_devices"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="grey"
          icon="mdi-store"
          :title="$t('Dashboard.nas_cnt')"
          :value="dashboard.nases"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="blue-grey"
          icon="mdi-store"
          :title="$t('Dashboard.profile_cnt')"
          :value="dashboard.profiles"
          sub-icon="mdi-calendar"
          sub-text="In your admin's area"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="orange"
          icon="mdi-account-group"
          :title="$t('Dashboard.admin_cnt') + '/' + $t('Dashboard.manager_cnt')"
          :value="`${dashboard.admins}/${dashboard.managers}`"
          small-value="accs"
          sub-icon="mdi-account-group"
          sub-text="Account management"
        />
      </v-flex>

      
      <!-- <v-flex md12>
        <v-btn color="success" @click="test_notify">Tetst notify</v-btn>
      </v-flex> -->


    </v-layout>
  </v-container>
</template>

<script>

  import API from '@/lib/API'

  export default {

    data () {
      return {

        dashboard: {},

        // See https://github.com/Yopadd/vue-chartist
        clientDevicesCntByMonth: {

          data: {
            labels: [],
            series: [
              [],
              []
            ]
          },
       
          options: {
            axisX: {
              showGrid: false
            },
            low: 0,
            // high: 1000,
            chartPadding: {
              top: 0,
              right: 5,
              bottom: 0,
              left: 0
            },
            //height: '300px',
            seriesBarDistance: 10,
          },
        
          // responsiveOptions: [
          //   [
          //     // 'screen and (max-width: 640px)',
          //     {
          //       seriesBarDistance: 9,
          //       axisX: {
          //         labelInterpolationFnc: function (value) {
          //           return value[0]
          //         }
          //       }
          //     }
          //   ]
          // ],

        }, // clientDevicesCntByMonth {}


        // clientDevicesRegsCntByMonth: {

        //   data: {
        //     labels: [],
        //     series: [
        //       []
        //     ]
        //   },
       
        //   options: {
        //     axisX: {
        //       showGrid: false
        //     },
        //     low: 0,
        //     // high: 1000,
        //     chartPadding: {
        //       top: 0,
        //       right: 5,
        //       bottom: 0,
        //       left: 0
        //     }
        //   },
        
        //   responsiveOptions: [
        //     [
        //       // 'screen and (max-width: 640px)',
        //       {
        //         seriesBarDistance: 5,
        //         axisX: {
        //           labelInterpolationFnc: function (value) {
        //             return value[0]
        //           }
        //         }
        //       }
        //     ]
        //   ]

        // }, // clientDevicesCntByMonth {}

      }
    },

    mounted () {
      this.load();
    },

    methods: {
     
      load() {

        // Maybe on API change to function for GRANT RULE issues:
        API.Dashboard().then(
          res => {
            console.log(res);
            res.data[0].client_devices = res.data[0].client_devices.toString();
            res.data[0].nases = res.data[0].nases.toString();
            res.data[0].profiles = res.data[0].profiles.toString();
            this.dashboard = res.data[0];
          },
          err => this.$store.commit("error", err)
        );

        API.getStatClDevByMonth().then(
          res => {

            // console.log(res);
            var min = null;
            res.data.forEach((item, i) => {
              this.clientDevicesCntByMonth.data.labels.unshift( this.$moment(item.month).format("MMM") );
              this.clientDevicesCntByMonth.data.series[0].unshift(item.cnt);
              
              // Чтобы график начинался не с ноля и не занимал много места:
              if ( min == null || min > item.cnt ) {
                min = item.cnt;
              };
            })
            this.clientDevicesCntByMonth.options.low = min;

          },
          err => this.$store.commit("error", err)
        );
        
        API.getStatClDevRegsByMonth().then(
          res => {
            // console.log(res);
            res.data.forEach((item, i) => {

              // this.clientDevicesRegsCntByMonth.data.labels.unshift( this.$moment(item.month).format("MMM") );
              // this.clientDevicesRegsCntByMonth.data.series[0].unshift(item.cnt);
              this.clientDevicesCntByMonth.data.series[1].unshift(item.cnt);

              // Чтобы график начинался не с ноля и не занимал много места:
              if ( this.clientDevicesCntByMonth.options.low > item.cnt ) {
                this.clientDevicesCntByMonth.options.low = item.cnt;
              };

            })
          },
          err => this.$store.commit("error", err)
        );

      },

      test_notify() {
        this.$store.commit("addNotify", "Test Notify");
      },

    },
 
  }

</script>

<style>

  .ct-series-b .ct-bar {
    /* Colour of your bars */
    stroke: #FFC107; /* amber */
  }

</style>
