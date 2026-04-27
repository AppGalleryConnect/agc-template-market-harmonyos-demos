import { display } from '@kit.ArkUI'

export function getFormatSize(size: number) {
  if (!size) {
    return '0KB'
  }
  let tempSize = size / 1024 //转成KB
  let format = 'KB'
  if (tempSize > 1024) {
    tempSize = tempSize / 1024 //在转成MB
    format = 'MB'
  }
  return `${tempSize.toPrecision(2)}${format}`
}

export function parsePath(src: string, index: number) {
  let arr = src.split('/')
  let lastStr = arr[arr.length - 1]
  let lastTemp = lastStr.split('.')
  return lastTemp[index]
}

export function formatDuration(ms: number) {
  if (!ms) {
    return '00:00:00'
  }
  // 处理异常值（负数转为0）
  const totalSeconds = Math.floor(Math.max(ms, 0) / 1000);

  // 计算小时、分钟、秒
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  // 补零（确保每位为2位数）
  const pad = (num: number) => num.toString().padStart(2, '0');

  return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
}

export function decodeUnicodeToChinese(str: string) {
  if (typeof str !== 'string') {
    return str;
  } // 非字符串直接返回
  return decodeURIComponent(str)
}

export function getDisplayWidthOfVp() {
  return px2vp(display.getDefaultDisplaySync().width)
}
//节流
export function throttle(func: Function, interval = 500) {
  let time = 0;
  return () => {
    const nowTime = Date.now();
    const remainTime = interval - (nowTime - time);
    if (remainTime <= 0) {
      time = nowTime;
      func();
    }
  };
}