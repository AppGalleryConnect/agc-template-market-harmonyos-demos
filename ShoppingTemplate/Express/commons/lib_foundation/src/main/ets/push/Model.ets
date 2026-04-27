
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
  image: string | undefined
  clickAction: Record<string, number | string | Record<string, number | string | ActionRecorder>>
  notifyId: number
}

export interface ActionRecorder {
  articleId: string,
  authorId: string
}

export interface PushActionParams {
  articleId: string
  authorId: string
}
