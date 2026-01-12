<template>
  <div class="q-pa-md">

    <q-splitter
      v-model="splitterModel"
      :limits="[0, 100]"
      :model-value="splitterModel"
      after-class="overflow-hidden q-ml-sm"
      before-class="overflow-hidden q-mr-sm"
      class="bg-amber-1"
      separator-class="bg-red"
    >

      <template v-slot:before>
        <div class="q-pa-sm-sm">
          <q-banner class="bg-orange-1 q-mb-sm" dense inline-actions>
            <div style="font-size: 1.2em; font-weight: bold;">
              <q-avatar color="black" icon="folder" text-color="white"></q-avatar>
              {{ $t("stocksGr") }}
            </div>
            <template v-slot:action>
              <q-btn
                v-if="hasTarget('mdl:mn_dop:stocks:insgr')"
                class="q-ml-sm"
                color="secondary"
                dense
                icon="post_add"
                @click="fnInsGr('ins', false)"
              >
                <q-tooltip transition-hide="rotate" transition-show="rotate">
                  {{ $t("create1level") }}
                </q-tooltip>
              </q-btn>

              <q-btn
                v-if="hasTarget('mdl:mn_dop:stocks:insgr')"
                :disable="currentNode == null"
                class="q-ml-sm img-vert"
                color="secondary"
                dense
                icon="post_add"
                @click="fnInsGr('ins', true)"
              >
                <q-tooltip transition-hide="rotate" transition-show="rotate">
                  {{ $t("createChild") }}
                </q-tooltip>
              </q-btn>

              <q-btn
                v-if="hasTarget('mdl:mn_dop:stocks:updgr')"
                :disable="currentNode == null"
                class="q-ml-sm"
                color="secondary"
                dense
                icon="edit"
                @click="fnInsGr('upd', null)"
              >
                <q-tooltip transition-hide="rotate" transition-show="rotate">
                  {{ $t("editRecord") }}
                </q-tooltip>
              </q-btn>

              <q-btn
                v-if="hasTarget('mdl:mn_dop:stocks:delgr')"
                :disable="currentNode == null"
                class="q-ml-sm"
                color="secondary"
                dense
                icon="delete"
                @click="fnDelGr(currentNode)"
              >
                <q-tooltip transition-hide="rotate" transition-show="rotate">
                  {{ $t("deletingRecord") }}
                </q-tooltip>
              </q-btn>

              <q-inner-loading :showing="visible" color="secondary"/>
            </template>
          </q-banner>

          <QTreeTable
            ref="childComp"
            :cols="cols"
            :icon_leaf="''"
            :rows="rows"
            checked_visible="true"
            @updateSelect="onUpdateSelect"
          />
        </div>
      </template>

      <template v-slot:after>


      </template>


    </q-splitter>


  </div>
</template>


<script>
import QTreeTable from "components/QTreeTable.vue";
import {
  collapsAll,
  expandAll,
  findNode,
  getParentNode,
  hasTarget,
  notifyError,
  notifyInfo,
  pack
} from "src/utils/jsutils.js";
import {api} from "boot/axios.js";
import UpdateGroup from "pages/group/UpdateGroup.vue";

