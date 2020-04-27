<template>
  <q-page padding>
    <!-- Cumulative confirmed https://hub.analythium.io/covid-19/api/v1/data/world/confirmed/ -->
    <h4 style="margin: 0 0 1rem;">Canada and other countries</h4>
    <p class="text-body1 q-mb-md">Compare the number of cases in Canada to data from other countries. Toggle view to the logarithmic scale and back.</p>
    <!-- Controls for Canada vs World -->
    <div class="row">
      <div class="col-2">
        <q-toggle
          v-model="logscale"
          @input="changeToggle"
          label="Log scale"
        />
      </div>
      <div class="col-10">
        <q-select
          rounded
          standout
          v-model="model"
          use-input
          use-chips
          multiple
          hint="Select countries"
          input-debounce="0"
          :options="filterOptions"
          @filter="filterFn"
          style="width: 100%; float:right;"
          @input="changeDisplay"
        />
      </div>
    </div>
    <!-- Plot for Canada vs World -->
    <div class="row">
      <div
        class="col"
        style="height: 89vh"
      >
        <v-chart
          class="q-mx-md"
          autoresize
          :options="lineCountries"
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
import "echarts/lib/chart/bar";
import "echarts/lib/chart/line";
import "echarts/lib/component/tooltip";
import "echarts/lib/component/toolbox";
import "echarts/lib/component/dataZoom";
import "echarts/lib/component/legend";
import "echarts/lib/component/title";
var pick = require("lodash.pick");
var cloneDeep = require("lodash.clonedeep");

import dataCountries from "./data.countries.json";

const dataLineCountries = {
  legend: { show: true, selected: {} },
  tooltip: {
    trigger: "axis",
    axisPointer: {
      animation: false
    }
  },
  dataset: {
    dimensions: [],
    source: []
  },
  grid: {
    left: "7%",
    containLabel: true
  },
  xAxis: { type: "category" },
  yAxis: { type: "log", minorTick: { show: true }, name: "Total Cases (log)", nameGap: 60, nameLocation: "middle" },
  series: [],
  dataZoom: [
    {
      type: "inside",
      start: 0,
      end: 100
    },
    {
      start: 0,
      end: 100,
      handleIcon:
        "M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z",
      handleSize: "80%",
      handleStyle: {
        color: "#fff",
        shadowBlur: 3,
        shadowColor: "rgba(0, 0, 0, 0.6)",
        shadowOffsetX: 2,
        shadowOffsetY: 2
      }
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
        title: { line: "Line", bar: "Bar", stack: "Stacked" }
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

const defaultCountries = [
  "France",
  "Italy",
  "Canada",
  "Germany",
  "Spain",
  "Japan"
];

export default {
  name: "World",
  components: {
    "v-chart": ECharts
  },
  data () {
    return {
      logscale: true,
      model: null,
      filterOptions: null,
      lineCountries: null,
      stringOptions: null,
      dataResponse: null,
      logDataset: null,
      regDataset: null
    };
  },
  methods: {
    changeToggle (val) {
      if (val) {
        this.lineCountries.yAxis.type = "log";
        this.lineCountries.toolbox.feature.magicType.type = this.lineCountries.toolbox.feature.magicType.type.filter(
          item => item !== "stack"
        );
        this.lineCountries.dataset.source = cloneDeep(this.logDataset);
        this.lineCountries.yAxis.name = "Total Cases (log)"
      } else {
        this.lineCountries.yAxis.type = "value";
        this.lineCountries.toolbox.feature.magicType.type.push("stack");
        this.lineCountries.dataset.source = cloneDeep(this.regDataset);
        this.lineCountries.yAxis.name = "Total Cases"
      }
    },
    changeDisplay (val) {
      if (this.dataResponse !== null) this.setConfig(val);
    },
    setConfig (selected) {
      if (this.dataResponse == null) return;
      try {
        var config = dataLineCountries;
        const toKeep = Object.keys(this.dataResponse[0]).filter(
          item => selected.includes(item) || item == "Date"
        );
        this.regDataset = cloneDeep(this.dataResponse);
        this.logDataset = cloneDeep(this.dataResponse);
        this.regDataset.forEach((item, index) => {
          const newobj = pick(this.regDataset[index], toKeep);
          var logobj = cloneDeep(newobj);
          this.regDataset[index] = newobj;
          for (let [key, value] of Object.entries(logobj)) {
            if (key !== "Date") logobj[key] = value + 1;
          }
          this.logDataset[index] = logobj;
        });
        config.series = Array(toKeep.length - 1).fill({
          type: "line"
        });
        config.dataset.dimensions = toKeep;
        config.yAxis.type = this.logscale ? "log" : "value";
        config.dataset.source = this.logscale
          ? this.logDataset
          : this.regDataset;
        this.logscale
          ? (config.toolbox.feature.magicType.type = config.toolbox.feature.magicType.type.filter(
            item => item !== "stack"
          ))
          : config.toolbox.feature.magicType.type.push("stack");
        this.lineCountries = cloneDeep(config);
      } catch (error) {
        console.log(error);
      }
    },
    filterFn (val, update) {
      update(() => {
        if (val === "") {
          this.filterOptions = this.stringOptions;
        } else {
          const needle = val.toLowerCase();
          this.filterOptions = this.stringOptions.filter(
            v => v.toLowerCase().indexOf(needle) > -1
          );
        }
      });
    },
    loadData () {
      this.$axios
        .get(
          "https://hub.analythium.io/covid-19/api/v1/data/world/confirmed/index.json"
        )
        .then(response => {
          this.dataResponse = response.data;
          const options = Object.keys(this.dataResponse[0]).filter(
            item => item !== "Date"
          );
          this.setConfig(defaultCountries);
          this.filterOptions = options;
          this.stringOptions = options;
          this.model = options.filter(item => defaultCountries.includes(item));
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
