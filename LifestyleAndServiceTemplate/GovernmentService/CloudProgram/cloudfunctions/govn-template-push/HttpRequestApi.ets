import { AxiosRequestHeaders } from 'axios';
import axiosClient from './AxiosRequest'

/**
 * push kit 推送请求体
 * @param date
 * @returns
 */
function pushMessageParams(pushToken:string) {
  return {
    "payload": {
      "notification": {
        "category": "MARKETING",
        "title": "欢迎使用政务模板",
        "body": "您可以尽情使用push kit为您带来的推送服务",
        "clickAction": {
          "actionType": 0
        },
        "notifyId": 12345
      }
    },
    "target": {
      "token": [pushToken ?? '']
    },
    "pushOptions": {
      "testMessage": true
    }
  }
}

/**
 * push kit 推送
 * @param date
 * @returns
 */
export function pushNotice(pushToken:string) {
  return axiosClient.post({
    url: 'https://push-api.cloud.huawei.com/v3/388421841222475582/messages:send',
    data: pushMessageParams(pushToken),
    showLoading: true,
    headers: { "Content-Type": "application/json", 'push-type': 0 } as ESObject
  })
}
