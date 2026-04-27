import { RouterMap } from 'common'

@ObservedV2
export class MessageItem {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace title: string
  @Trace subtitle: string
  @Trace time: string
  @Trace isDelete: boolean = false
  @Trace url: string = ''
  @Trace count: number = 0

  constructor(id: string, icon: ResourceStr, title: string, subtitle: string, time: string, isDelete: boolean,
    count: number,
    url: string) {
    this.id = id
    this.icon = icon
    this.title = title
    this.subtitle = subtitle
    this.time = time
    this.isDelete = isDelete
    this.url = url
    this.count = count
  }
}

// 存储消息中心数据
@ObservedV2
export class NumbObj {
  @Trace listArr: MessageItem[] = [
    new MessageItem('11', $r('app.media.icon_envelope'), '系统消息', '用户协议及隐私政策更新通知', '3分钟前', false, 4,
      RouterMap.SYS_MESSAGE_PAGE)
  ]

  get totalUnreadCount(): number {
    return this.listArr.reduce((sum, item) => sum + item.count, 0);
  }
}
