<template>
  <div class="q-pa-md bg-green-1">
    <q-banner dense inline-actions class="bg-orange-1">

      <div style="font-size: 1.2em; font-weight: bold;">
        <q-avatar color="black" text-color="white" icon="dashboard"></q-avatar>
        {{ $t("types_objects_comps") }}
      </div>

    </q-banner>

    <div>
      <q-inner-loading :showing="loading" color="secondary" />
    </div>

    <q-tabs dense v-model="tab" active-color="purple" class="text-teal no-scroll">
      <q-tab name="types" no-caps :label="$t('types_objects')" v-if="hasTarget('nsi:ot:typ')"/>
      <q-tab name="components" no-caps :label="$t('components')"  v-if="hasTarget('nsi:ot:com')"/>
      <q-tab name="comp_objects" no-caps :label="$t('comp_objects')"  v-if="hasTarget('nsi:ot:objcom')"/>
<!--      <q-tab name="comp_objects2" no-caps :label="$t('comp_objects')" />-->
    </q-tabs>

    <q-tab-panels v-model="tab" animated>
      <q-tab-panel name="types" class="no-scroll">
        <types-objects-page/>
      </q-tab-panel>

      <q-tab-panel name="components" class="no-scroll">
        <components-page/>
      </q-tab-panel>

<!--
      <q-tab-panel name="comp_objects" class="no-scroll">
        <component-objects-page codRelTyp="RT_Components"/>
      </q-tab-panel>
-->

      <q-tab-panel name="comp_objects" class="no-scroll">
        <component-objects-page2 codRelTyp="RT_Components"/>
      </q-tab-panel>

    </q-tab-panels>

  </div>
</template>

<script>
import TypesObjectsPage from "pages/types_objects/TypesObjectsPage.vue";
import ComponentsPage from "pages/types_objects/ComponentsPage.vue";
import ComponentObjectsPage2 from "pages/types_objects/ComponentObjectsPage2.vue";
import {hasTarget} from "src/utils/jsutils";

export default {
  name: "TypesObjectsSelectPage",
  methods: {hasTarget},
  components: {ComponentObjectsPage2, ComponentsPage, TypesObjectsPage},

  data: function () {
    return {
      loading: false,
      tab: "types"
    }
  },

  mounted() {
    if (hasTarget('nsi:ot:typ'))
      this.tab = "types";
    else if (hasTarget('nsi:ot:com'))
      this.tab = "components";
    else if (hasTarget('nsi:ot:objcom'))
      this.tab = "comp_objects";

  }


}
</script>

<style scoped>

</style>
