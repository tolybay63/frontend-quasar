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
        <div>{{ txt_lang("newRecord") }}</div>
      </q-bar>
      <q-bar v-if="mode === 'upd'" class="text-white bg-primary">
        <div>{{ txt_lang("editRecord") }}</div>
      </q-bar>

      <q-card-section>
        <q-input
          :dense="dense"
          v-model="myData.cod"
          :model-value="myData.cod"
          :label="txt_lang('code')"
          :placeholder="txt_lang('msgCodeGen')"
        />

        <q-select
          :dense="dense"
          :options-dense="dense"
          v-model="al"
          :options="options"
          :label="txt_lang('accessLevel')"
          option-value="id"
          option-label="text"
          map-options
          :model-value="al"
          @update:model-value="fnSelect()"
        />

        <!-- name -->
        <q-input
          :dense="dense"
          :model-value="myData.name"
          v-model="myData.name"
          autofocus class="q-pt-md"
          @blur="onBlurName"
          :label="txt_lang('fldName')"
          :rules="[(val) => (!!val && !!val.trim()) || txt_lang('req')]"
        >
        </q-input>
        <!-- fullName-->
        <q-input
          :dense="dense"
          :model-value="myData.fullName"
          v-model="myData.fullName"
          :label="txt_lang('fldFullName')"
          :rules="[(val) => (!!val && !!val.trim()) || txt_lang('req')]"
        >
        </q-input>
        <!-- roleTag-->
        <q-input
          :dense="dense"
          :model-value="myData['roleTag']"
          v-model="myData['roleTag']"
          :label="txt_lang('fldRoleTag')"
        >
        </q-input>

        <!-- cmt -->
        <q-input
          :dense="dense"
          :model-value="myData.cmt"
          v-model="myData.cmt"
          type="textarea"
          class="q-pt-md"
          :label="txt_lang('fldCmt')"
        >
        </q-input>
        <!---->
      </q-card-section>

      <q-card-actions align="right">
        <q-btn
          :dense="dense"
          color="primary"
          icon="save"
          :label="txt_lang('save')"
          @click="onOKClick"
          :disable="validName()"
        />
        <q-btn
          :dense="dense"
          color="primary"
          icon="cancel"
          :label="txt_lang('cancel')"
          @click="onCancelClick"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script>
import {api} from "boot/axios";
import {notifyError, notifySuccess, txt_lang} from "src/utils/jsutils";

export default {
  props: ["form", "mode", "action", "dense"],

  data() {
    return {
      myData: this.form,
      act: this.action,
      options: [],
      al: this.form.accessLevel === 0 ? 1 : this.form.accessLevel,
    };
  },

  emits: [
    // REQUIRED
    "ok",
    "hide",
  ],

  methods: {
    txt_lang,
    onBlurName() {
      if (this.myData.name) {
        this.myData.name = this.myData.name.trim();
        if (
          !this.myData.fullName ||
          (this.myData.fullName && this.myData.fullName.trim() === "")
        ) {
          this.myData.fullName = this.myData.name;
        }
      }
    },

    fnSelect() {
      //console.log("select", this.al)
      this.myData.accessLevel = this.al.id;
    },

    validName() {
      if (!this.myData.name) return true;
      else if (this.myData.name.trim().length === 0) return true;
      return false;
    },

    // following method is REQUIRED
    // (don't change its name --> "show")
    show() {
      this.$refs["dialog"]["show"]();
    },

    // following method is REQUIRED
    // (don't change its name --> "hide")
    hide() {
      this.$refs["dialog"]["hide"]();
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
      let err = false
      const method = this.mode === "ins" ? "insert" : "update";
      this.myData.accessLevel =
        typeof this.al === "object" ? this.al.id : this.al;
      this.myData.lang = localStorage.getItem("curLang")
      api
        .post('', {
          method: this.act + "/" + method,
          params: [{rec: this.myData}],
        })
        .then(
          (response) => {
            err = false
            this.$emit("ok", response.data.result.records[0]);
            notifySuccess(this.$t("success"));
          },
          (error) => {
            //console.log("error.response.data=>>>", error.response.data.error.message)
            err = true
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
    api
      .post('', {
        method: "dict/load",
        params: [{dict: "FD_AccessLevel", lang: localStorage.getItem("curLang")}],
      })
      .then((response) => {
        this.options = response.data.result.records;
      });
  },
};
</script>
