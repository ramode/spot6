<template>
  <v-container fill-height fluid grid-list-xl>
    <v-layout wrap>

      <v-flex sm12 md12 lg6>
        <material-chart-card
          :data="clientDevicesCntByMonth.data"
          :options="clientDevicesCntByMonth.options"
          :responsive-options="clientDevicesCntByMonth.responsiveOptions"
          color="red"
          type="Bar"
        >
          <h4 class="title font-weight-light">{{ $t('Dashboard.cldev_per_month') }}</h4>
          <!-- <p class="category d-inline-flex font-weight-light">Last Campaign Performance</p> -->

          <!-- <template slot="actions">
            <v-icon class="mr-2" small>
              mdi-clock-outline
            </v-icon>
            <span class="caption grey--text font-weight-light">updated 10 minutes ago</span>
          </template> -->
        </material-chart-card>
      </v-flex>

      <v-flex sm12 md12 lg6>

        <material-chart-card
          :data="trafficInLastMonth.data"
          :options="trafficInLastMonth.options"
          :responsive-options="trafficInLastMonth.responsiveOptions"
          color="grey"
          type="Line"
        >
          <h4 class="title font-weight-light">{{ $t('Dashboard.month_trafic') }}, Gb</h4>
          <!-- <p class="category d-inline-flex font-weight-light">Last Campaign Performance</p> -->

          <!-- <template slot="actions">
            <v-icon class="mr-2" small>
              mdi-clock-outline
            </v-icon>
            <span class="caption grey--text font-weight-light">updated 10 minutes ago</span>
          </template> -->
        </material-chart-card>

      </v-flex>

      <v-flex sm12 md12 lg6>
        <material-chart-card
          :data="devVendorStat.data"
          :options="devVendorStat.options"
          :responsive-options="devVendorStat.responsiveOptions"
          color="light-green"
          type="Pie"
        >
          <h4 class="title font-weight-light">{{ $t('Dashboard.dev_vendors_title') }}</h4>
        </material-chart-card>
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="light-green"
          icon="mdi-cellphone"
          :title="$t('Dashboard.cldev_cnt')"
          :value="dashboard.client_devices"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="grey"
          icon="mdi-access-point-network"
          :title="$t('Dashboard.nas_cnt')"
          :value="dashboard.nases"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="blue-grey"
          icon="receipt"
          :title="$t('Dashboard.profile_cnt')"
          :value="dashboard.profiles"
        />
      </v-flex>

      <v-flex xs12 sm6 md6 lg3>
        <material-stats-card
          color="orange"
          icon="mdi-account"
          :title="$t('Dashboard.admin_cnt') + '/' + $t('Dashboard.manager_cnt')"
          :value="`${dashboard.admins}/${dashboard.managers}`"
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
              top: 30,
              right: 5,
              bottom: 0,
              left: 0
            },
            //height: '300px',
            seriesBarDistance: 10,
          },

          responsiveOptions: []
        
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


        trafficInLastMonth: {

          data: {
            labels: [],
            series: [
              [], []
            ]
            // series: [
            //   {
            //     name: "download",
            //     data: [] // {x: new Date(143134652600), y: 53},
            //   },
            //   {
            //     name: "upload",
            //     data: [] // {x: new Date(143134652600), y: 53},
            //   },
            // ]
          },
       
          options: {
            showArea: true,
            chartPadding: {
              top: 30,
            },
          },

        },


        devVendorStat: {

          data: {
            labels: [],
            series: []
          },
       
          options: {
            donutWidth: 60,
            donutSolid: true,
            donut: true,
            // labelInterpolationFnc: function(value) {
            //   return value[0]
            // },
          },

        },


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
            // console.log(res);
            res.data[0].client_devices = res.data[0].client_devices.toString();
            res.data[0].nases = res.data[0].nases.toString();
            res.data[0].profiles = res.data[0].profiles.toString();
            this.dashboard = res.data[0];
          },
          err => this.$store.commit("error", err)
        );

        API.getStatClDevByMonth().then(
          res => {

            var min = null;
            res.data.forEach((item, i) => {
              this.clientDevicesCntByMonth.data.labels.unshift( this.$moment(item.month).format("MMM") );
              this.clientDevicesCntByMonth.data.series[1].unshift(item.cnt);
              
              // Чтобы график начинался не с ноля и не занимал много места:
              if ( min == null || min > item.cnt ) {
                min = item.cnt;
              };
              // console.log(min);
            })
            // this.clientDevicesCntByMonth.options.low = min;


          },
          err => this.$store.commit("error", err)
        );
        
        API.getStatClDevRegsByMonth().then(
          res => {
            // console.log(res);
            res.data.forEach((item, i) => {

              // this.clientDevicesRegsCntByMonth.data.labels.unshift( this.$moment(item.month).format("MMM") );
              // this.clientDevicesRegsCntByMonth.data.series[0].unshift(item.cnt);
              this.clientDevicesCntByMonth.data.series[0].unshift(item.cnt);

              // Чтобы график начинался не с ноля и не занимал много места:
              if ( this.clientDevicesCntByMonth.options.low > item.cnt ) {
                this.clientDevicesCntByMonth.options.low = item.cnt;
              };

            })
          },
          err => this.$store.commit("error", err)
        );

        API.getStatMonthTrafic().then(
          res => {
            // console.log(res);
            res.data.forEach((item, i) => {
              // this.trafficInLastMonth.data.labels.unshift( this.$moment(item.day).format("D MMM") ); // "2019-06-16T00:00:00"
              // this.trafficInLastMonth.data.labels.unshift( this.$moment(item.day).format("D") );

              // Чтобы по-реже сделать подписи по оси X, а то перекрываются
              var x_value = this.$moment(item.day).format("D");
              if ( ["1", "10", "20"].includes(x_value) ) {
                x_value = this.$moment(item.day).format("D MMM");
              } else {
                x_value = null;
              };
              this.trafficInLastMonth.data.labels.push( x_value );

              // this.trafficInLastMonth.data.series[0].push( Math.floor(item.download/1073741824) );
              // this.trafficInLastMonth.data.series[1].push( Math.floor(item.upload/1073741824) );

              this.trafficInLastMonth.data.series[0].push( Math.floor(item.download/1048579) );
              this.trafficInLastMonth.data.series[1].push( Math.floor(item.upload/1048579) );

            })
          },
          err => this.$store.commit("error", err)
        );

        API.getStatDevVendor().then(
          res => {
            // console.log(res);
            var percent_modulus = 100;
            res.data.forEach((item, i) => {
              // this.devVendorStat.data.labels.push(`${item.company.split(' ')[0]}\n\r(${item.percent}%)`);
              this.devVendorStat.data.labels.push(`${item.company.split(' ')[0]}`);
              this.devVendorStat.data.series.push(item.percent);
              percent_modulus = percent_modulus - item.percent;
            });
            this.devVendorStat.data.labels.push(this.$t('Dashboard.dev_vendor_other'));
            this.devVendorStat.data.series.push(percent_modulus);
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

  .ct-label {

	color: #090909;
    fill:unset;

  }

  .ct-series-b .ct-bar {
    /* Colour of your bars */
    stroke: #FFC107; /* amber */
  }

  .ct-series-a .ct-point {
    /* Size of your points */
    stroke-width: 2px;
    /* Make your points appear as squares */
    stroke-linecap: square;
  }

  .ct-series-b .ct-point {
    /* Size of your points */
    stroke-width: 2px;
    /* Make your points appear as squares */
    stroke-linecap: square;
  }

</style>
