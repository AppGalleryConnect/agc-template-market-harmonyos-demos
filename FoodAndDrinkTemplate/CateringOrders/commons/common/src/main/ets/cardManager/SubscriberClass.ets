import commonEventManager from '@ohos.commonEventManager'

class SubscriberClass {
  eventFormId = 'form_id'
  publishCount: number = 1
  subscriber?: commonEventManager.CommonEventSubscriber

  // 发布者
  publish(eventType: string, data: string) {
    // next中data支持导入类型
    commonEventManager.publish(eventType, { data }, (err) => {
      if (err) {
        // 失败只发3次
        if (this.publishCount <= 3) {
          this.publishCount++
          this.publish(eventType, data)
        } else {
          this.publishCount = 1
        }
      } else {
        this.publishCount = 1
      }
    })
  }

  // 订阅者
  subscribe(eventType: string, callback: (event?: string) => void) {
    commonEventManager.createSubscriber({ events: [eventType] }, (err, sub) => {
      if (err) {
        console.log('logData:', `创建订阅者error ${JSON.stringify(err)}`)
      }
      this.subscriber = sub
      if (this.subscriber !== null) {
        //订阅事件
        commonEventManager.subscribe(this.subscriber, (err, data) => {
          if (err) {
            console.error(`logData`, '订阅事件失败')
          }
          callback(data.data)
        })
      } else {
        console.error('logData:', `需要创建subscriber`);
      }
    })
  }
}
const subscriber = new SubscriberClass()
export { subscriber as Subscriber }