<template>
  <q-layout view="hHh LpR lff">
    
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn
          dense
          flat
          round
          icon="menu"
          aria-label="Menu"
          @click="leftDrawerOpen = !leftDrawerOpen"
        />
        <q-toolbar-title>
          <q-avatar>
            <img src="https://hub.analythium.io/assets/logo/blues3/logo.png" />
          </q-avatar>COVID-19 App
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      content-class="bg-grey-1"
      :width="270"
    >
      <q-list>
        <q-item-label header class="text-grey-8">Navigation</q-item-label>
        <EssentialLink v-for="link in essentialLinks" :key="link.title" v-bind="link" />
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>

    <!-- <q-footer class="bg-grey-2 text-black">
      <q-toolbar>
        Footer text
      </q-toolbar>
    </q-footer>-->
  </q-layout>
</template>

<script>
import EssentialLink from "components/EssentialLink";

export default {
  name: "MainLayout",

  components: {
    EssentialLink
  },

  data() {
    return {
      leftDrawerOpen: false,
      essentialLinks: [
        {
          title: "World",
          caption: "Canada and other countries",
          icon: "public",
          link: "/"
        },
        {
          title: "Canada",
          caption: "Canadian provinces and territories",
          icon: "mdi-leaf-maple",
          link: "/canada"
        },
        {
          title: "Alberta",
          caption: "Zones and areas within Alberta",
          icon: "mdi-map-marker",
          link: "/alberta"
        }
        ,{
          title: "World Map",
          caption: "View hotspots of the world",
          icon: "mdi-globe-model",
          link: "/worldmap"
        }
      ]
    };
  }
};
</script>
