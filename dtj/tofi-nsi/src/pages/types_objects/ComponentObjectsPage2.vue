<template>
  <div class="no-padding no-margin">
    <q-table
      style="height: calc(100vh - 280px); width: 100%"
      class="my-sticky-header-table"
      color="primary" dense
      card-class="bg-amber-1 text-brown"
      row-key="idro"
      :columns="cols"
      :rows="rows"
      :wrap-cells="true"
      :table-colspan="4"
      table-header-class="text-bold text-white bg-blue-grey-13"
      separator="cell"
      :filter="filter"
      :loading="loading"
      selection="single"
      v-model:selected="selected"
      :rows-per-page-options="[25, 50, 0]"
    >

      <template v-slot:top>

        <q-td colspan="100%" v-if="selected.length > 0">
          <span class="text-blue"> {{ $t("selectedRow") }}: </span>
          <span class="text-bold"> {{ this.infoSelected(selected[0]) }} </span>
        </q-td>
        <q-td colspan="100%" v-else-if="this.rows.length > 0" class="text-blue">
          {{ $t("infoRow") }}
        </q-td>


        <q-space/>
        <q-btn v-if="hasTarget('nsi:ol:ins')"
               icon="post_add" dense
               color="secondary"
               :disable="loading"
               @click="addRow()"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("newRecord") }}
          </q-tooltip>
        </q-btn>

        <q-btn v-if="hasTarget('nsi:ol:del')"
               icon="delete" dense
               color="secondary"
               class="q-mx-lg"
               :disable="loading || selected.length === 0"
               @click="removeRow(selected[0])"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("deletingRecord") }}
          </q-tooltip>
        </q-btn>

        <q-input
          dense
          debounce="300"
          color="primary"
          class="q-ml-lg"
          :model-value="filter"
          v-model="filter"
          :label="$t('txt_filter')"
        >
          <template v-slot:append>
            <q-icon name="search"/>
          </template>
        </q-input>
      </template>

      <template #loading>
        <q-inner-loading showing color="secondary"></q-inner-loading>
      </template>
    </q-table>
  </div>
</template>

<script>
import {baseURL} from "boot/axios";
import {hasTarget, notifyError, notifyInfo} from "src/utils/jsutils";
import UpdateChartsObjects2 from "pages/charts_objects/UpdateChartsObjects2.vue";

export default {
  props: ["codRelTyp"],
  name: "ComponentObjectsPage2",

  data: function () {
    return {
      loading: false,
      cols: [],
      rows: [],
      filter: "",
      selected: [],
      labelTyp1: "Тип обслуживаемого объекта",
      labelTyp2: "Компонент",

    }
  },

  methods: {
    hasTarget,

    fetchData() {
      this.loading = true;
      this.$axios
        .post(baseURL, {
          method: "data/loadComponentsObject2",
          params: [this.codRelTyp, "Typ_ObjectTyp", "Typ_Components"],
        })
        .then((response) => {
          //console.info("rows", response.data.result["records"])
          this.rows = response.data.result["records"]
          //console.info("rows2", this.rows)
        })
        .catch((error) => {
          let msg = error.message;
          if (error.response) msg = this.$t(error.response.data.error.message);

          notifyError(msg);
        })
        .finally(() => {
          this.loading = false
        })
    },

    addRow() {
      this.$q
        .dialog({
          component: UpdateChartsObjects2,
          componentProps: {
            data: {},
            codRelTyp: this.codRelTyp,
            codTyp1: "Typ_ObjectTyp",
            codTyp2: "Typ_Components",
            labelTyp1: this.labelTyp1,
            labelTyp2: this.labelTyp2,

            // ...
          },
        })
        .onOk((r) => {
          //console.log("Ok! updated", r);
          if (r.res)
            this.fetchData()

/*
          for (let key in r) {
            if (r.hasOwnProperty(key)) {
              rec[key] = r[key];
            }
          }
*/

        })

    },


    removeRow(rec) {
      this.$q
        .dialog({
          title: this.$t("confirmation"),
          message:
            this.$t("deleteRecord") +
            '<div style="color: plum">(' + rec.name + ")</div>",
          html: true,
          cancel: true,
          persistent: true,
          focus: "cancel",
        })
        .onOk(() => {
          //let index = this.rows.findIndex((row) => row.id === rec.id);
          this.$axios
            .post(baseURL, {
              method: "data/deleteOwnerWithProperties",
              params: [rec.idro, 0],
            })
            .then(
              () => {
                this.fetchData()
                this.selected = []
              })
            .catch(error => {
              console.log(error.message)
              notifyInfo(error.message)
            })
        })
        .onCancel(() => {
          notifyInfo(this.$t("canceled"));
        })
    },

    getColumns() {
      return [
        {
          name: "namerom1",
          label: this.labelTyp1, //this.$t("fldName"),
          field: "namerom1",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width: 50%",
        },

        {
          name: "namerom2",
          label: this.labelTyp2, //this.$t("fldName"),
          field: "namerom2",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width: 50%",
        },

        /*        {
                  name: "cmt",
                  label: this.$t("fldCmt"),
                  field: "cmt",
                  align: "left",
                  classes: "bg-blue-grey-1",
                  headerStyle: "font-size: 1.2em; width: 20%",
                },*/
      ]
    },

    infoSelected(row) {
      return " " + row.namerom1 + " <=> " + row.namerom2
    },

  },

  created() {
    this.cols = this.getColumns();
    this.fetchData()
  }

}
</script>

<style lang="sass">
.my-sticky-header-table
  /* height or max-height is important */
  height: calc(100vh - 140px)
  /* bg color is important for th; just specify one */
  background-color: #bdbdbd

  thead tr th
    position: sticky
    z-index: 1

  thead tr:first-child th
    top: 0

  /* this is when the loading indicator appears */

  &.q-table--loading thead tr:last-child th
    /* height of all previous header rows */
    top: 48px

  /* prevent scrolling behind sticky top row on focus */

  tbody
    /* height of all previous header rows */
    scroll-margin-top: 48px
</style>
