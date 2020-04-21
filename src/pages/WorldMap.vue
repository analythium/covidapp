<template>
  <q-page padding>
    <h4
      class="q-mx-md"
      style="margin: 0 0 1rem;"
    >Map of confirmed cases</h4>
    <p class="text-body1 q-mb-md">Latest number of confirmed cases worldwide.</p>
    <div class="row q-mt-md">
      <div class="col">
        <!-- comfirmed and deaths https://hub.analythium.io/covid-19/api/v1/data/world/latest/index.json -->
        <iframe
          frameBorder="0"
          style="height:70vh; width: 100%; margin: 0; padding: 0;"
          src="https://hub.analythium.io/covid-19/map.html"
        />
      </div>
    </div>
  </q-page>
</template>