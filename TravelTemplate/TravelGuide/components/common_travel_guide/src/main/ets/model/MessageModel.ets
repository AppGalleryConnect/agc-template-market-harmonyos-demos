export enum MessageType {
  ORDER = 'order',
  SYSTEM = 'system'
}

@ObservedV2
export class MessageItem {
  @Trace id: string
  @Trace title: string
  @Trace time: string
  @Trace content: string
  @Trace type: MessageType = MessageType.ORDER

  constructor(id: string, title: string, time: string, content: string) {
    this.id = id
    this.title = title
    this.time = time
    this.content = content
  }
}

// 消息列表
@ObservedV2
export class MyMessageList {
  @Trace list: MessageItem[] = []

  add(data: MessageItem) {
    this.list.unshift(data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.id !== id)
  }
}