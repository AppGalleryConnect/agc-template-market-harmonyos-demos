import { AppStorageV2 } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { CreateGroupFromOldGroupModel } from '../viewmodel/CreateGroupFromOldGroupModel';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight, TValueType } from 'common';
import { ContactSingleRow } from '../components/ContactSingleRow';
import { StartGroupChatRow } from '../components/StartGroupChatRow';
import { MessageContactModel } from '../viewmodel/MessageContactModel';
import { MessageGroupInfoModel } from '../viewmodel/MessageGroupInfoModel';

@Builder
export function CreateGroupFromOldGroupPageBuilder(valueVM: TValueType) {
  CreateGroupFromOldGroupPage({ valueVM: valueVM })
}

@ComponentV2
export struct CreateGroupFromOldGroupPage {
  @Param @Require valueVM: TValueType;
  @Local createGroupVM: CreateGroupFromOldGroupModel = new CreateGroupFromOldGroupModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage();
  }
  @Local rightOnClick: () => void = () => {
    this.createGroupVM.selectAllContact();
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onFriendClick: (friendInfoVM: MessageContactModel) => void =
    (friendInfoVM: MessageContactModel) => {
      this.createGroupVM.selectContact(friendInfoVM);
    }
  @Local onStartGroupChatClick: () => void = () => {
    this.createGroupVM.startGroupChat();
  }

  aboutToAppear(): void {
    try {
      this.createGroupVM.groupInfoVM = this.valueVM as MessageGroupInfoModel;
      this.createGroupVM.getGroupMemberList();
    } catch (err) {
    }
    this.createGroupVM.pageTitle = this.createGroupVM.groupInfoVM?.groupName ?? '创建群聊';
  }

  @Builder
  render() {
    CommonHeader({
      title: this.createGroupVM.pageTitle,
      onReturnClick: this.onReturnClick,
      rightTitle: '全选',
      rightOnClick: this.rightOnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.createGroupVM.scroller }) {
        Repeat<MessageContactModel>(this.createGroupVM.contactList)
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
            totalCount: this.createGroupVM.contactList.length
          })
          .templateId((_friendInfoVM: MessageContactModel): string => {
            return '';
          })
      }
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider')
      })
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')
    .padding({
      bottom: this.createGroupVM.isShowBottom ? $r('app.float.vp_12') : BarVM.instance.aiBarH
    })

    StartGroupChatRow({
      onStartGroupChatClick: this.onStartGroupChatClick
    })
      .visibility(this.createGroupVM.isShowBottom ? Visibility.Visible : Visibility.None)
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

