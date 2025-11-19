<template>
  <div class="q-pa-md q-gutter-sm">
    <h6 class="page-header text-weight-bolder">Заливка</h6>
    <hr style="margin-top: -50px" />
    <div class="q-pa-md q-gutter-sm q-pt-none">1. Обслуживаемые объекты и их свойства</div>

    <div class="row">
      <div class="col-9">
        <q-input
          v-model="file"
          :clearable="true"
          accept=".xlsx"
          autofocus
          dense
          type="file"
          @clear="clrFile"
          @update:model-value="updFile"
        />
      </div>
      <q-space></q-space>
      <div class="col-1 text-right">
        <q-btn
          :disable="!file || (file && errTest)"
          color="grey-4"
          icon="file_download"
          label="Залить"
          text-color="black"
          @click="fnGo"
        />
      </div>
    </div>

    <div v-if="file" class="q-pa-md q-gutter-sm">
      <div v-if="!isFill">
        <div v-if="errTest">
          <div>
            Проверка формата: <span class="text-red"> {{ logs[0].msg }} </span>
          </div>
          <div>Количество строк: {{ logs[0].cnt }}</div>
        </div>
        <div v-else>
          <div>Проверка формата: <span class="text-green"> Успешно </span></div>
          <div>Количество строк: {{ logs.length > 0 ? logs[0].cnt : '' }}</div>
        </div>
      </div>
      <div v-else>
        <div v-if="errFill">
          <div>Заливка данных: <span class="text-red"> Ошибка </span></div>
        </div>
        <div v-else>
          <div>Заливка данных: <span class="text-green"> Успешно </span></div>
        </div>
      </div>
    </div>

    <div>
      <q-inner-loading :showing="loading" color="secondary"></q-inner-loading>
    </div>

  </div>
</template>

<script>
import { ref } from 'vue'
import { baseURL } from 'boot/axios'

export default {
  name: 'FillPage',

  data() {
    return {
      file: ref(null),
      loading: false,
      logs: [],
      errTest: false,
      errFill: false,
      isFill: false,
      //
    }
  },

  methods: {
    fnGo() {
      this.toSrv(true)
    },

    clrFile() {
      this.file = ref(null)
      this.errTest = false
      this.errFill = false
      this.logs = []
    },

    updFile(val) {
      if (val !== null) {
        this.file = val[0]
        this.toSrv(false)
      }
    },

    toSrv(fill) {
      this.loading = true
      this.isFill = fill

      let fd = new FormData()
      fd.append('file', this.file)
      fd.append('filename', this.file.name)
      fd.append('fill', fill)

      this.$axios
        .post('/filldata', fd, {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        })
        .then(() => {
          if (fill) {
            this.errFill = false
          }
        })
        .then(() => {
          this.loading = true
          this.$axios
            .post(baseURL, {
              method: 'fill/loadLog',
              params: []
            })
            .then((response) => {
              this.logs = response.data.result.records
              this.errTest = this.logs[0].err === 1
            })
            .finally(() => {
              this.loading = false
            })
        })
        .catch(() => {
          if (fill) {
            this.errFill = true
          }
        })
        .finally(() => {
          this.loading = false
        })
    }
  }
}
</script>

<style scoped></style>
