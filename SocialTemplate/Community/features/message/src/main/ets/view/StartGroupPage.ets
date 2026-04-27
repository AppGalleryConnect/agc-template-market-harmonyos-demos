import { AppStorageV2 } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BreakpointModel, CommonHeader, TempBarHeight, TValueType } from 'common';
import { ContactSingleRow } from '../components/ContactSingleRow';
import { StartGroupChatRow } from '../components/StartGroupChatRow';
import { StartGroupModel } from '../viewmodel/StartGroupModel';
import { MessageContactModel } from '../viewmodel/MessageContactModel';

@Builder
export function StartGroupPageBuilder(valueVM: TValueType) {
  StartGroupPage({ valueVM: valueVM })
}

@ComponentV2
export struct StartGroupPage {
  @Param @Require valueVM: TValueType;
  @Local startGroupVM: StartGroupModel = new StartGroupModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onFriendClick: (friendVM: MessageContactModel) => void =
    (friendVM: MessageContactModel) => {
      this.startGroupVM.selectFriend(friendVM);
    }
  @Local onStartGroupChatClick: () => void = () => {
    this.startGroupVM.startGroupChat();
  }

  aboutToAppear(): void {
    try {
      let beforeId = this.valueVM as string;
      this.startGroupVM.beforeUserId = beforeId;
      this.startGroupVM.getStartGroupFriendList();
    } catch (err) {
    }
  }

  @Builder
  render() {
    CommonHeader({
      title: this.startGroupVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.startGroupVM.scroller }) {
        Repeat<MessageContactModel>(this.startGroupVM.friendList)
          .each((ri: RepeatItem<MessageContactModel>) => {
            ListItem() {
              ContactSingleRow({
                friendInfoVM: ri.item,
                onFriendClick: this.onFriendClick
              });
            }
          })
          .key((item: MessageContactModel, index: number): string => item.userId.toString() + index)
          .virtualScroll({
            totalCount: this.startGroupVM.friendList.length
          })
          .templateId((_friendInfoVM: MessageContactModel): string => {
            return '';
          })

        ListItem().height($r('app.float.vp_16'))
      }
      .height('100%')
      .width('100%')
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider')
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')

    StartGroupChatRow({
      onStartGroupChatClick: this.onStartGroupChatClick
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}


