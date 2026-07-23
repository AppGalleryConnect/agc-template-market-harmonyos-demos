export interface PushModel {
  payload: Payload
  target: Record<string, string[]>
  pushOptions: Record<string, string | boolean>
}

export interface Payload {
  notification: Notification
}

export interface Notification {
  category: string
  title: string
  body: string
  badge: Record<string, number>
  clickAction: Record<string, number | string | Record<string, number | string  | ActionRecorder>>
  notifyId: number
}

export interface ActionRecorder {
  eventId: string,
}

export interface PushActionParams {
  eventId: string
}

export class PushMessageInfo {
  id:string = ''
  date:string = ''
  content:string = ''
  type:string = ''
}

/**
 * 推送卡片-跳转模型
 */
@ObservedV2
export class PushCardInfo {
  @Trace id: number = 0;
  @Trace eventId: string = '';
}
