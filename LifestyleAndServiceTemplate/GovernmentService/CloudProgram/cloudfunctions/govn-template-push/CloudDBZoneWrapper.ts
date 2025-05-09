import { pushNotice } from './HttpRequestApi'

export class CloudDbZoneWrapper {
  async pushMessage(pushToken: string, logger) {
    //   推送消息
    pushNotice(pushToken).then((resp) => {
      return 'push success'
    }).catch((err) => {
      return 'push failed'
    })
  }
}