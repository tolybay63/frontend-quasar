<template>
  <div class="q-pa-md q-gutter-sm">
    <h6 class="page-header text-weight-bolder">Заливка</h6>
    <hr style="margin-top: -50px" />
    <div class="q-pa-md q-gutter-sm q-pt-none">1. Обслуживаемые объекты и их свойства</div>

    <div class="row">
      <div class="col-9">
        <q-input
          v-model="file"
          :model-value="file"
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
          :disable="!file || err || (file && filled)"
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
        <div v-if="err">
          <div>
            Проверка формата: <span class="text-red"> {{ msg }} </span>
          </div>
          <div>Количество строк: {{ count }}/{{ countVal }}</div>
        </div>
        <div v-else>
          <div>Проверка формата: <span class="text-green"> {{ msg }} </span></div>
          <div>Количество объектов/свойства: {{ count }}/{{ countVal }}</div>
        </div>
      </div>
      <div v-else>
        <div v-if="err">
          <div>Заливка данных: <span class="text-red"> Ошибка </span></div>
          <div> {{ msg }}</div>
        </div>
        <div v-else>
          <div>Заливка данных: <span class="text-green"> {{msg}} </span></div>
          <div>Количество объектов/свойства: {{ count }}/{{ countVal }}</div>
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
      err: false,
      msg: "Успешно",
      count: 0,
      countVal: 0,

      isFill: false,
      filled: false
    }
  },

  methods: {
    fnGo() {
      this.toSrv(true)
    },

    clrFile() {
      this.file = ref(null)
      this.err = false
      this.msg = "Успешно"
      this.isFill = false
      this.filled = false

    },

    updFile(val) {
      this.err = false
      this.isFill = false
      this.filled = false
      this.msg = "Успешно"

      if (val && val.length > 0) {
        this.file = val[0]
        this.filled = false
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
          this.$axios
            .post(baseURL, {
              method: 'fill/loadLog',
              params: []
            })
            .then((response) => {
              let logs = response.data.result.records[0]
              this.err = logs["err"]===1
              this.count = logs["count"]
              this.countVal = logs["countval"]
              if (this.err)
                this.msg = logs["msg"]
            })
            .finally(() => {
              this.loading = false
            })
        })
        .catch((error) => {
          console.log(error.message)
        })
        .finally(() => {
          if (this.isFill) this.filled = true
          this.loading = false
        })
    }
  }
}
</script>

<style scoped></style>
