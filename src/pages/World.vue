<template>
  <q-page padding>
    <!-- Cumulative confirmed https://hub.analythium.io/covid-19/api/v1/data/world/confirmed/ -->
    <h4 style="margin: 0 0 1rem;">Canada and other countries</h4>
    <p class="text-body1">Compare the number of cases in Canada to data from other countries.</p>
    <!-- Controls for Canada vs World -->
    <div class="row">
      <div class="col">
        <q-toggle v-model="logscale" @input="changeToggle" label="Log scale" left-label />
      </div>
      <div class="col">
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
          style="width: 500px; float:right;"
          @input="changeDisplay"
        />
      </div>
    </div>
    <!-- Plot for Canada vs World -->
    <div class="row">
      <div class="col">
        <v-chart class="q-mt-lg" autoresize :options="lineCountries" />
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

import dataCountries from "./data.countries.json";

const dataLineCountries = {
  legend: { show: false, selected: {} },
  tooltip: {},
  dataset: {
    dimensions: [],
    source: []
  },
  grid: {
    left: "7%",
    top: "2.5%"
  },
  xAxis: { type: "category" },
  yAxis: { type: "log" },
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

const defaultCountries = ["France", "Italy", "Canada", "Germany", "Spain", "Japan"]

export default {
  name: "World",
  components: {
    "v-chart": ECharts
  },
  data() {
    return {
      logscale: true,
      model: null,
      filterOptions: null,
      lineCountries: null,
      stringOptions: null
    };
  },
  methods: {
    changeToggle(val) {
      if (val) {
        this.lineCountries.yAxis.type = "log";
      } else {
        this.lineCountries.yAxis.type = "value";
      }
    },
    changeDisplay(val){
      this.stringOptions.forEach(item => {
        if (val.includes(item)){
          this.lineCountries.legend.selected[item] = true
        } else {
          this.lineCountries.legend.selected[item] = false
        }
      })
    },
    filterFn(val, update) {
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
    loadData() {
      this.$axios
        .get(
          "https://hub.analythium.io/covid-19/api/v1/data/world/confirmed/index.json"
        )
        .then(response => {
          var config = dataLineCountries;
          config.dataset.source = response.data;
          config.dataset.dimensions = Object.keys(response.data[0]);
          config.series = Array(Object.keys(response.data[0]).length - 1).fill({
            type: "line",
          });
          const options = config.dataset.dimensions.filter(item => item !== "Date");
          options.forEach(item => {
            if (defaultCountries.includes(item)) {
              config.legend.selected[String(item)] = true
            } else {
              config.legend.selected[String(item)] = false
            }
          })
          this.lineCountries = config;
          this.filterOptions = options;
          this.stringOptions = options;
          this.model = config.dataset.dimensions.filter(item => defaultCountries.includes(item));
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
