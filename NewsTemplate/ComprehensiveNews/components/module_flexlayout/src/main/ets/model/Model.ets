import { NodeControllerFactory } from '../factory/NativeNodeFactory'
import { JSONObject, LayoutSetting } from './CommonModel'

export class FrameNodeParams {
  viewLayout: LayoutSetting
  articles: JSONObject[]
  extraInfo?: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]>
  style: Record<string, string | number>
  nodeControllerFactory?: NodeControllerFactory

  constructor(viewLayout: LayoutSetting, articles: JSONObject[], style: Record<string, string | number>,
    extraInfo?: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]>,
    nodeControllerFactory?: NodeControllerFactory) {
    this.viewLayout = viewLayout
    this.articles = articles
    this.style = style
    this.extraInfo = extraInfo
    this.nodeControllerFactory = nodeControllerFactory
  }
}

/**
 * 断点名称
 */
export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
}
