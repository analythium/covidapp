<template>
  <v-chart :options="line" />
</template>

<script>
import ECharts from "vue-echarts";

export default {
  name: 'LineChart',
  props: {
    series: {
      type: Array,
      required: true
    },
    dimensions: {
      type: Array,
      required: true
    },
    source: {
      type: Array,
      required: true
    },
    axistype: {
      type: String,
      default: 'log' // or 'value'
    }

  },
  components: {
    "v-chart": ECharts,
  },
  data () {
    return {
      line: {
        "legend": {},
        "tooltip": {},
        "dataset": {
          "dimensions": this.dimensions,
          "source": this.source
        },
        "xAxis": { "type": "category" },
        // "xAxis": { "type": "time" },
        "yAxis": { "type": this.axistype },
        "series": this.series,
        "dataZoom": [
          {
            "type": "inside",
            "start": 0,
            "end": 100
          },
          {
            "start": 0,
            "end": 100,
            "handleIcon": "M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z",
            "handleSize": "80%",
            "handleStyle": {
              "color": "#fff",
              "shadowBlur": 3,
              "shadowColor": "rgba(0, 0, 0, 0.6)",
              "shadowOffsetX": 2,
              "shadowOffsetY": 2
            }
          }
        ],
        "toolbox": {
          "show": true,
          "orient": "vertical",
          "feature": {
            "dataZoom": { "title": { "zoom": "", "back": "" } },
            "magicType": {
              "type": ["line", "bar"],
              "title": { "line": "", "bar": "" }
            },
            "restore": {},
            "saveAsImage": { "title": "Save" }
          }
        }
      }

    }
  }
}
</script>
