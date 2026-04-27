import { BaseChatMessage } from './BaseChatMesage';
import { BufferChat } from './BufferChat';
import { ChatDataSource } from './ChatDataSource';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatViewVM } from './ChatViewVM';
import { IChatManager } from './IChatManager';

const TAG = '[ChatManager]'
@ObservedV2
export class ChatManager implements IChatManager {
  SCROLL_ITEM_NUM: number = 10;
  MAX_CHAT_NUM = 100;
  BUFFER_TIME = 400;
  updateBufferTime: number = this.BUFFER_TIME
  bufferChat: BufferChat | null = null
  bufferTime: number = this.BUFFER_TIME

  scroller: Scroller | null = null
  @Trace vm: ChatViewVM = new ChatViewVM()
  @Trace dataSource: ChatDataSource = this.vm.dataSource
  constructor() {
    this.bufferChat = new BufferChat(this, this.updateBufferTime)
  }

  setScroller(scroller: Scroller) {
    this.scroller = scroller
  }
  getVM():ChatViewVM{
    return this.vm
  }

  public addSystemMessage(chat: BaseChatMessage) {
    if (this.bufferChat) {
      this.bufferChat.addChat(chat)
    }
  }

  public addNormalChatMessage(chat: BaseChatMessage) {
    if (this.bufferChat) {
      this.bufferChat.addChat(chat)
    }
  }

  updateChatView(bufferList: BaseChatMessage[]) {
    hilog.info(0x0000, TAG, 'updateChatView:' + bufferList.length)
    let isAtBottom: boolean = this.isAtBottom();
    if (!isAtBottom) {
      this.showNewsView()
      this.dataSource.addDataList(bufferList);
      this.removeOverItems();
    } else {
      this.dataSource.addDataList(bufferList);
      this.removeOverItems();
      this.runToBottom();
    }
  }

  isAtBottom(): boolean {
    let ret: boolean = true;
    if (this.scroller) {
      ret = this.scroller.isAtEnd()
    }
    return ret
  }

  runToBottom() {
    this.scroller?.scrollEdge(Edge.Bottom)
    this.hideNewsView()
  }

  showNewsView() {
    if (this.vm) {
      this.vm.isShowTips = true;
    }
  }

  hideNewsView() {
    if (this.vm) {
      this.vm.isShowTips = false;
    }
  }

  removeOverItems() {
    let dataSize: number = this.getDataSize();
    if (dataSize > this.MAX_CHAT_NUM) {
      let overSize = dataSize - this.MAX_CHAT_NUM;
      this.dataSource.removeData(0, overSize);
    }
  }

  getDataSize(): number {
    return this.dataSource.totalCount() - 1;
  }

  setBufferTime(bufferTime: number) {
    if (bufferTime < 0) {
      bufferTime = this.BUFFER_TIME;
    }
    this.bufferTime = bufferTime;
  }

  play() {
    this.bufferChat?.play()
  }

  stop(){
    this.bufferChat?.stop()
  }
}