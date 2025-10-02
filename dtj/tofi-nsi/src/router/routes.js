const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue') },
      {path: '/source_collections', name: "SourceCollectionsPage", component: () => import('pages/source_collections/SourceCollectionsPage.vue')},
      {path: '/process_charts', name: "ProcessChartsPage", component: () => import('pages/process_charts/ProcessChartsPage.vue')},
      {path: '/types_objects', name: "TypesObjectsSelectPage", component: () => import('pages/types_objects/TypesObjectsSelectPage.vue')},
      {path: '/charts_objects', name: "ChartsObjectsPage2", component: () => import('pages/charts_objects/ChartsObjectsPage2.vue')},
      {path: '/param_objects', name: "ParamObjectsPage", component: () => import('pages/param_objects/ParamObjectsSelectPage.vue')},
      {path: '/defect_objects', name: "DefectObjectsPage", component: () => import('pages/defect_objects/DefectObjectsPage.vue')},
      {path: '/section', name: "SectionPage", component: () => import('pages/section/SectionPage.vue')},
      {path: '/separation_point', name: "SeparationPointPage", component: () => import('pages/separation_point/SeparationPointPage.vue')},
      {path: '/hauls', name: "HaulsPage", component: () => import('pages/hauls/HaulsPage.vue')},
    ]
  },

  //{path: '/charts_objects', name: "ChartsObjectsPage", component: () => import('pages/charts_objects/ChartsObjectsPage.vue')},


  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
