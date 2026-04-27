import { CardData, cardDataList, MessageItem, messDataList } from './model';
import { promptAction } from '@kit.ArkUI';

const TOAST_TIME = 1500;
const CARD_CONTENT = '这是一段正文内容这是一段正文内容这是一段正文内容这是一段正文内容这是一段正文内容这是这是一段正文内容这是一段正文内容这是一段正文内容这是一段正文内容这是一段正文内容这是';

@ObservedV2
export class MessageManagerService {
  @Trace messageList: MessageItem[] = messDataList;
  @Trace cardList: CardData[] = cardDataList
  @Trace unReadCount: number = 0;
  static _instance: MessageManagerService;
  static get instance() {
    if (!MessageManagerService._instance) {
      MessageManagerService._instance = new MessageManagerService();
      MessageManagerService._instance.messageList = messDataList;
      MessageManagerService._instance.updateUnReadCount();
    }
    return MessageManagerService._instance;
  }

  /**
   * 更新未读消息数量
   */
  updateUnReadCount() {
    let count = 0;
    this.messageList.forEach((item: MessageItem) => {
      if (!item.hasRead) {
        count ++;
      }
    })
    this.unReadCount = count;
  }



  /**
   * 删除全部消息
   */
  deleteAll() {
    this.messageList = [];
    this.updateUnReadCount();
  }

  /**
   * 删除单条数据
   * @param id
   */
  deleteById(id: string) {
    const index = this.messageList.findIndex((item: MessageItem) => item.id === id);
    this.messageList.splice(index, 1);
    this.updateUnReadCount();
  }

  /**
   * 全部设置已读
   */
  setReadAll() {
    const willRead = this.messageList.filter((item:MessageItem) => !item.hasRead)
    if (willRead.length > 0) {
      willRead.forEach((item: MessageItem) => {item.read()});
      promptAction.showToast({
        message:'操作成功',
        duration: TOAST_TIME,
      })
    } else {
      promptAction.showToast({
        message:'暂无未读消息',
        duration: TOAST_TIME,
      })
    }

    this.updateUnReadCount();
  }

  /**
   * 单条设置已读
   * @param id
   */
  setReadById(id: string) {
    const message = this.messageList.find((item: MessageItem) => item.id === id);
    message?.read();
    this.updateUnReadCount();
  }

  /**
   * 获取消息列表
   * @returns
   */
  getMessageList():MessageItem[] {
    return this.messageList
  }


  /**
   * 获取新发布职位
   * @returns
   */
  getJobDataList(): CardData[] {
    return this.cardList;
  }

  getCardDataList():CardData[] {
    return [
      new CardData('样式一标题', CARD_CONTENT , '14:24', 'XXXXXXXXX', ['标签一', '标签二', '标签三']),
      new CardData('样式二标题', CARD_CONTENT , '06/25 14:24', 'XXXXXXXXX'),
      new CardData('样式三标题', CARD_CONTENT , '昨天 14:24', 'XXXXXXXXX'),
    ]
  }

}