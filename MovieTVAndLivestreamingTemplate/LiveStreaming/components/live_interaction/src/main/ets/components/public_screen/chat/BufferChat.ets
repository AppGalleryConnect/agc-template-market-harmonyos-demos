import { BaseChatMessage } from './BaseChatMesage';
import { IChatManager } from './IChatManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[BufferChat]'

export class BufferChat {
  timer: number = 0
  chatMgr: IChatManager
  updateBufferTime = 400;
  bufferList: BaseChatMessage[] = []

  addChat(chat: BaseChatMessage) {
    this.bufferList.push(chat)

  }

  constructor(chatMgr: IChatManager, updateBufferTime: number) {
    this.updateBufferTime = updateBufferTime;
    this.chatMgr = chatMgr
  }

  setUpdateTime(interval: number) {
    if (this.timer) {
      clearInterval(this.timer)
      this.play()
    }
    this.updateBufferTime = interval
  }

  play() {
    this.timer = setInterval(() => {
      this.run();
    }, this.updateBufferTime)
  }

  stop() {
    clearInterval(this.timer)
  }

  run() {
    hilog.debug(0x000, TAG, 'run')
    if (this.chatMgr !== null && this.bufferList.length !== 0) {
      hilog.debug(0x000, TAG, 'updateChatView')
      this.chatMgr.updateChatView(this.bufferList)
      this.bufferList = []
    }
  }

  release() {
    this.bufferList = []
  }
}