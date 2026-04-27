import { TValueType } from 'common'

@ObservedV2
export class MineItem {
  @Trace titleName: string
  @Trace icon: ResourceStr
  @Trace builder?: WrappedBuilder<[Object]>
  @Trace url?: string
  @Trace params?: TValueType
  @Trace messageNum?: number

  constructor(
    titleName: string,
    icon: ResourceStr,
    builder?: WrappedBuilder<[Object]>,
    url?: string,
    params?: TValueType,
    messageNum?: number
  ) {
    this.titleName = titleName
    this.icon = icon
    this.builder = builder
    this.url = url
    this.params = params
    this.messageNum = messageNum
  }
}