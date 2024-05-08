import { ref } from 'vue'

export default function windowResize() {
  // * 指向最外层容器
  const screenRef = ref()
  const screenContainerRef = ref()
  // * 定时函数
  const timer = ref(0)
  // * 默认缩放值
  const scale = {
    width: '1',
    height: '1',
  }
  // * 设计稿尺寸（px）
  const baseWidth = 1920
  const baseHeight = 1080

  // * 需保持的比例（默认1.77778）
  const baseProportion = parseFloat((baseWidth / baseHeight).toFixed(5))
  const calcRate = () => {
    let width = screenContainerRef.value.offsetWidth
    let height = screenContainerRef.value.offsetHeight
    const fullScreen = screenContainerRef.value.dataset.screen

    if (fullScreen === 'true' || fullScreen === true) {
      width = window.innerWidth
      height = window.innerHeight
    }
    
    const widthPre = (width / baseWidth).toFixed(5)
    const heightPre = (height / baseHeight).toFixed(5)
    let pre = widthPre
    if (heightPre < widthPre) {
      pre = heightPre
    }
    // 当前宽高比
    const currentRate = parseFloat(
      (width / height).toFixed(5)
    )

    if (screenRef.value) {
      screenRef.value.style.transform = `scale(${ pre }, ${ pre })`
      // if (currentRate > baseProportion) {
      //   // 表示更宽
      //   scale.width = (
      //     (height * baseProportion)
      //     / baseWidth
      //   ).toFixed(5)
      //   scale.height = (height / baseHeight).toFixed(5)
      //   screenRef.value.style.transform = `scale(${scale.width}, ${scale.height})`
      // } else {
      //   // 表示更高
      //   scale.height = (
      //     width
      //     / baseProportion
      //     / baseHeight
      //   ).toFixed(5)
      //   scale.width = (width / baseWidth).toFixed(5)
      //   screenRef.value.style.transform = `scale(${scale.width}, ${scale.height})`
      // }
    }
  }

  const resize = () => {
    clearTimeout(timer.value)
    timer.value = window.setTimeout(() => {
      calcRate()
    }, 100)
  }

  // 改变窗口大小重新绘制
  const windowDraw = () => {
    window.addEventListener('resize', resize)
  }

  // 改变窗口大小重新绘制
  const unWindowDraw = () => {
    window.removeEventListener('resize', resize)
  }

  return {
    screenContainerRef,
    screenRef,
    calcRate,
    windowDraw,
    unWindowDraw,
  }
}
