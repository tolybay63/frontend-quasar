<template>
  <q-dialog
    ref="dialog"
    @hide="onDialogHide"
    persistent
    autofocus
    transition-show="slide-up"
    transition-hide="slide-down"
    style="width: 600px"
  >
    <q-card class="q-dialog-plugin" style="width: 600px">
      <q-bar v-if="mode === 'ins'" class="text-white bg-primary">
        <div>{{ $t("newRecord") }}</div>
      </q-bar>
      <q-bar v-if="mode === 'upd'" class="text-white bg-primary">
        <div>{{ $t("editRecord") }}</div>
      </q-bar>

      <q-card-section>

        <!-- objSection -->
        <q-select
          v-model="form['parent']"
          :model-value="form['parent']"
          :label="fmReqLabel('section')"
          :options="optSection"
          dense class="q-ma-md"
          map-options
          option-label="name"
          option-value="id"
          use-input
          @update:model-value="fnSelectSection"
          @filter="filterSection"
        />

        <!-- name -->
        <q-input
          :model-value="form.name"
          v-model="form.name"
          :label="fmReqLabel('fldName')"
          class="q-ma-md" dense autofocus
        >
        </q-input>
<!--    :rules="[(val) => (!!val && !!val.trim()) || $t('req')]"    -->

        <!-- StartKm -->
        <q-input
          :model-value="form['StartKm']"
          v-model="form['StartKm']"
          class="q-ma-md" dense type="number"
          :label="fmReqLabel('StartKm')"
        />

        <!-- StartPicket -->
        <q-input
          :model-value="form['StartPicket']"
          v-model="form['StartPicket']"
          class="q-ma-md" dense type="number"
          :label="fmReqLabel('StartPicket')"
        />

        <!-- FinishKm -->
        <q-input
          :model-value="form['FinishKm']"
          v-model="form['FinishKm']"
          class="q-ma-md" dense type="number"
          :label="fmReqLabel('FinishKm')"
        />

        <!-- FinishPicket -->
        <q-input
          :model-value="form['FinishPicket']"
          v-model="form['FinishPicket']"
          class="q-ma-md" dense type="number"
          :label="fmReqLabel('FinishPicket')"
        />


      </q-card-section>
      <!---->

      <q-card-actions align="right">
        <q-btn
          color="primary"
          icon="save" dense
          :label="$t('save')"
          @click="onOKClick"
          :disable="validSave()"
        />
        <q-btn
          color="primary"
          icon="cancel" dense
          :label="$t('cancel')"
          @click="onCancelClick"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script>
import {api, baseURL} from "boot/axios";
import {notifyError} from "src/utils/jsutils";

export default {
  props: ["mode", "data"],

  data() {
    return {
      loading: false,
      form: this.data,
      optSection: [],
      optSectionOrg: [],
    };
  },

  emits: [
    // REQUIRED
    "ok",
    "hide",
  ],

  methods: {
    fmReqLabel(label) {
      return this.$t(label) + "*";
    },

    fnSelectSection(v) {
      this.form.parent = v.id
      //this.form.pvSection = v["pv"]
    },

    filterSection(val, update) {
      if (val === null || val === '') {
        update(() => {
          this.optSection = this.optSectionOrg
        })
        return
      }
      update(() => {
        if (this.optSectionOrg.length < 2) return
        const needle = val.toLowerCase()
        let name = 'name'
        this.optSection = this.optSectionOrg.filter((v) => {
          return v[name].toLowerCase().indexOf(needle) > -1
        })
      })
    },

    validSave() {
      if (!this.form.parent || !this.form.name || !this.form.StartKm || !this.form.StartPicket ||
        !this.form.FinishKm || !this.form.FinishPicket) return true
    },

    // following method is REQUIRED
    // (don't change its name --> "show")
    show() {
      this.$refs.dialog.show();
    },

    // following method is REQUIRED
    // (don't change its name --> "hide")
    hide() {
      this.$refs.dialog.hide();
    },

    onDialogHide() {
      // required to be emitted
      // when QDialog emits "hide" event
      this.$emit("hide");
    },

    onOKClick() {
      // on OK, it is REQUIRED to
      // emit "ok" event (with optional payload)
      // before hiding the QDialog

      this.$axios
        .post(baseURL, {
          method: "data/saveStation",
          params: [ this.mode, this.form ],
        })
        .then(
          (response) => {
            this.$emit("ok", response.data.result.records[0]);
          },
          (error) => {
            //console.log("error.response.data=>>>", error.response.data.error.message)

            let msg = error.message;
            if (error.response)
              msg = this.$t(error.response.data.error.message);
            notifyError(msg);
          }
        )
        .finally(() => {
          this.hide();
        });
    },

    onCancelClick() {
      // we just need to hide the dialog
      this.hide();
    },
  },
  created() {

    this.loading = true
    api
      .post(baseURL, {
        method: 'data/loadObjList',
        params: ['Cls_Section', "Prop_Section", 'objectdata'],
      })
      .then(
        (response) => {
          this.optSection = response.data.result["records"]
          this.optSectionOrg = response.data.result["records"]
        })
      .finally(()=> {
        this.loading = false
      })

  },
};
</script>
