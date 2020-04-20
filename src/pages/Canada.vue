<template>
  <q-page padding>
    <h4 style="margin: 0 0 1rem;">Canadian provinces and territories</h4>
    <p class="text-body1">Compare provinces and territories within Canada.</p>
    <div class="row">
      <div class="col">
        <q-toolbar>
          Deaths
          <q-toggle class="q-mr-sm" v-model="total" @input="changeValue" label="Total" />
          <q-separator vertical />
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
        <v-chart class="q-mt-lg" autoresize :options="lineCanada" />
      </div>
    </div>
  </q-page>
</template>

<style>
.echarts {
  width: 100%;
  /* height: 100%; */
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
  grid: {
    left: "7%"
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
      bottom: "60%",
      left: "7%"
    },
    {
      top: "60%",
      left: "7%"
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
      total: true,
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
    changeValue() {
      var newSeries = null;
      if (this.total) {
        if (this.logscale) {
          if (this.rate) {
            newSeries = [...this.rateData.log, ...this.totalData.log];
          } else {
            newSeries = [...this.doubleData.log, ...this.totalData.log];
          }
        } else {
          if (this.rate) {
            newSeries = [...this.rateData.norm, ...this.totalData.norm];
          } else {
            newSeries = [...this.doubleData.norm, ...this.totalData.norm];
          }
        }
      } else {
        if (this.logscale) {
          if (this.rate) {
            newSeries = [...this.rateData.log, ...this.deathData.log];
          } else {
            newSeries = [...this.doubleData.log, ...this.deathData.log];
          }
        } else {
          if (this.rate) {
            newSeries = [...this.rateData.norm, ...this.deathData.norm];
          } else {
            newSeries = [...this.doubleData.norm, ...this.deathData.norm];
          }
        }
      }
      newSeries.forEach(i => console.log(i.id, i.data))
      if (this.logscale) {
        this.lineCanada.yAxis[0].type = "log";
        this.lineCanada.yAxis[1].type = "log";
      } else {
        this.lineCanada.yAxis[0].type = "value";
        this.lineCanada.yAxis[1].type = "value";
      }
      this.lineCanada.series = cloneDeep(newSeries);
    },
    changeRateToggle(val) {},
    loadData() {
      this.$axios
        .get("https://hub.analythium.io/covid-19/api/v1/data/canada/index.json")
        .then(response => {
          this.dataResponse = response.data;
          var total = this.dataResponse["numtotal"];
          var deaths = this.dataResponse["numdeaths"];
          var rate = this.dataResponse["rate"];
          var double = this.dataResponse["double"];
          this.options = Object.keys(total);
          var config = dataLineCanada;
          config.xAxis[0].data = total["Date"];
          config.xAxis[1].data = rate["Date"];
          for (let [key, value] of Object.entries(total)) {
            if (key !== "Date") {
              this.totalData.norm.push({
                id: "total-" + key,
                name: key,
                type: "line",
                data: value
              });
              this.totalData.log.push({
                id: "total-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          for (let [key, value] of Object.entries(deaths)) {
            if (key !== "Date") {
              this.deathData.norm.push({
                id: "deaths-" + key,
                name: key,
                type: "line",
                data: value
              });
              this.deathData.log.push({
                id: "deaths-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          for (let [key, value] of Object.entries(rate)) {
            if (key !== "Date") {
              this.rateData.norm.push({
                id: "rate-" + key,
                name: key,
                type: "line",
                data: value,
                xAxisIndex: 1,
                yAxisIndex: 1
              });
              this.rateData.log.push({
                id: "rate-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                ),
                xAxisIndex: 1,
                yAxisIndex: 1
              });
            }
          }
          for (let [key, value] of Object.entries(double)) {
            if (key !== "Date") {
              this.doubleData.norm.push({
                id: "double-" + key,
                name: key,
                type: "line",
                data: value,
                xAxisIndex: 1,
                yAxisIndex: 1
              });
              this.doubleData.log.push({
                id: "double-" + key,
                name: key,
                type: "line",
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                ),
                xAxisIndex: 1,
                yAxisIndex: 1
              });
            }
          }
          config.series.push(...this.totalData.log);
          config.series.push(...this.rateData.log);
          this.lineCanada = cloneDeep(config);
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
