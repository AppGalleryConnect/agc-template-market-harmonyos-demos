export class BaseChatMessage {
  type: number
  content: string

  constructor(type: number, content: string) {
    this.type = type
    this.content = content
  }
}