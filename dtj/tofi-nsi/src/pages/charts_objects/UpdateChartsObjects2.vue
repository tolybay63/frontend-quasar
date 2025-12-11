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
      <q-bar class="text-white bg-primary">
        <div>{{ $t("newRecord") }}</div>
      </q-bar>

      <q-card-section>

        <!-- objUch1 -->
        <q-select
          v-model="form['uch1']"
          :model-value="form['uch1']"
          :label= labelTyp1
          :options="optUch1"
          dense class="q-ma-md"
          map-options
          option-label="fullname"
          option-value="id"
          use-input
          @update:model-value="fnSelectUch1"
          @filter="filterUch1"
        />

        <!-- objUch2 -->
        <q-select
          v-model="form['uch2']"
          :model-value="form['uch2']"
          :label=labelTyp2
          :options="optUch2"
          dense class="q-ma-md"
          map-options
          option-label="name"
          option-value="id"
          use-input
          :disabled="!(form['uch1']>0)"
          @update:model-value="fnSelectUch2"
          @filter="filterUch2"
        />


        <!---->
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
            dense
            color="primary"
            icon="save"
            :label="$t('save')"
            @click="onOKClick"
            :disable="validSave()"
        />
        <q-btn
            dense
            color="primary"
            icon="cancel"
            :label="$t('cancel')"
            @click="onCancelClick"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script>
import {api} from "boot/axios";
import {notifyError, notifySuccess} from "src/utils/jsutils";

export default {
  props: ["data", "mode", "codRelTyp", "codTyp1", "codTyp2", "labelTyp1", "labelTyp2"],

  data() {
    return {
      form: this.data,
      lang: this.lg,
      optUch1: [],
      optUch1Org: [],
      optUch2: [],
      optUch2Org: [],
      name1: "",
      name: ""
    };
  },

  emits: [
    // REQUIRED
    "ok",
    "hide",
  ],

  methods: {

    fnSelectUch1(v) {
      if (v) {
        this.form.uch1 = v.id
        this.form.cls1 = v.cls
        this.name1 = v.name
        this.loadUch2(v.id)
      }
    },

    filterUch1(val, update) {
      if (val === null || val === '') {
        update(() => {
          this.optUch1 = this.optUch1Org
        })
        return
      }
      update(() => {
        if (this.optUch1Org.length < 2) return
        const needle = val.toLowerCase()
        let name = 'name'
        this.optUch1 = this.optUch1Org.filter((v) => {
          return v[name].toLowerCase().indexOf(needle) > -1
        })
      })
    },

    fnSelectUch2(v) {
      this.form.uch2 = v.id
      this.form.cls2 = v.cls
      this.name = this.name1 + " <=> " + v.name
    },

    filterUch2(val, update) {
      if (val === null || val === '') {
        update(() => {
          this.optUch2 = this.optUch2Org
        })
        return
      }
      update(() => {
        if (this.optUch2Org.length < 2) return
        const needle = val.toLowerCase()
        let name = 'name'
        this.optUch2 = this.optUch2Org.filter((v) => {
          return v[name].toLowerCase().indexOf(needle) > -1
        })
      })
    },

    loadUch2(id) {
      this.loading = true
      api
        .post('', {
          method: 'data/loadUch2',
          params: [this.codRelTyp, id, this.codTyp2],
        })
        .then(
          (response) => {
            this.optUch2 = response.data.result["records"]
            this.optUch2Org = response.data.result["records"]
            console.log("optUch2", this.optUch2)
          })
        .catch((error) => {
          console.log(error);
        })
        .finally(() => {
          this.loading = false
        })
    },

    validSave() {
      return !this.form.uch1 || !this.form.uch2
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

      let err = false;
      this.form['codRelTyp'] = this.codRelTyp;
      this.form['name'] = this.name;
      api
          .post('', {
            id: this.form.id,
            method: "data/saveRelObj",
            params: [this.form],
          })
          .then(
              () => {
                err = false;
                this.$emit("ok", {res: true});
                notifySuccess(this.$t("success"));
              },
              (error) => {
                //console.log("error.response.data=>>>", error.response.data.error.message)
                err = true;
                notifyError(error.response.data.error.message);
              }
          )
          .finally(() => {
            if (!err) this.hide();
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
      .post('', {
        method: 'data/loadObjFromTyp',
        params: [this.codTyp1],
      })
      .then(
        (response) => {
          this.optUch1 = response.data.result["records"]
          this.optUch1Org = response.data.result["records"]
          //console.log("optUch1", this.optUch1)
        })
    .catch((error) => {
      console.log(error);
    })
    .finally(() => {
      this.loading = false
    })
    //

  },
};
</script>
