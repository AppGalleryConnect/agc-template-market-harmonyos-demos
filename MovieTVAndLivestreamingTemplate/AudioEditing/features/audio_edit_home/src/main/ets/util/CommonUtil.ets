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
  // toPrecision(2) 会保留2位有效数字，这可能导致科学计数法，比如 480KB -> 4.8e+2KB
  // 改用 toFixed(2) 保留2位小数
  return `${tempSize.toFixed(2)}${format}`
}

export function parseSizeToNumber(formattedSize: string): number {
  if (!formattedSize) {
    return 0;
  }

  let value = 0;
  if (formattedSize.indexOf('KB') !== -1) {
    value = value * 1024;
  } else if (formattedSize.indexOf('MB') !== -1) {
    value = value * 1024 * 1024;
  }
  return value
}