<template>
  <q-page padding>
    <h4 style="margin: 0 0 1rem;">Zones and areas within Alberta</h4>
    <p class="text-body1">Compare zones and areas within Alberta.</p>
    <!-- Plot for Alberta -->
    <div class="row">
      <div class="col">
        <v-chart class="q-mt-lg" autoresize :options="lineAlberta" />
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

import dataAlberta from "./data.alberta.json";

const dataLineAlberta = {
  legend: {},
  tooltip: {},
  dataset: {
    dimensions: [],
    source: []
  },
  grid: {
    left: "7%"
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
    orient: "vertical",
    feature: {
      dataZoom: { title: { zoom: "", back: "" } },
      magicType: {
        type: ["line", "bar"],
        title: { line: "", bar: "" }
      },
      restore: {},
      saveAsImage: { title: "Save" }
    }
  }
};
dataLineAlberta.dataset.source = dataAlberta.source;
dataLineAlberta.dataset.dimensions = dataAlberta.dimensions;
dataLineAlberta.series = dataAlberta.series;

export default {
  name: "PageIndex",
  components: {
    "v-chart": ECharts
  },
  data() {
    return {
      lineAlberta: dataLineAlberta
    };
  }
};
</script>