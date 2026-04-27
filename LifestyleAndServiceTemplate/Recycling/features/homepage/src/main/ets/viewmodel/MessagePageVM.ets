@ObservedV2
export class MessagePageVM {
  // 模拟收到的消息
  @Trace messageList: Array<MessageItem> = [
    new MessageItem(
      new Date().getTime(),
      '距离奢侈品1折抢购结束，仅剩10小时',
      '倒计时开始！双十一奢品年度最大力度，千元红包+1折大牌+限量秒杀不止1折，错过今天再等一年。',
      '查看详情'
    ),
    new MessageItem(
      new Date().getTime() - 1000 * 60 * 60 * 12,
      '您有新的订单',
      '倒计时开始！双十一奢品年度最大力度，千元红包+1折大牌+限量秒杀不止1折，错过今天再等一年。',
      '查看详情'
    ),
    new MessageItem(
      new Date().getTime() - 1000 * 60 * 60 * 24,
      '您有新的订单',
      '倒计时开始！双十一奢品年度最大力度，千元红包+1折大牌+限量秒杀不止1折，错过今天再等一年。',
      '查看详情'
    )
  ]
}

/**
 * 消息类
 */
@ObservedV2
export class MessageItem {
  // 时间
  @Trace time: number = 0;
  // 标题
  @Trace title: string = '';
  // 简要内容
  @Trace simpleContent: string = ''
  // 提示标签
  @Trace tag: string = ''
  // 详细内容
  @Trace detailContent: string = ''

  constructor(time: number, title: string, simpleContent: string, tag: string) {
    this.time = time;
    this.title = title;
    this.simpleContent = simpleContent;
    this.tag = tag;
  }
}