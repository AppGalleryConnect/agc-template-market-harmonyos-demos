import { TValueType } from '../../../constant/Constants'

/**
 * window参数
 */
export interface WindowParam {
  /** 自定义view */
  builder: WrappedBuilder<WindowParam[]>
  /** 业务参数 */
  attachParam: TValueType
  aboutToAppear?: (windowName: string) => void
  aboutToDisappear?: (windowName: string) => void
  onBackPress?: (windowName: string) => void
  /* window名称，若业务不传入，默认随机uuid */
  name?: string
  /*对齐方式*/
  align?: Alignment
  /* 背景显示蒙层 */
  showMask?: boolean
  /* 空白处自动、返回键取消弹框 */
  autoCancel?: boolean
  /** 自动隐藏 */
  autoHideCallBack?: Function
  /* window操作事件 */
  event?: WindowEvent
}

/* 操作事件 */
interface WindowEvent {
  show: Function
  hide: Function
  remove: Function
}