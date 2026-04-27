import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight, TValueType } from 'common';
import { GroupSingleRow } from '../components/GroupSingleRow';
import { CMChatGroupInfo } from 'instant_messaging';
import { SearchContactRow } from '../components/SearchContactRow';
import { ForwardChatModel } from '../viewmodel/ForwardChatModel';
import { ChatContentSingleModel, ChatConversationType } from 'chat_window';
import { RelayDialogModel } from '../model/RelayDialogModel';
import { relayDialogBuilder } from '../components/relayui/RelayDialogBuilder';
import { SearchContactModel } from '../viewmodel/SearchContactModel';
import { MessageGroupInfoModel } from '../viewmodel/MessageGroupInfoModel';

@Builder
export function ForwardChatPageBuilder(valueVM: TValueType) {
  ForwardChatPage({ valueVM: valueVM })
}

@ComponentV2
export struct ForwardChatPage {
  @Param @Require valueVM: TValueType;
  @Local forwardChatVM: ForwardChatModel = new ForwardChatModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  relayDialogModel: RelayDialogModel = new RelayDialogModel()
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onGroupClick: (groupInfoVM: CMChatGroupInfo) => void =
    (groupInfoVM: CMChatGroupInfo) => {
      this.relayDialogModel.groupInfoVM = groupInfoVM
      this.relayDialogModel.type = 2
      this.openDialog(this.forwardChatVM.chatModel)
    }
  @Local onContactClick: (contactVM: SearchContactModel) => void =
    (contactVM: SearchContactModel) => {
      this.relayDialogModel.type = 1
      this.relayDialogModel.contactVM = contactVM
      this.openDialog(this.forwardChatVM.chatModel)
    }

  //打开弹窗
  openDialog(chatVM: ChatContentSingleModel) {
    this.relayDialogModel.chatVM = chatVM

    const contentNode: ComponentContent<Object> =
      new ComponentContent(this.getUIContext(), wrapBuilder(relayDialogBuilder), this.relayDialogModel);
    this.relayDialogModel.initDialog(this.getUIContext(), contentNode)
    this.relayDialogModel.openDialog()
  }

  cancelCallBack = () => {
    this.relayDialogModel.closeDialog()
  }
  sureCallBack = () => {
    if (this.relayDialogModel.type === ChatConversationType.CHAT_GROUP) {
      this.forwardChatVM.selectGroupOrContact(this.relayDialogModel.groupInfoVM?.groupId, undefined);
    }
    if (this.relayDialogModel.type === ChatConversationType.CHAT_C2C) {
      this.forwardChatVM.selectGroupOrContact(undefined, this.relayDialogModel.contactVM?.userId);
    }
    this.relayDialogModel.closeDialog()
  }

  aboutToAppear(): void {
    try {
      let vm = this.valueVM as ChatContentSingleModel;
      this.forwardChatVM.chatModel = vm;
      this.forwardChatVM.init();
      this.relayDialogModel.cancelCallBack = this.cancelCallBack;
      this.relayDialogModel.sureCallBack = this.sureCallBack;
    } catch (err) {
    }
  }

  @Builder
  render() {
    CommonHeader({
      title: this.forwardChatVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.forwardChatVM.scroller }) {
        Repeat<MessageGroupInfoModel>(this.forwardChatVM.groupList)
          .each((ri: RepeatItem<MessageGroupInfoModel>) => {
            ListItem() {
              GroupSingleRow({
                groupInfoVM: ri.item,
                onGroupClick: this.onGroupClick
              });
            }
          })
          .key((item: MessageGroupInfoModel, index: number): string => item.groupId.toString() + index)
          .virtualScroll({
            totalCount: this.forwardChatVM.groupList.length
          })
          .templateId((_groupInfoVM: MessageGroupInfoModel): string => {
            return '';
          })

        Repeat<SearchContactModel>(this.forwardChatVM.contactList)
          .each((ri: RepeatItem<SearchContactModel>) => {
            ListItem() {
              SearchContactRow({
                contactVM: ri.item,
                onContactClick: this.onContactClick
              });
            }
          })
          .key((item: SearchContactModel, index: number): string => item.userId.toString() + index)
          .virtualScroll({
            totalCount: this.forwardChatVM.contactList.length
          })
          .templateId((_friendInfoVM: SearchContactModel): string => {
            return '';
          })

        ListItem().height(BarVM.instance.aiBarH)
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')
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


