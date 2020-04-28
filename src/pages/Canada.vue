<template>
  <q-page padding>
    <h4 style="margin: 0 0 1rem;">Canadian provinces and territories</h4>
    <p class="text-body1 q-mb-sm">Compare provinces and territories within Canada. Toggle view to the logarithmic scale and back for the top chart. The bottom chart shows percent daily change based on 3-day moving average of daily % change values calculated as 100 &times; (<em>R</em><sub>t</sub> &ndash; 1) where <em>R</em><sub>t</sub> is the rate of change (<em>R</em><sub>t</sub> = <em>N</em><sub>t</sub>/<em>N</em><sub>t&ndash;1</sub>). The doubling day show how long it takes the case numbers to double given the growth rate (log(2)/log(<em>R</em><sub>t</sub>)) also calculated as 3-day moving average.</p>
    <div class="row">
      <div class="col">
        <q-toolbar class="q-pl-none">
          Deaths
          <q-toggle
            class="q-mr-sm"
            v-model="total"
            @input="changeValue"
            label="Total"
          />
          <q-separator vertical />
          <q-toggle
            class="q-mr-sm"
            v-model="logscale"
            @input="changeValue"
            label="Log scale"
          />
          <q-separator vertical />
          <div class="q-ml-sm">
            Doubling Time Days
            <q-toggle
              v-model="rate"
              @input="changeValue"
              label="Daily % Change"
            />
          </div>
        </q-toolbar>
      </div>
    </div>
    <!-- Plot for Canada -->
    <div class="row">
      <div
        class="col"
        style="height: 89vh"
      >
        <v-chart
          ref="chart"
          manual-update
          class="q-mt-sm"
          autoresize
          :options="lineCanada"
        />
      </div>
    </div>
  </q-page>
</template>

<style>
.echarts {
  width: 100%;
  height: 100%;
}
</style>

<script>
import ECharts from "vue-echarts";
import ec_og from 'echarts/lib/echarts'
import "echarts/lib/chart/bar";
import "echarts/lib/chart/line";
import "echarts/lib/component/tooltip";
import "echarts/lib/component/toolbox";
import "echarts/lib/component/dataZoom";
import "echarts/lib/component/legend";
import "echarts/lib/component/title";
var cloneDeep = require("lodash.clonedeep");

const dataLineCanada = {
  legend: {},
  tooltip: {
    show: true,
    trigger: 'axis',
    textStyle: {
      fontSize: 10
    },
    axisPointer: {
      animation: false
    },
    formatter: function(params, axis){
      var a = params.sort((a, b) => a.componentIndex > b.componentIndex)
      var grid0 = params.filter(item => item.seriesId.includes('grid0'))
      var grid1 = params.filter(item => item.seriesId.includes('grid1'))
      var g0name = ec_og.getInstanceById(document.querySelector(".echarts").attributes.getNamedItem('_echarts_instance_').nodeValue).getOption().yAxis[0].name
      var g1name = ec_og.getInstanceById(document.querySelector(".echarts").attributes.getNamedItem('_echarts_instance_').nodeValue).getOption().yAxis[1].name
      return `${g0name} (${grid0[0].name})<br />
            ${grid0.map(item => `${item.marker} ${item.seriesName}: ${item.value}<br/>`).join('')}
            <br />
            ${g1name} (${grid1[0].name})<br />
            ${grid1.map(item => `${item.marker} ${item.seriesName}: ${item.value}<br/>`).join('')}
            `
    }
  },
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
      gridIndex: 1,
      name: "Date",
      nameGap: 30, nameLocation: "middle"
    }
  ],
  yAxis: [
    { type: "log", minorTick: { show: true }, name: "Total Cases (log)", nameGap: 39, nameLocation: "middle" },
    { type: "value", minorTick: { show: true }, name: "Daily % Change", nameGap: 28, nameLocation: "middle", gridIndex: 1 }
  ],
  axisPointer: {
    link: { xAxisIndex: 'all' }
  },
  grid: [
    {
      top: "18%",
      bottom: "40%",
      left: "6%",
      right: "12%"
    },
    {
      top: "67.5%",
      left: "6%",
      right: "12%"
    }
  ],
  series: [],
  dataZoom: [
    {
      show: true,
      realtime: true,
      start: 0,
      end: 100,
      top: "11%",
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
    top: "9%",
    right: "2.5%",
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
    }
  }
};

