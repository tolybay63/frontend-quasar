<template>
  <div class="no-padding no-margin">
    <q-table
      class="my-sticky-header-table"
      color="primary" dense
      card-class="bg-amber-1 text-brown"
      row-key="id"
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
      <template #top-row>
      </template>

      <template v-slot:top>
        <div style="font-size: 1.2em; font-weight: bold" class="q-mr-xl">
          <q-avatar color="black" text-color="white" icon="home_work">
          </q-avatar>
          {{ $t("defect_objects") }}
        </div>

        <q-td colspan="100%" v-if="selected.length > 0">
          <span class="text-blue"> {{ $t("selectedRow") }}: </span>
          <span class="text-bold"> {{ this.infoSelected(selected[0]) }} </span>
        </q-td>
        <q-td colspan="100%" v-else-if="this.rows.length > 0" class="text-blue">
          {{ $t("infoRow") }}
        </q-td>

        <q-space/>
        <q-btn v-if="hasTarget('nsi:defect:ins')"
               icon="post_add" dense
               color="secondary"
               :disable="loading"
               @click="editRow(null, 'ins')"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("newRecord") }}
          </q-tooltip>
        </q-btn>
        <q-btn v-if="hasTarget('nsi:defect:upd')"
               icon="edit" dense
               color="secondary"
               class="q-ml-sm"
               :disable="loading || selected.length === 0"
               @click="editRow(selected[0], 'upd')"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("editRecord") }}
          </q-tooltip>
        </q-btn>
        <q-btn v-if="hasTarget('nsi:defect:del')"
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
          class="q-ml-xl"
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
import {hasTarget, notifyError, notifyInfo} from "src/utils/jsutils";
import {api} from "boot/axios";
import {extend} from "quasar";
import UpdaterDefectsObject from "pages/defect_objects/UpdaterDefectsObject.vue";

export default {
  name: "DefectObjectsPage",

  data: function () {
    return {
      loading: false,
      cols: [],
      rows: [],
      filter: "",
      selected: [],
      mapFvCategory: null,

    }
  },

  methods: {
    hasTarget,

    loadData() {
      this.loading = true;
      api
        .post('', {
          method: "data/loadDefects",
          params: [0],
        })
        .then(
          (response) => {
            this.rows = response.data.result["records"]
          })
        .catch(error=> {
          if (error.response.data.error.message.includes("@")) {
            let msgs = error.response.data.error.message.split("@")
            let m1 = this.$t(`${msgs[0]}`)
            let m2 = (msgs.length > 1) ? " [" + msgs[1] + "]" : ""
            let msg = m1 + m2
            notifyError(msg)
          } else {
            notifyError(this.$t(error.response.data.error.message))
          }
        })
        .finally(() => {
          this.loading = false
        })
    },

    editRow(row, mode) {
      let data = {
        accessLevel: 1,
      }

      if (mode === "upd") {
        extend(true, data, row)
      }

      this.$q
        .dialog({
          component: UpdaterDefectsObject,
          componentProps: {
            mode: mode,
            data: data,
            // ...
          },
        })
        .onOk((r) => {
          //console.log("Ok! updated", r);
          if (mode==="ins") {
            this.rows.push(r);
            this.selected = [];
            this.selected.push(r);
          } else {
            for (let key in r) {
              if (r.hasOwnProperty(key)) {
                row[key] = r[key];
              }
            }
          }
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
          api
            .post('', {
              method: "data/deleteOwnerWithProperties",
              params: [ rec.id, 1 ],
            })
            .then(
              () => {
                this.loadData()
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
          name: "name",
          label: this.$t("fldName"),
          field: "name",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:30%",
        },
        {
          name: "nameDefectsComponent",
          label: this.$t("cmp"),
          field: "nameDefectsComponent",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:10%",
        },
        {
          name: "DefectsIndex",
          label: this.$t("DefectsIndex"),
          field: "DefectsIndex",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:10%",
        },
        {
          name: "fvDefectsCategory",
          label: this.$t("DefectsCategory"),
          field: "fvDefectsCategory",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:10",
          format: (v) => this.mapFvCategory ? this.mapFvCategory.get(v): null
        },
        {
          name: "DefectsNote",
          label: this.$t("DefectsNote"),
          field: "DefectsNote",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:40%",
        },
      ]
    },

    infoSelected(row) {
      return " " + row.name + " - " + row.nameDefectsComponent
    },

  },

  created() {
    api
      .post('', {
        method: "data/loadFvForSelect",
        params: ["Factor_Defects"],
      })
      .then(
        (response) => {
          this.mapFvCategory = new Map()
          response.data.result["records"].forEach(r => {
            this.mapFvCategory.set(r.id, r.name);
          })
        })
      .then(()=> {
        this.cols = this.getColumns()
      })
      .then(()=> {
        this.loadData()
      })

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
