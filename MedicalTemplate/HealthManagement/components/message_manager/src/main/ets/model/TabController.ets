import { MessageManagerService } from './MessageMangerService'

@ObservedV2
export class TabController {
  messageManagerService: MessageManagerService = MessageManagerService.instance;
  tabName: string;
  useMessageService: boolean = false;
  @Trace unReadCount: number = 0;

  @Monitor('messageManagerService.unReadCount')
  messageCountChange() {
    if (this.useMessageService) {
      this.unReadCount = this.messageManagerService.unReadCount;
    }
  }

  constructor(tabName: string, useMessageService?: boolean) {
    this.tabName = tabName;
    if (useMessageService !== undefined) {
      this.useMessageService = useMessageService;
      this.messageCountChange();
    }
  }

  public changeUnReadCount(count: number) {
    this.unReadCount = count;
  }
}