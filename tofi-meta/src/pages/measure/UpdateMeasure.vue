<template>
  <q-dialog
    ref="dialog"
    autofocus
    persistent
    style="width: 600px"
    transition-hide="slide-down"
    transition-show="slide-up"
    @hide="onDialogHide"
  >
    <q-card class="q-dialog-plugin" style="width: 600px">
      <q-bar v-if="mode === 'ins'" class="text-white bg-primary">
        <div>{{ $t("newRecord") }}</div>
      </q-bar>
      <q-bar v-if="mode === 'upd'" class="text-white bg-primary">
        <div>{{ $t("editRecord") }}</div>
      </q-bar>

      <q-card-section>
        <q-item-section v-if="isChild">
          {{ $t("baseMeasure") }}: {{ parentName }}
        </q-item-section>

        <!-- name -->
        <q-input
          v-model="form.name"
          :label="$t('fldName')"
          :model-value="form.name"
          :rules="[(val) => (!!val && !!val.trim()) || $t('req')]"
          autofocus
          @blur="onBlurName"
        >
        </q-input>
        <!-- fullName-->
        <q-input
          v-model="form.fullName"
          :label="$t('fldFullName')"
          :model-value="form.fullName"
          :rules="[(val) => (!!val && !!val.trim()) || $t('req')]"
        >
        </q-input>

        <!-- cod -->
        <q-input
          v-model="form.cod"
          :label="$t('code')"
          :model-value="form.cod"
          :placeholder="$t('msgCodeGen')"
        />
        <!-- accessLevel -->
        <q-select
          v-model="al"
          :label="$t('accessLevel')"
          :model-value="al"
          :option-label="dictText()"
          :options="options"
          map-options
          option-value="id"
          @update:model-value="fnSelect()"
        />

        <!-- kFromBase -->
        <q-input
          v-if="isChild"
          v-model="form.kFromBase"
          :label="$t('kfcMeasure')"
          :model-value="form.kFromBase"
          input-class="text-right"
          type="number"
        >
        </q-input>

        <!-- cmt -->
        <q-input
          v-model="form.cmt"
          :label="$t('fldCmt')"
          :model-value="form.cmt"
          type="textarea"
        >
        </q-input>
        <!---->
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          :disable="validName()"
          :label="$t('save')"
          color="primary"
          icon="save"
          @click="onOKClick"
        />
        <q-btn
          :label="$t('cancel')"
          color="primary"
          icon="cancel"
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
  props: ["mode", "isChild", "parentName", "data"],

  data() {
    return {
      form: this.data,
      options: [],
      al: this.data.accessLevel === 0 ? 1 : this.data.accessLevel,
    };
  },
  //al: this.form.accessLevel===0 ? 1 : this.form.accessLevel
  emits: [
    // REQUIRED
    "ok",
    "hide",
  ],

  methods: {
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

    fnSelect() {
      //console.log("select", this.al)
      this.form.accessLevel = this.al.id;
    },

    dictText() {
      return "text";
    },

    validName() {
      return (
        !this.form.name ||
        !this.form.fullName ||
        parseFloat(this.form.kFromBase) <= 0
      );
    },

    // following method is REQUIRED
    // (don't change its name --> "show")
    show() {
      this.$refs.dialog["show"]();
    },

    // following method is REQUIRED
    // (don't change its name --> "hide")
    hide() {
      this.$refs.dialog["hide"]();
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

      delete this.form["accessLevel_text"];
      const method = this.mode === "ins" ? "insert" : "update";
      this.form.accessLevel =
        typeof this.al === "object" ? this.al.id : this.al;
      this.form.lang = localStorage.getItem("curLang")

      api
        .post('', {
          method: "measure/" + method,
          params: [{rec: this.form}],
        })
        .then(
          (response) => {
            //this.$emit("ok", {res: true});
            this.$emit("ok", response.data.result.records[0]);
            notifySuccess(this.$t("success"));
          },
          (error) => {
            //console.log("error.response.data=>>>", error.response.data.error.message)
            let msg = error.response.data.error.message
              ? error.response.data.error.message
              : error.message;
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
    let lang = localStorage.getItem("curLang")
    api
      .post('', {
        method: "dict/load",
        params: [{dict: "FD_AccessLevel", lang: lang}],
      })
      .then((response) => {
        this.options = response.data.result.records;
      });
  },
};
</script>
