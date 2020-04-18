<template>
  <q-page class="flex fit row wrap justify-center items-start content-start">
    <div class="q-pa-md">
      <!-- Heading for Canada vs World -->
      <div class="row">
        <div class="col">
          <h4>Canada and other countries</h4>
          <p class="text-body1">
            Compare the number of cases in Canada to data from other countries.
          </p>
        </div>
      </div>
      <!-- Controls for Canada vs World -->
      <div class="row">
        <div class="col">
          <q-toggle
            v-model="logscale"
            label="Log scale"
            left-label
          />
          <p>{{ logscale ? 'Log scale' : 'Normal scale'}} </p>
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
            @new-value="createValue"
            :options="filterOptions"
            @filter="filterFn"
            style="width: 250px"
          />
        </div>
      </div>
      <!-- Plot for Canada vs World -->
      <div class="row">
        <div class="col">
          <!-- <v-chart :options="lineCountries" /> -->
          <v-linechart
            :series="lineCountries.series"
            :dimensions="lineCountries.dimensions"
            :source="lineCountries.source"
            :axistype="logscale ? 'log' : 'value'"
          />
        </div>
      </div>
      <!-- Heading for Provinces -->
      <div class="row">
        <div class="col">
          <h4>Canadian provinces and territories</h4>
          <p class="text-body1">
            Compare provinces and territories within Canada.
          </p>
        </div>
      </div>
      <!-- Plot for Canada vs World -->
      <div class="row">
        <div class="col">
          <!-- <v-chart :options="lineCanada" /> -->
        </div>
      </div>
      <!-- Heading for Alberta -->
      <div class="row">
        <div class="col">
          <h4>Zones and areas within Alberta</h4>
          <p class="text-body1">
            Compare zones and areas within Alberta.
          </p>
        </div>
      </div>
      <!-- Plot for Canada vs World -->
      <div class="row">
        <div class="col">
          <!-- <v-chart :options="lineAlberta" /> -->
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
// import ECharts from "vue-echarts";
import LineChart from "components/LineChart";

import "echarts/lib/chart/bar";
import "echarts/lib/chart/line";
import "echarts/lib/component/tooltip";
import "echarts/lib/component/toolbox";
import "echarts/lib/component/dataZoom";
import "echarts/lib/component/legend";
import "echarts/lib/component/title";

import dataLineAlberta from "./data.alberta.json";
import dataLineCanada from "./data.canada.json";
import dataLineCountries from "./data.countries.json";

const stringOptions = [
  "France",
  "Spain",
  "Italy",
  "Canada",
  "Morocco",
  "Hungary"
];

export default {
  name: "PageIndex",
  components: {
    //    "v-chart": ECharts,
    "v-linechart": LineChart
  },
  data () {
    return {
      logscale: true,
      model: null,
      filterOptions: stringOptions,
      lineCountries: dataLineCountries,
      lineCanada: dataLineCanada,
      lineAlberta: dataLineAlberta
    };
  },
  methods: {
    createValue (val, done) {
      if (val.length > 0) {
        if (!stringOptions.includes(val)) {
          stringOptions.push(val);
        }
        done(val, "toggle");
      }
    },
    filterFn (val, update) {
      update(() => {
        if (val === "") {
          this.filterOptions = stringOptions;
        } else {
          const needle = val.toLowerCase();
          this.filterOptions = stringOptions.filter(
            v => v.toLowerCase().indexOf(needle) > -1
          );
        }
      });
    }
  }
};
</script>