export default {
  name: "StocksPage",
  components: {QTreeTable},


  data() {
    return {
      splitterModel: 30,
      cols: [],
      rows: [],
      currentNode: null,
      visible: false,

      stockId: 0,
      stockGrId: 0

    }
  },

  methods: {
    hasTarget,

    onUpdateSelect(item) {

      //this.propId = 0
      //if (this.currentNode2)
        //this.$refs.childComp2.selectedRow(this.currentNode2);

      this.currentNode = item.selected !== undefined ? item.selected : null;
      if (this.currentNode) {
        api
          .post('', {
            method: "group/loadRec",
            params: [{id: this.currentNode.id, tableName: "SourceStockGr"}],
          })
          .then((response) => {
            this.currentNode = response.data.result.records[0];

            this.fetchData(this.currentNode.id);
          });
      } else {
        //this.currentNode2 = null;
        this.fetchData(0);
      }
    },

    fetchDataGr() {
      this.visible = true
      this.currentNode = null

      api
        .post('', {
          method: "group/loadGroup",
          params: [{tableName: "SourceStockGr"}],
        })
        .then(
          (response) => {
            this.rows = pack(response.data.result.records, "id");
            this.fnExpand();
          },
          (error) => {

            let msg = error.message;
            if (error.response)
              msg = this.$t(error.response.data.error.message);

            notifyError(msg);
          }
        )
        .then(() => {
          if (this.stockGrId > 0 && this.$refs.childComp) {
            let res = []
            findNode(this.rows, "id", this.stockGrId, res)
            this.currentNode = res[0]
            this.$refs.childComp.restoreSelect(this.currentNode)
            this.fetchData(this.currentNode.id)
          }
        })
        .finally(() => {
          this.visible = false;
        });
    },

    fnInsGr(mode, isChild) {
      let data = {
        accessLevel: 1,
      };
      let parent = null;
      let parentName = null;
      if (isChild) {
        parent = this.currentNode.id;
        parentName = this.currentNode.name;
      }
      if (mode === "ins") {
        data.parent = parent;
      } else if (mode === "upd") {
        data = {
          id: this.currentNode.id,
          cod: this.currentNode.cod,
          name: this.currentNode.name,
          fullName: this.currentNode.fullName,
          accessLevel: this.currentNode.accessLevel,
          parent: this.currentNode.parent,
          cmt: this.currentNode.cmt,
        };
        if (this.currentNode.parent > 0) {
          let parentNode = [];
          getParentNode(this.rows, this.currentNode.parent, parentNode);
          //console.log("ParentNode-----", parentNode)
          parentName = parentNode[0].fullName;
          isChild = true;
        }
      }
      //
      this.$q
        .dialog({
          component: UpdateGroup,
          componentProps: {
            data: data,
            mode: mode,
            isChild: isChild,
            tableName: "SourceStockGr",
            parentName: parentName,
            dense: true,
          },
        })
        .onOk((data) => {
          this.fetchDataGr();
          this.currentNode = data
          this.$refs.childComp.restoreSelect(data)
          this.onUpdateSelect({selected: data})
        });
    },

    fnDelGr(rec) {
      rec.tableName = "SourceStockGr";
      this.$q
        .dialog({
          title: this.$t("confirmation"),
          message:
            this.$t("deleteRecord") +
            '<div style="color: plum">(' +
            rec.cod +
            ": " +
            rec.name +
            ")</div>",
          html: true,
          cancel: true,
          persistent: true,
          focus: "cancel",
        })
        .onOk(() => {
          //let index = this.rows.findIndex((row) => row.id === rec.id);
          api
            .post('', {
              method: "group/delete",
              params: [rec],
            })
            .then(
              () => {
                this.fetchDataGr();
              },
              (error) => {
                let msg = error.message;
                if (error.response) msg = error.response.data.error.message;

                notifyError(msg);
              }
            );
        })
        .onCancel(() => {
          notifyInfo(this.$t("canceled"));
        });
    },

    getColumns() {
      return [
        {
          name: "cod",
          label: this.$t("code"),
          field: "cod",
          align: "left",
          headerStyle: "font-size: 1.2em; width: 30%",
        },
        {
          name: "name",
          label: this.$t("fldName"),
          field: "name",
          align: "left",
          headerStyle: "font-size: 1.2em; width: 70%",
        },
      ];
    },

    fnExpand() {
      expandAll(this.rows);
    },

    fnCollapse() {
      collapsAll(this.rows);
    },



  },


  mounted() {
    this.stockId = parseInt(this.$route["params"].stock, 10);
    this.stockGrId = parseInt(this.$route["params"].stockGr, 10);

    this.fetchDataGr();

    //console.info("mounted params", this.$route.params)

  },

  created() {
    this.cols = this.getColumns();
    //this.cols2 = this.getColumns2();
  }


}


</script>

<style scoped>

</style>