export default {
  name: "PageIndex",
  components: {
    "v-chart": ECharts
  },
  data () {
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
    replaceSeries (g1, g0) {
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
    changeValue () {
      if (this.total) {
        if (this.logscale) {
          if (this.rate) {
            this.replaceSeries(this.rateData.norm, this.totalData.log);
            this.lineCanada.yAxis[1].name = "Daily % Change"
            this.lineCanada.yAxis[0].name = "Total Cases (log)"
          } else {
            this.replaceSeries(this.doubleData.norm, this.totalData.log);
            this.lineCanada.yAxis[1].name = "Doubling Time Days"
            this.lineCanada.yAxis[0].name = "Total Cases (log)"
          }
        } else {
          if (this.rate) {
            this.replaceSeries(this.rateData.norm, this.totalData.norm);
            this.lineCanada.yAxis[1].name = "Daily % Change"
            this.lineCanada.yAxis[0].name = "Total Cases"
          } else {
            this.replaceSeries(this.doubleData.norm, this.totalData.norm);
            this.lineCanada.yAxis[1].name = "Doubling Time Days"
            this.lineCanada.yAxis[0].name = "Total Cases"
          }
        }
      } else {
        if (this.logscale) {
          if (this.rate) {
            this.replaceSeries(this.rateData.norm, this.deathData.log);
            this.lineCanada.yAxis[1].name = "Daily % Change"
            this.lineCanada.yAxis[0].name = "Total Deaths (log)"
          } else {
            this.replaceSeries(this.doubleData.norm, this.deathData.log);
            this.lineCanada.yAxis[1].name = "Doubling Time Days"
            this.lineCanada.yAxis[0].name = "Total Deaths (log)"
          }
        } else {
          if (this.rate) {
            this.replaceSeries(this.rateData.norm, this.deathData.norm);
            this.lineCanada.yAxis[1].name = "Daily % Change"
            this.lineCanada.yAxis[0].name = "Total Deaths"
          } else {
            this.replaceSeries(this.doubleData.norm, this.deathData.norm);
            this.lineCanada.yAxis[1].name = "Doubling Time"
            this.lineCanada.yAxis[0].name = "Total Deaths"
          }
        }
      }
      if (this.logscale) {
        this.lineCanada.yAxis[0].type = "log";
        this.lineCanada.toolbox.feature.magicType.type = this.lineCanada.toolbox.feature.magicType.type.filter(
          item => item !== "stack"
        );
      } else {
        this.lineCanada.yAxis[0].type = "value";
        this.lineCanada.toolbox.feature.magicType.type.push("stack");
      }
      this.$refs.chart.mergeOptions(cloneDeep(this.lineCanada), true);
    },
    changeRateToggle (val) { },
    loadData () {
      this.$axios
        .get("https://hub.analythium.io/covid-19/api/v1/data/canada/index.json")
        .then(response => {
          this.dataResponse = response.data;
          var total = this.dataResponse["numtotal"];
          var deaths = this.dataResponse["numdeaths"];
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
          for (let [key, value] of Object.entries(deaths)) {
            if (key !== "Date") {
              this.deathData.norm.push({
                name: key,
                data: value
              });
              this.deathData.log.push({
                name: key,
                data: value.map(item =>
                  isNaN(item) || item <= 0 ? 1 : item + 1
                )
              });
            }
          }
          for (let [key, value] of Object.entries(rate)) {
            if (key !== "Date") {
              config.series.push({
                id: "grid1-" + key,
                name: key,
                type: "line",
                data: value,
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
  mounted () {
    this.loadData();
  }
};
</script>
