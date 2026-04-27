// 辅助函数：pushPathByName 的替代实现
export function pushPathByName(
  stack: NavPathStack | null,
  name: string,
  param?: string | object,
  onComplete?: (popInfo?: PopInfo) => void,
  animated?: boolean
): void {
  if (!stack) {
    return
  }
  try {
    const pathInfo: NavPathInfo = {
      name: name,
      param: typeof param === 'string' ? param : (param ? JSON.stringify(param) : ''),
      onPop: onComplete
    }
    stack.pushPath(pathInfo, animated !== false)
  } catch (e) {
  }
}