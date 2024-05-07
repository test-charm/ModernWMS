<template>
  <div class="screen-header">
    <div class="screen-header-top-section">
      <dv-decoration-10 :color="['#45a1f1', '#000000']" class="dv-dec-10" :dur="10" />
      <div class="screen-header-title-section">
        <dv-decoration-8 :color="['#45a1f1', '#000000']" class="dv-dec-8" />
        <div class="title-section">
          <p class="header-title">ModernWms 大屏</p>
        </div>
        <dv-decoration-8 :color="['#45a1f1', '#000000']" class="dv-dec-8" :reverse="true" />
      </div>

      <dv-decoration-10 :color="['#45a1f1', '#000000']" class="dv-dec-10 dev-reverse" :reverse="true" :dur="10" />
    </div>
    <div class="screen-header-bottom-section">
      <div class="sub-dec-section">
        <dv-decoration-6 class="dv-dec-6" :reverse="true" :color="['#50e3c2', '#67a1e5']" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, onMounted, onUnmounted } from 'vue'
import { formatDate } from '@/utils/format/formatSystem'

const timeInfo = reactive({
  setInterval: 0,
  dateDay: '',
  dateYear: '',
  dateWeek: ''
})
const WEEK = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

onMounted(() => {
  handleTime()
})

onUnmounted(() => {
  clearInterval(timeInfo.setInterval)
})

const handleTime = () => {
  timeInfo.setInterval = window.setInterval(() => {
    const date = new Date()
    timeInfo.dateDay = formatDate(date, 'HH: mm: ss')
    timeInfo.dateYear = formatDate(date, 'yyyy-MM-dd')
    timeInfo.dateWeek = WEEK[date.getDay()]
  }, 1000)
}

const downloadHandler = (type: string) => {
  switch (type) {
    case 'github':
      window.open('https://github.com/dddggg123/vue3-big-screen.git')
      break
    case 'gitee':
      window.open('https://gitee.com/xiaoxiang_reincarnation/vue3-big-screen.git')
      break
  }
}
</script>

<style lang="less" scoped>
.screen-header {
  .screen-header-top-section {
    display: flex;
    align-items: center;

    .screen-header-title-section {
      width: 50%;
      display: flex;
      align-items: center;
      padding-top: 20px;

      .dv-dec-8 {
        width: 30%;
        height: 20px;
      }

      .title-section {
        width: 40%;
        text-align: center;
        .sub-dec-section {
          width: 20%;
          padding: 0 40px;

          .dv-dec-6 {
            height: 20px;
            margin-top: 15px;
          }
        }

        .header-title {
          background-color: transparent;
          font-size: 24px;
          font-weight: 550;
          background-image: linear-gradient(#fff, #45a1f1);
          background-clip: text;
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }
      }
    }

    .dv-dec-10 {
      width: 25%;
      height: 20px;
    }
  }

  .screen-header-bottom-section {
    display: flex;
    justify-content: center;
    .sub-dec-section {
      width: 20%;
      padding: 0 40px;

      .dv-dec-6 {
        height: 20px;
        // margin-top: 15px;
      }
    }
  }
}
.dev-reverse {
  transform: rotateY(180deg);
}
</style>
