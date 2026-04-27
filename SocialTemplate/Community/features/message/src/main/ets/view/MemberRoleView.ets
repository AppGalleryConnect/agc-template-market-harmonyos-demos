import { AppStorageV2 } from '@kit.ArkUI'
import { ChatBreakpoint, TValueTypes } from 'chat_window'
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight } from 'common'
import { CMChatFactory, CMChatGroupInfo, CMChatGroupMemberInfo } from 'instant_messaging'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { MemberRoleViewViewModel } from '../viewmodel/MemberRoleViewViewModel'
import { ChatSettingsViewModel } from '../viewmodel/ChatSettingsViewModel'

@Builder
export function MemberRoleViewPageBuilder(pames: TValueTypes) {
  MemberRoleView({ chatGroupInfo: pames as CMChatGroupInfo })
}

@ComponentV2
export struct MemberRoleView {
  @Param @Require chatGroupInfo: CMChatGroupInfo
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
      this.getGroupsInfo()
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param leftImageMargin: Length = this.chatBreakpoint.pagePadding;
  @Param fontWightParam: FontWeight | number = 700
  @Param isShowLeftImage: boolean = true;
  @Local memberRoleData: CMChatGroupMemberInfo [] = []
  @Local memberRoleViewViewModel: MemberRoleViewViewModel = new MemberRoleViewViewModel()
  @Local cmchatGroupInfo: CMChatGroupInfo = new CMChatGroupInfo()
  @Local chatSettingsViewModel: ChatSettingsViewModel = new ChatSettingsViewModel()

  aboutToAppear(): void {
    try {
      this.chatSettingsViewModel.groupId = this.chatGroupInfo.groupId;
    } catch (err) {
    }
  }

  async getGroupsInfo() {
    this.memberRoleData = []
    if (this.chatSettingsViewModel.groupId === '') {
      return;
    }
    let result = await CMChatFactory.instance.getGroupsInfo([this.chatSettingsViewModel.groupId]);
    this.cmchatGroupInfo.groupId = result[0].groupId;
    this.cmchatGroupInfo.groupName = result[0].groupName;
    this.cmchatGroupInfo.faceURL = result[0].faceURL;
    this.cmchatGroupInfo.role = result[0].role;
    this.cmchatGroupInfo.notification = result[0].notification;
    this.cmchatGroupInfo.introduction = result[0].introduction;
    this.cmchatGroupInfo.groupRemark = result[0].groupRemark;
    this.cmchatGroupInfo.groupMiRemark = result[0].groupMiRemark;
    try {
      this.cmchatGroupInfo.memberInfoList = await this.chatSettingsViewModel.getGroupMemberList();
    } catch (err) {
    }
    this.cmchatGroupInfo.owner = result[0].owner;
    for (let i = 0; i < this.cmchatGroupInfo.memberInfoList.length; i++) {
      if (this.cmchatGroupInfo.memberInfoList[i].role === 400) {
        this.memberRoleData.unshift((this.cmchatGroupInfo.memberInfoList[i]))
      } else if (this.cmchatGroupInfo.memberInfoList[i].role === 300) {
        this.memberRoleData.push((this.cmchatGroupInfo.memberInfoList[i]))
      }
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }

  @Builder
  render() {

    Blank().height(BarVM.instance.staBarH);

    CommonHeader({
      title: '群管理',
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    Column() {
      Text($r('app.string.group_rule'))
        .fontSize(18)
        .fontColor(Color.Black)
        .margin({ top: 30, bottom: 30 })
      Row() {
        Text($r('app.string.add_group_rule'))
          .textAlign(TextAlign.Start)
          .fontSize(18)
          .fontColor($r('app.color.color_66000000'))
          .margin({ top: 10, bottom: 20 })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.memberRoleData, (item: CMChatGroupMemberInfo) => {
          Column() {
            Image($r('app.media.' + item.avatarUrl))
              .width($r('app.float.vp_48'))
              .aspectRatio(1)
              .borderRadius($r('sys.float.corner_radius_level6'))
            Text(item.nickName)
              .width($r('app.float.vp_48'))
              .maxLines(1)
              .margin({ top: 4 })
              .textAlign(TextAlign.Center)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('app.color.color_66000000'))
              .fontSize(13)
          }
          .margin({
            top: 10,
            right: 4,
            left: 17,
            bottom: 10
          })
        }, (item: CMChatGroupMemberInfo) => JSON.stringify(item))
        Image($r('app.media.add_message'))
          .borderRadius($r('sys.float.corner_radius_level6'))
          .width($r('app.float.vp_48'))
          .aspectRatio(1)
          .padding($r('app.float.vp_14'))
          .margin({
            top: 10,
            right: 4,
            left: 17,
            bottom: 13
          })
          .backgroundColor($r('sys.color.comp_background_gray'))
          .onClick(() => {
            if (this.memberRoleData.length > 3) {
              this.memberRoleViewViewModel.noAddGroupMemberRole()
            } else {
              this.memberRoleViewViewModel.routerAddGroupMemberRole(this.cmchatGroupInfo)
            }

          })
        Image($r('app.media.delete_message'))
          .width($r('app.float.vp_48'))
          .aspectRatio(1)
          .padding($r('app.float.vp_14'))
          .margin({
            top: 10,
            right: 4,
            left: 17,
            bottom: 13
          })
          .backgroundColor($r('sys.color.comp_background_gray'))
          .borderRadius($r('sys.float.corner_radius_level6'))
          .onClick(() => {
            this.memberRoleViewViewModel.routerDeleteGroupMemberRole(this.cmchatGroupInfo)
          })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ top: 10, bottom: 30 })

      Button($r('app.string.disband_group'))
        .fontColor($r('sys.color.warning'))
        .width('100%')
        .backgroundColor(Color.White)
        .margin({
          top: 10,
          bottom: 10
        })
        .borderRadius(10)
        .onClick(() => {
          this.memberRoleViewViewModel.disbandGroup(this.chatGroupInfo.groupId)
        })
    }
    .width('100%')
    .padding({ left: this.leftImageMargin, right: this.leftImageMargin })

  }
}