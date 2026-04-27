import { BreakpointModel } from 'common';
import { CardData, MessageItem, MessageManagerService, TabController, } from 'message_manager';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class MessageCenterVM {
  navPathStack: NavPathStack = new NavPathStack();
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace currentIndex: number = 0;
  messageManagerService: MessageManagerService = MessageManagerService.instance;
  tabList: TabController[] = [
    new TabController('新职位发布'),
    new TabController('推送消息', true),
    new TabController('消息样式')
  ]
  swiperController: SwiperController = new SwiperController();
  messageList: MessageItem[] = this.messageManagerService.getMessageList();
  newJobList: CardData[] = this.messageManagerService.getJobDataList();
  cardList: CardData[] = this.messageManagerService.getCardDataList()
}