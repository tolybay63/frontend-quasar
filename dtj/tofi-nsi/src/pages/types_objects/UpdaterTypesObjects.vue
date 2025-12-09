<template>
  <q-dialog
      ref="dialog"
      @hide="onDialogHide"
      persistent
      autofocus
      transition-show="slide-up"
      transition-hide="slide-down"
  >
    <q-card class="q-dialog-plugin" style="width: 600px">
      <q-bar v-if="mode === 'ins'" class="text-white bg-primary">
        <div>{{ $t("newRecord") }}</div>
      </q-bar>
      <q-bar v-if="mode === 'upd'" class="text-white bg-primary">
        <div>{{ $t("editRecord") }}</div>
      </q-bar>

      <q-inner-loading :showing="visible" color="secondary"/>

      <q-card-section>
        <!-- name -->
        <q-input
            class="q-ma-md"
            dense :model-value="form.name"
            v-model="form.name"
            :disable="mode === 'upd'"
            @blur="onBlurName"
            :label="fmReqLabel('fldName')" autofocus
            :rules="[(val) => (!!val && !!val.trim()) || $t('req')]"
        >
        </q-input>

        <!-- fvShape -->
        <q-select
          v-model="form.fvShape"
          :model-value="form.fvShape"
          :label="fmReqLabel('Typ_ObjectTyp')"
          :options="optFvOt"
          dense options-dense map-options
          option-label="name" option-value="id"
          class="q-ma-md" clearable
          @update:model-value="fnSelectFvOt"
          @clear="fnClearFvOt"
        />

        <!---->
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
            dense color="primary"
            icon="save"
            :label="$t('save')"
            @click="onOKClick"
            :disable="validSave()"
        />
        <q-btn
            dense color="primary"
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
import {extend} from "quasar";

export default {

  props: [
    "data",
    "mode",
  ],

  data() {
    return {
      form: extend({}, this.data),
      visible: false,
      lang: this.lg,
      optFvOt: [],
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

    fnSelectFvOt(v) {
      if (v) {
        this.form.fvShape = v.id
        this.form.pvShape = v["pv"]
      }
    },

    fnClearFvOt() {
      this.form.fvShape = null
      this.form.pvShape = null
    },

    onBlurName() {
      if (this.form.name) {
        this.form.name = this.form.name.trim();
        if (
            !this.form.fullName ||
            (this.form.fullName && this.form.fullName.trim() === "")
        ) {
          this.form.fullName = this.form.name;
        }
      }
    },

    validSave() {
      if (!this.form.fvShape || !this.form.name) return true;
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
          .post('', {
            id: this.form.id,
            method: "data/saveTypesObjects",
            params: [this.mode, this.form],
          })
          .then(
              (response) => {
                this.$emit("ok", response.data.result["records"][0]);
                notifySuccess(this.$t("success"));
              },
              (error) => {
                //console.log("error.response.data=>>>", error.response.data.error.message)
                notifyError(error.response.data.error.message);
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
    //
    this.loading = true
    api
      .post('', {
        method: 'data/loadFvForSelect',
        params: ['Factor_Shape'],
      })
      .then(
        (response) => {
          this.optFvOt = response.data.result["records"]
        })
      .catch(error => {
          let msg = error.message
          if (error.response) msg = this.$t(error.response.data.error.message)
          notifyError(msg)
        }
      )
      .finally(() => {
        this.loading = false
      })
    //

    if (this.form.parent) {
      this.loading = true
      api
        .post('', {
          method: 'data/getCls',
          params: [this.form.parent],
        })
        .then(
          (response) => {
            this.form.cls = response.data.result
          })
        .catch(error => {
            let msg = error.message
            if (error.response) msg = this.$t(error.response.data.error.message)
            notifyError(msg)
          }
        )
        .finally(() => {
          this.loading = false
        })

    }



  }

}
</script>
