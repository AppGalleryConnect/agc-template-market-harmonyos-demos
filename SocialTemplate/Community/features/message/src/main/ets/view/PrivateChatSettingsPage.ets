import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { PrivateChatSettingModel } from '../viewmodel/PrivateChatSettingModel';
import { PrivateSettingAvatarRow } from '../components/PrivateSettingAvatarRow';
import { PrivateSettingTitleRow } from '../components/PrivateSettingTitleRow';
import { CMChatFactory } from 'instant_messaging';
import { PrivateChatSettingSingleEnum } from '../utils/MessageEnum';
import { PrivateChatSettingSingleModel } from '../viewmodel/PrivateChatSettingSingleModel';

@Builder
export function PrivateChatSettingsPageBuilder(valueVM: TValueType) {
  PrivateChatSettingsPage({ valueVM: valueVM })
}

@ComponentV2
export struct PrivateChatSettingsPage {
  @Param @Require valueVM: TValueType;
  @Local chatSettingsVM: PrivateChatSettingModel = new PrivateChatSettingModel();
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local onReturnClick: () => void = () => {
    if (this.chatSettingsVM.isFix) {
      phoneRouterControl.popPage({ popData: 'fixContact' });
    } else {
      phoneRouterControl.popPage();
    }
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: async () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = this.tempBarHeight.bottomTempValue;
      let result = await CMChatFactory.instance.checkFriend([this.chatSettingsVM.userId]);
      this.chatSettingsVM.isFriend = result[0]?.isFriend;
      this.chatSettingsVM.setPageData();
    },
    onBackPress: () => {
      this.onReturnClick();
      return true;
    }
  })
  @Local onAddGroupClick: () => void = () => {
    this.chatSettingsVM.gotoStartGroup();
  }
  @Local onContactAvatarClick: () => void = () => {
    this.chatSettingsVM.gotoContactAvatar();
  }
  @Local onSettingsClick: (settingVM: PrivateChatSettingSingleModel) => void =
    (settingVM: PrivateChatSettingSingleModel) => {
      this.chatSettingsVM.onSettingsClick(settingVM, this.context, this.getUIContext());
    }
  @Local onDeleteFriendClick: () => void = () => {
    this.chatSettingsVM.deleteFromFriendList();
  }
  @Local onToggleClick: (isOn: boolean) => void = (isOn: boolean) => {
    if (isOn) {
      this.chatSettingsVM.deleteFromBlackList();
    } else {
      this.chatSettingsVM.addToBlackList();
    }
  }

  aboutToAppear(): void {
    try {
      let vm = this.valueVM as PrivateChatSettingModel;
      this.chatSettingsVM.pageType = vm.pageType;
      this.chatSettingsVM.userId = vm.userId;
      this.chatSettingsVM.conversationID = vm.conversationID;
      this.chatSettingsVM.showName = vm.showName;
    } catch (err) {
    }

    this.chatSettingsVM.getBlackList();
  }

  @Builder
  render() {
    CommonHeader({
      title: this.chatSettingsVM.pageTitle,
      onReturnClick: this.onReturnClick
    })

    Column() {
      List() {
        Repeat<PrivateChatSettingSingleModel>(this.chatSettingsVM.pageData)
          .each((ri: RepeatItem<PrivateChatSettingSingleModel>) => {
            ListItem() {
              if (ri.item.type === PrivateChatSettingSingleEnum.AVATAR) {
                PrivateSettingAvatarRow({
                  settingVM: ri.item,
                  onAddGroupClick: this.onAddGroupClick,
                  onContactAvatarClick: this.onContactAvatarClick
                })
              } else if (ri.item.type === PrivateChatSettingSingleEnum.TITLE ||
                ri.item.type === PrivateChatSettingSingleEnum.SWITCH) {
                PrivateSettingTitleRow({
                  settingVM: ri.item,
                  onSettingsClick: this.onSettingsClick,
                  isBlackList: this.chatSettingsVM.isBlackList,
                  onToggleClick: this.onToggleClick
                });
              } else if (ri.item.type === PrivateChatSettingSingleEnum.GROUP) {
                Text(ri.item.title)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('app.color.color_99000000'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)
                  .width('100%')
                  .height(ri.item.height)
              } else if (ri.item.type === PrivateChatSettingSingleEnum.BUTTON) {
                Text(ri.item.title)
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor('#E84026')
                  .backgroundColor(Color.White)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height(ri.item.height)
                  .borderRadius($r('app.float.vp_12'))
                  .onClick(() => this.onDeleteFriendClick())
              } else {
                Row().height(ri.item.height);
              }
            }
          })
          .key((item: PrivateChatSettingSingleModel): string => item.keyId)
          .virtualScroll({
            totalCount: this.chatSettingsVM.pageData.length
          })
          .templateId((_groupInfoVM: PrivateChatSettingSingleModel): string => {
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
      useSafePadding: true,
      pageConfig: this.pageConfig
    })
  }
}


