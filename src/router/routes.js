const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      { path: "", component: () => import("pages/World.vue") },
      { path: "canada", component: () => import("pages/Canada.vue") },
      { path: "alberta", component: () => import("pages/Alberta.vue") },
      { path: "worldmap", component: () => import("pages/WorldMap.vue") },
      { path: "areas", component: () => import("pages/Areas.vue") }
    ]
  }
];

// Always leave this as last one
if (process.env.MODE !== "ssr") {
  routes.push({
    path: "*",
    component: () => import("pages/Error404.vue")
  });
}

export default routes;
