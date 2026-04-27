import { NumbObj } from './MessageModel'

@ObservedV2
export class MineItem {
  @Trace titleName: string
  @Trace builder?: WrappedBuilder<[Object]>
  @Trace url?: string
  @Trace params?: NumbObj
  @Trace messageNum?: number

  constructor(titleName: string, builder?: WrappedBuilder<[Object]>, url?: string, params?: NumbObj,
    messageNum?: number) {
    this.titleName = titleName
    this.builder = builder
    this.url = url
    this.params = params
    this.messageNum = messageNum
  }
}