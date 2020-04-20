<template>
  <q-page padding>
    <h4 style="margin: 0 0 1rem;">Zones and areas within Alberta</h4>
    <p class="text-body1">Compare zones and areas within Alberta.</p>
    <div class="row">
      <div class="col">
        <q-toolbar class="q-pl-none">
          <!-- Deaths
          <q-toggle class="q-mr-sm" v-model="total" @input="changeValue" label="Total" />
          <q-separator vertical />-->
          <q-toggle class="q-mr-sm" v-model="logscale" @input="changeValue" label="Log scale" />
          <q-separator vertical />
          <div class="q-ml-sm">
            Doubling Time
            <q-toggle v-model="rate" @input="changeValue" label="Daily % Rate" />
          </div>
        </q-toolbar>
      </div>
    </div>
    <!-- Plot for Canada -->
    <div class="row">
      <div class="col">
        <v-chart ref="chart" manual-update class="q-mt-sm" autoresize :options="lineCanada" />
      </div>
    </div>
  </q-page>
</template>

<style>
.echarts {
  width: 100%;
  height: 65vh;
}
</style>

<script>
import ECharts from "vue-echarts";
import "echarts/lib/chart/bar";
import "echarts/lib/chart/line";
import "echarts/lib/component/tooltip";
import "echarts/lib/component/toolbox";
import "echarts/lib/component/dataZoom";
import "echarts/lib/component/legend";
import "echarts/lib/component/title";
var cloneDeep = require("lodash.clonedeep");

import dataCanada from "./data.canada.json";

const dataLineCanada = {
  legend: {},
  tooltip: {},
  dataset: {
    dimensions: [],
    source: []
  },
  xAxis: [
    {
      data: []
    },
    {
      data: [],
      gridIndex: 1
    }
  ],
  yAxis: [
    { type: "log", minorTick: { show: true } },
    { type: "log", minorTick: { show: true }, gridIndex: 1 }
  ],
  grid: [
    {
      bottom: "55%",
      left: "5%",
      right: "6%"
    },
    {
      top: "55%",
      left: "5%",
      right: "6%"
    }
  ],
  series: [],
  dataZoom: [
    {
      show: true,
      realtime: true,
      start: 0,
      end: 100,
      xAxisIndex: [0, 1]
    },
    {
      type: "inside",
      realtime: true,
      start: 0,
      end: 100,
      xAxisIndex: [0, 1]
    }
  ],
  toolbox: {
    show: true,
    itemSize: 30,
    orient: "vertical",
    showTitle: false,
    feature: {
      dataZoom: { title: { zoom: "Zoom", back: "Undo" } },
      magicType: {
        type: ["line", "bar"],
        title: { line: "Line", bar: "Bar" }
      },
      restore: { title: "Reset" },
      saveAsImage: { title: "Save" }
    },
    tooltip: {
      // same as option.tooltip
      show: true,
      position: "left"
    }
  }
};

export default {
  name: "PageIndex",
  components: {
    "v-chart": ECharts
  },
  data() {
    return {
      lineCanada: null,
      logscale: true,
      //   total: true,
      dataResponse: null,
      options: null,
      totalData: { norm: [], log: [] },
      deathData: { norm: [], log: [] },
      rateData: { norm: [], log: [] },
      doubleData: { norm: [], log: [] },
      rate: true
    };
  },
  methods: {
    replaceSeries(g1, g0) {
      g0.forEach(item => {
        if (item.name !== "Date")
          this.lineCanada.series.filter(
            i => i.id == "grid0-" + item.name
          )[0].data = cloneDeep(item.data);
      });
      g1.forEach(item => {
        if (item.name !== "Date")
          this.lineCanada.series.filter(
            i => i.id == "grid1-" + item.name
          )[0].data = cloneDeep(item.data);
      });
    },
    changeValue() {
      if (this.logscale) {
        if (this.rate) {
          this.replaceSeries(this.rateData.log, this.totalData.log);
        } else {
          this.replaceSeries(this.doubleData.log, this.totalData.log);
        }
      } else {
        if (this.rate) {
          this.replaceSeries(this.rateData.norm, this.totalData.norm);
        } else {
          this.replaceSeries(this.doubleData.norm, this.totalData.norm);
        }
      }
      if (this.logscale) {
        this.lineCanada.yAxis[0].type = "log";
        this.lineCanada.yAxis[1].type = "log";
        this.lineCanada.toolbox.feature.magicType.type = this.lineCanada.toolbox.feature.magicType.type.filter(
          item => item !== "stack"
        );
      } else {
        this.lineCanada.yAxis[0].type = "value";
        this.lineCanada.yAxis[1].type = "value";
        this.lineCanada.toolbox.feature.magicType.type.push("stack");
      }
      this.$refs.chart.mergeOptions(cloneDeep(this.lineCanada), true);
    },
    changeRateToggle(val) {},
    loadData() {
      this.$axios
        .get(
          "https://hub.analythium.io/covid-19/api/v1/data/alberta/index.json"
        )
        .then(response => {
          this.dataResponse = response.data;
          var total = this.dataResponse["numtotal"];
          //   var deaths = this.dataResponse["numdeaths"];
          var rate = this.dataResponse["rate"];
          var double = this.dataResponse["double"];
          this.options = Object.keys(total);
          var config = cloneDeep(dataLineCanada);
          config.xAxis[0].data = total["Date"];
          config.xAxis[1].data = rate["Date"];
          for (let [key, value] of Object.entries(total)) {
            if (key !== "Date") {
              config.series.push({
                id: "grid0-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
              this.totalData.norm.push({
                name: key,
                data: value
              });
              this.totalData.log.push({
                name: key,
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          //   for (let [key, value] of Object.entries(deaths)) {
          //     if (key !== "Date") {
          //       this.deathData.norm.push({
          //         name: key,
          //         data: value
          //       });
          //       this.deathData.log.push({
          //         name: key,
          //         data: value.map(item =>
          //           isNaN(item) || item <= 0 ? 1 : item + 1
          //         )
          //       });
          //     }
          //   }
          for (let [key, value] of Object.entries(rate)) {
            if (key !== "Date") {
              config.series.push({
                id: "grid1-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                ),
                xAxisIndex: 1,
                yAxisIndex: 1
              });
              this.rateData.norm.push({
                name: key,
                data: value
              });
              this.rateData.log.push({
                name: key,
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          for (let [key, value] of Object.entries(double)) {
            if (key !== "Date") {
              this.doubleData.norm.push({
                name: key,
                data: value
              });
              this.doubleData.log.push({
                name: key,
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          this.lineCanada = config;
          this.$refs.chart.mergeOptions(cloneDeep(config), true);
        })
        .catch(() => {
          this.$q.notify({
            color: "negative",
            position: "bottom",
            message: "Loading failed",
            icon: "report_problem",
            timeout: 0,
            actions: [{ icon: "close", color: "white" }]
          });
        });
    }
  },
  mounted() {
    this.loadData();
  }
};
</script>
