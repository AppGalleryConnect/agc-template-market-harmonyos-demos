
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

