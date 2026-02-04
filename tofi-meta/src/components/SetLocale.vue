<template>
  <q-select
    v-model="locale"
    :model-value="locale"
    :options="localeOptions"
    emit-value
    dense
    borderless
    map-options
    options-dense
    @update:model-value="
      () => {
        setLang(locale);
      }
    "
    hide-dropdown-icon
  >
    <template v-slot:selected-item="scope">
      <q-chip color="primary" text-color="white" dense>
        <q-avatar>
          <q-btn class="q-pa-none" round color="primary" dense icon="language">
            <q-tooltip transition-show="rotate" transition-hide="rotate">{{
                $t("chooseLanguage")
              }}
            </q-tooltip>
          </q-btn>
        </q-avatar>

        {{ scope.opt.value }}
      </q-chip>
    </template>
  </q-select>
</template>

<script>
import languages from "quasar/lang/index.json";
import {Quasar} from "quasar";
import {useI18n} from "vue-i18n";
import {useUserStore} from "stores/user-store.js";
import {storeToRefs} from "pinia";

let localeOptions

let infoStore = {id: 0, user: "", target: "", metamodel:""}

export default {

  methods: {
    setLang(e) {
      console.info("setLang", e)
      import(`../../node_modules/quasar/lang/${e}.js`).then((l) => {
        this.$q.lang.set(l.default);
        let curLang = l.default.isoName;
        //
        localStorage.setItem("curLang", curLang);
      }).then(() => {
        this.cpyStore()
        location.reload();
        this.restoreStore()
      })
    },

    cpyStore() {
      const store = useUserStore();
      const {getUserId, getUserName, getTarget, metamodel} = storeToRefs(store);
      infoStore.id = getUserId()
      infoStore.fullname = getUserName()
      infoStore.target = getTarget()
    },

    restoreStore() {
      const store = useUserStore();
      const { setUserStore } = store;
      setUserStore(infoStore)
    }

  },

  created() {
  },

  setup() {
    console.info("setup")
    const appLanguages = languages.filter((lang) =>
      ["kk", "ru", "en-US"].includes(lang.isoName)
    );
    localeOptions = appLanguages.map((lang) => ({
      label: lang.nativeName,
      value: lang.isoName,
    }));
    if (!localStorage.getItem("curLang")) localStorage.setItem("curLang", "ru");
    let curLang = localStorage.getItem("curLang");
    import(`../../node_modules/quasar/lang/${curLang}.js`).then((l) => {
      Quasar.lang.set(l.default);
    });
    const {locale} = useI18n({useScope: "global"});
    locale.value = curLang;

    return {
      locale,
      localeOptions,
    };
  },

};
</script>

<style scoped></style>
