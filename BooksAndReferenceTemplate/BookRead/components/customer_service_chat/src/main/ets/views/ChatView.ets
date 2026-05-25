import { BaseChatItem } from '../components/BaseChatItem';
import { Constants } from '../common/Constant';
import { ChatInput } from '../components/ChatInput';
import { AvatarInfo, AvatarParam, FeatureItemConfig, FeatureSwitch } from '../models/DataModels';
import { MessageModel, SenderType } from '../models/MessageModel';
import { ChatVM } from '../viewmodels/ChatVM';
import { GridRowColSetting } from '../common/GridRowColSetting';

@ComponentV2
export struct ChatView {
  @Param serviceAvatarInfo: AvatarInfo = new AvatarInfo()
  @Param userAvatarInfo: AvatarInfo = new AvatarInfo()
  @Param avatarParam: AvatarParam = {}
  @Param placeHolder: ResourceStr = '请输入'
  @Param featureSwitch: FeatureSwitch = {}
  @Param additionalFeatureItems: FeatureItemConfig[] = [];
  @Event onChatAvatarClick: (senderType: SenderType) => void = () => {
  }
  @Local vm: ChatVM = ChatVM.getInstance()

  async aboutToAppear() {
    this.vm.windowModel.init(this.getUIContext());
    this.vm.windowModel.registerWindowBottomPadding();
    this.vm.windowModel.registerKeyboardListener(this.vm.onKeyBoardCB);
    await this.vm.initializeService();
  }

  aboutToDisappear() {
    this.vm.closeAll();
    this.vm.currentService.disconnect();
    this.vm.windowModel.unRegisterWindowBottomPadding();
    this.vm.windowModel.unRegisterKeyboardListener(this.vm.onKeyBoardCB);
  }

  build() {
    Column() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
        }) {
          // 消息列表
          Refresh({ refreshing: $$this.vm.isRefreshing }) {
            List({ space: Constants.SPACE_M, scroller: this.vm.scrollController }) {
              Repeat(this.vm.messageList)
                .each((message: RepeatItem<MessageModel>) => {
                  ListItem() {
                    BaseChatItem({
                      message: message.item,
                      avatarInfo: message.item.sender === SenderType.USER ? this.userAvatarInfo :
                        this.serviceAvatarInfo,
                      avatarParam: this.avatarParam,
                      onChatAvatarClick: this.onChatAvatarClick,
                    })
                  }
                })
                .key((message: MessageModel) => JSON.stringify(message.id))
                .virtualScroll({ totalCount: this.vm.messageList.length })
            }
            .scrollBar(BarState.Off)
            .width(Constants.FULL_PERCENT)
            .margin({ bottom: Constants.PADDING_XL })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          }
          .layoutWeight(1)
          .padding({
            left: GridRowColSetting.getPageMargin(this.vm.breakpoint),
            right: GridRowColSetting.getPageMargin(this.vm.breakpoint),
          })
          .onRefreshing(() => {
            this.vm.loadHistoryMessage();
          })
        }
      }
      .layoutWeight(1)
      .onSizeChange((_, newSize) => {
        this.vm.containerWidth = newSize.width as number;
        this.vm.calculateWidth();
      })
      .onBreakpointChange((bp) => {
        this.vm.breakpoint = bp;
      })
      .onClick(() => {
        this.vm.closeAll();
      })

      // 输入区域
      ChatInput({
        placeHolder: this.placeHolder,
        featureSwitch: this.featureSwitch,
        additionalFeatureItems: this.additionalFeatureItems,
      })
    }
    .width(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
  }
}
