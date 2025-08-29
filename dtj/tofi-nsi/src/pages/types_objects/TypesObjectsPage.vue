<template>
  <div class="no-padding no-margin">
    <q-table
      style="height: calc(100vh - 280px); width: 100%"
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
      :rows-per-page-options="[25,50,0]"
    >
      <template v-slot:top>

        <q-td colspan="100%" v-if="selected.length > 0">
          <span class="text-blue"> {{ $t("selectedRow") }}: </span>
          <span class="text-bold"> {{ infoSelected(selected[0]) }} </span>
        </q-td>
        <q-td colspan="100%" v-else-if="rows.length > 0" class="text-blue">
          {{ $t("infoRow") }}
        </q-td>

        <q-space/>

        <q-btn v-if="hasTarget('nsi:ot:typ:ins')"
               icon="post_add" dense
               color="secondary"
               :disable="loading"
               @click="editRow(null, 'ins')"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("newRecord") }}
          </q-tooltip>
        </q-btn>

        <q-btn v-if="hasTarget('nsi:ot:typ:upd')"
               icon="edit" dense
               color="secondary"
               class="q-mx-md"
               :disable="loading || selected.length === 0"
               @click="editRow(selected[0], 'upd')"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("editRecord") }}
          </q-tooltip>
        </q-btn>
        <q-btn v-if="hasTarget('nsi:ot:typ:del')"
               icon="delete" dense
               color="secondary"
               class="q-mx-md"
               :disable="loading || selected.length === 0"
               @click="removeRow(selected[0])"
        >
          <q-tooltip transition-show="rotate" transition-hide="rotate">
            {{ $t("deletingRecord") }}
          </q-tooltip>
        </q-btn>


        <q-input
          dense class="q-ml-lg"
          debounce="300"
          color="primary"
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

import {ref} from "vue";
import {api, baseURL} from "boot/axios";
import {hasTarget, notifyError, notifyInfo} from "src/utils/jsutils";
import UpdaterTypesObjects from "pages/types_objects/UpdaterTypesObjects.vue";
import {extend} from "quasar";


const expand = (item) => {
  item.expend = ref(true);
  const {children} = item;
  if (children.length > 0) item.leaf = ref(false);
  else item.leaf = ref(true);
};

export default {
  name: "TypesObjectsPage",
  data() {
    return {
      loading: false,
      cols: [],
      rows: [],
      filter: "",
      selected: [],

      FD_PropType: null,
      FD_DimPropType: null,
      mapCls: null,
      mapFvOt: null,
    };
  },

  methods: {
    hasTarget,

    editRow(row, mode) {
      let data = {
        accessLevel: 1,
      }

      if (mode === "upd") {
        extend(true, data, row)
      }

      this.$q
        .dialog({
          component: UpdaterTypesObjects,
          componentProps: {
            mode: mode,
            data: data,
            // ...
          },
        })
        .onOk((r) => {
          //console.log("Ok! updated", r);
          if (mode === "ins") {
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
          this.$axios
            .post(baseURL, {
              method: "data/deleteOwnerWithProperties",
              params: [rec.id, 1],
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


    loadData() {
      this.loading = true;
      api
        .post(baseURL, {
          method: "data/loadTypesObjects",
          params: [0],
        })
        .then(
          (response) => {
            this.rows = response.data.result["records"]
            this.fnExpand()
          })
        .catch(error => {
          if (error.response && error.response.data) {
            if (error.response.data.error.message.includes("@")) {
              let msgs = error.response.data.error.message.split("@")
              let m1 = this.$t(`${msgs[0]}`)
              let m2 = (msgs.length > 1) ? " [" + msgs[1] + "]" : ""
              let msg = m1 + m2
              notifyError(msg)
            } else {
              notifyError(this.$t(error.response.data.error.message))
            }
          }
        })
        .finally(() => {
          this.loading = false
        })

    },

    infoSelected(row) {
      return " " + row.name
    },

    getColumns() {
      return [
        {
          name: "number",
          label: "№",
          field: "number",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:10%",
        },
        {
          name: "name",
          label: this.$t("fldName"),
          field: "name",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:35%",
        },
        {
          name: "cls",
          label: this.$t("class"),
          field: "cls",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width: 40%",
          format: (v) => this.mapCls ? this.mapCls.get(v) : null
        },
        {
          name: "fvShape",
          label: this.$t("Typ_ObjectTyp"),
          field: "fvShape",
          align: "left",
          classes: "bg-blue-grey-1",
          headerStyle: "font-size: 1.2em; width:15%",
          format: (v) => this.mapFvOt ? this.mapFvOt.get(v) : null
        },
      ]
    }

  },

  computed: {
    arrayTreeObj() {
      let vm = this;
      let newObj = [];
      vm.recursive(vm.rows, newObj, 0, vm.itemId, vm.isExpanded);
      return newObj;
    },
  },

  mounted() {
    console.info("mounted")
    this.cols = this.getColumns()
  },

  created() {
  console.info("created")
    api
      .post(baseURL, {
        method: "data/loadClsForSelect",
        params: ["Typ_ObjectTyp"],
      })
      .then(
        (response) => {
          this.mapCls = new Map()
          response.data.result["records"].forEach(r => {
            this.mapCls.set(r.id, r.name);
          })
        })
      .then(() => {
        api
          .post(baseURL, {
            method: "data/loadFvOt",
            params: ["Factor_Shape"],
          })
          .then(
            (response) => {
              this.mapFvOt = new Map()
              response.data.result["records"].forEach(r => {
                this.mapFvOt.set(r.id, r.name);
              })
            })
      })
      .then(() => {
        this.cols = this.getColumns()
      })
      .then(() => {
        this.loadData()
      })

  }


}
</script>

<style scoped>

</style>
