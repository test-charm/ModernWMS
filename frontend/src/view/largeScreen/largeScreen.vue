<template>
  <div id="container" ref="screenContainerRef" :data-screen="fullScreen" class="screen-container" :class="{ 'screen-container-full': fullScreen }">
    <div class="screenfullbtn">
      <v-btn icon variant="text" @click="toggleFullScreen">
        <v-tooltip activator="parent" location="bottom">{{ $t('system.page.fullScreen') }}</v-tooltip>
        <v-icon :icon="`mdi-arrow-${fullScreen ? 'collapse' : 'expand'}`" color="white"></v-icon>
      </v-btn>
    </div>
    <div ref="screenRef" class="screen-content" :class="{ 'screen-content-full': fullScreen }">
      <div v-if="loading" class="mask flex-c">
        <dv-loading>
          <span class="loading-title">加载中...</span>
        </dv-loading>
      </div>
      <div class="header-section">
        <ScreenHeader></ScreenHeader>
      </div>
      <div class="screen-chart-section1">
        <dv-border-box-12>
          <ScreenTopLeft></ScreenTopLeft>
        </dv-border-box-12>
        <dv-border-box-8 :dur="10">
          <ScreenTopCenter></ScreenTopCenter>
        </dv-border-box-8>
        <dv-border-box-13>
          <ScreenTopRight></ScreenTopRight>
        </dv-border-box-13>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import screenfull from 'screenfull'
import windowResize from '@/utils/largeScreenResize'
import ScreenHeader from './ScreenHeader.vue'
import ScreenTopLeft from './ScreenTopLeft.vue'
import ScreenTopCenter from './ScreenTopCenter.vue'
import ScreenTopRight from './ScreenTopRight.vue'

const { screenContainerRef, screenRef, calcRate, windowDraw, unWindowDraw } = windowResize()
const loading = ref(true)
onMounted(() => {
  // 监听浏览器窗口尺寸变化
  windowDraw()
  calcRate()
  setTimeout(() => {
    loading.value = false
  }, 2000)
})

onUnmounted(() => {
  unWindowDraw()
})
const fullScreen = ref(false)
const toggleFullScreen = () => {
  if (screenfull.isEnabled) {
    // const container = document.getElementById('container')
    // screenfull.toggle(container!)
    fullScreen.value = !fullScreen.value
  }
}
</script>
<style lang="less" scoped>
.screen-container {
  // z-index: 999;
  // position: absolute;
  // left: 0px;
  // right: 0px;
  // width: 100vw;
  // height: 100vh;
  width: 100%;
  height: 100%;
  background-color: #020308;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  .mask {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    background-color: #020308;
    z-index: 9999;
    background-image: url('@/assets/img/home_bg.png');
  }
  .screenfullbtn {
    position: absolute;
    top: 10px;
    right: 10px;
    z-index: 10;
    display: flex;
    align-items: center;
    padding: 5px;
    border-radius: 4px;
  }
  .screen-content {
    width: 1428px;
    height: 851px;
    // width: 100%;
    // height: 100%;
    box-sizing: border-box;
    padding: 12px;
    background-image: url('@/assets/img/home_bg.png');
    transition: all 0.2s ease-in-out;

    .loading-title {
      font-size: 16px;
      color: #fff;
      margin-top: 10px;
    }

    .screen-chart-section1 {
      margin-top: 10px;
      display: grid;
      grid-template-columns: 2fr 2fr 2fr;
      grid-column-gap: 5px;
    }

    .screen-chart-section2 {
      margin-top: 5px;
      display: grid;
      grid-template-columns: 5fr 5fr;
      grid-column-gap: 5px;
    }
  }
  .screen-content-full {
    width: 1920px !important;
    height: 1080px !important;
  }
}
.screen-container-full {
  z-index: 999;
  position: absolute;
  left: 0px;
  top: 0px;
  width: 100vw;
  height: 100vh;
}
</style>
