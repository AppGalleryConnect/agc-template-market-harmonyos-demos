import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { MessageChatModel } from '../viewmodel/MessageChatModel';
import { CMChatFactory, CMChatGroupInfo, CMChatGroupMemberInfo } from 'instant_messaging';
import { ChatBreakpoint } from 'chat_window';
import { ChatSettingsViewModel } from '../viewmodel/ChatSettingsViewModel';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight, TValueType, UserInfo } from 'common';
import { ChatBackgroundSkillUtil } from '../utils/ChatBackgroundSkillUtil';

/**
 * 聊天设置页面
 */
@ComponentV2
export struct ChatSettings {
  @Param @Require valueVM: TValueType;
  @Local chatSettingsViewModel: ChatSettingsViewModel = new ChatSettingsViewModel()
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param leftImageMargin: Length = this.chatBreakpoint.pagePadding;
  @Param fontWightParam: FontWeight | number = 700
  @Param isShowLeftImage: boolean = true;
  @Local recordData: string[] = ['查找聊天记录', '设置当前聊天背景', '删除聊天记录']
  @Local messageChatVM: MessageChatModel = new MessageChatModel(this.getUIContext());
  @Local isOn: boolean = false
  @Local chatGroupInfo: CMChatGroupInfo = new CMChatGroupInfo()
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
      this.getGroupsInfo()
    },
    onBackPress: () => {
      this.onReturnClick();
      return true;
    }
  })
  @Local onReturnClick: () => void = () => {
    if (this.chatSettingsViewModel.isFix) {
      phoneRouterControl.popPage({ popData: 'fixContact' });
    } else {
      phoneRouterControl.popPage();
    }
  }
  @Local memberInfoData: CMChatGroupMemberInfo [] = []
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local chatBackgroundSkillUtil: ChatBackgroundSkillUtil = new ChatBackgroundSkillUtil()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    try {
      let vm = this.valueVM as ChatSettingsViewModel;
      this.chatSettingsViewModel.groupId = vm.groupId;
      this.chatSettingsViewModel.conversationID = vm.conversationID;
    } catch (err) {
    }
  }

  async getGroupsInfo() {
    this.memberInfoData = []
    if (this.chatSettingsViewModel.groupId === '') {
      return;
    }
    let result = await CMChatFactory.instance.getGroupsInfo([this.chatSettingsViewModel.groupId]);
    this.chatGroupInfo.groupId = result[0].groupId;
    this.chatGroupInfo.groupName = result[0].groupName;
    this.chatGroupInfo.faceURL = result[0].faceURL;
    this.chatGroupInfo.role = result[0].role;
    this.chatGroupInfo.notification = result[0].notification;
    this.chatGroupInfo.introduction = result[0].introduction;
    this.chatGroupInfo.groupRemark = result[0].groupRemark;
    this.chatGroupInfo.groupMiRemark = result[0].groupMiRemark;
    try {
      this.chatGroupInfo.memberInfoList = await this.chatSettingsViewModel.getGroupMemberList();
    } catch (err) {
    }
    this.chatGroupInfo.owner = result[0].owner;
    for (let i = 0; i < this.chatGroupInfo.memberInfoList.length; i++) {
      if (this.chatGroupInfo.memberInfoList[i].role === 400) {
        this.memberInfoData.unshift((this.chatGroupInfo.memberInfoList[i]))
      } else {
        this.memberInfoData.push((this.chatGroupInfo.memberInfoList[i]))
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
    Blank().height(this.chatBreakpoint.topValue);
    CommonHeader({
      title: '群聊设置',
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
      })

    Scroll() {
      Column() {
        Text('群聊成员')
          .fontSize(14)
          .fontColor($r('app.color.color_99000000'))
          .margin({ top: 20 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.memberInfoData, (item: CMChatGroupMemberInfo) => {
            Column() {
              Image($r('app.media.' + item.avatarUrl))
                .width($r('app.float.vp_48'))
                .aspectRatio(1)
                .borderRadius($r('sys.float.corner_radius_level6'))
              Text(item.nickName)
                .width($r('app.float.vp_48'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor($r('app.color.color_66000000'))
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .margin({ top: 4 })
            }
            .margin({
              top: 10,
              right: 4,
              left: 17,
              bottom: 10
            })
          }, (item: CMChatGroupMemberInfo) => JSON.stringify(item))
          Image($r('app.media.add_message'))
            .width($r('app.float.vp_48'))
            .aspectRatio(1)
            .borderRadius($r('sys.float.corner_radius_level6'))
            .padding($r('app.float.vp_14'))
            .margin({
              top: 10,
              right: 4,
              left: 17,
              bottom: 13
            })
            .backgroundColor($r('sys.color.comp_background_gray'))
            .onClick(() => {
              this.chatSettingsViewModel.addGroupMember(this.chatGroupInfo)
            })
          if (this.chatGroupInfo.role === 400) {
            Image($r('app.media.delete_message'))
              .width($r('app.float.vp_48'))
              .aspectRatio(1)
              .borderRadius($r('sys.float.corner_radius_level6'))
              .padding($r('app.float.vp_14'))
              .margin({
                top: 10,
                right: 4,
                left: 17,
                bottom: 13
              })
              .backgroundColor($r('sys.color.comp_background_gray'))
              .onClick(() => {
                this.chatSettingsViewModel.deleteGroupMember(this.chatGroupInfo)
              })
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ top: 10, bottom: 10 })

        this.ManageView()
        this.MiName()
        List() {
          this.RecordView()
        }
        .width('100%')
        .borderRadius(16)
        .backgroundColor(Color.White)
        .margin({ top: 5 })
        .scrollBar(BarState.Off)

        if (this.chatGroupInfo.role !== 400) {
          Button($r('app.string.delete_group_chat'))
            .fontColor($r('sys.color.warning'))
            .width('100%')
            .backgroundColor(Color.White)
            .margin({
              top: 10,
              bottom: 10
            })
            .borderRadius(10)
            .onClick(() => {
              this.chatSettingsViewModel.quitGroupData(this.chatGroupInfo.groupId)
              //完成后延迟释放
              setTimeout(() => {
                this.getGroupsInfo() // 延迟执行的释放函数
              }, 500); // 延迟到事件循环空闲时执行

            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.leftImageMargin, right: this.leftImageMargin })
    }
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    Blank().height(BarVM.instance.aiBarH)
  }

  @Builder
  ManageView() {
    Column() {
      if (this.chatGroupInfo.role === 400 || this.chatGroupInfo.role === 300) {
        Row() {
          Text('群头像')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
          Blank()
          Image(this.chatGroupInfo.faceURL ? this.chatGroupInfo.faceURL : $r('app.media.no_faceurl'))
            .size({ width: 18, height: 18 })
            .margin({ right: 10 })
            .borderRadius(360)
          Image($r('app.media.next_image'))
            .size({ width: 18, height: 18 })
            .margin({
              left: 6,
              top: 19,
              bottom: 19,
              right: 16
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          this.chatSettingsViewModel.setfaceURL(this.chatGroupInfo, this.context)
        })
      }
      Row() {
        Text('群聊名称')
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({
            left: 16,
            top: 19,
            bottom: 19,
            right: 16
          })
        Blank()
        Text(this.chatGroupInfo.groupName)
          .fontColor($r('app.color.color_66000000'))
          .width('40%')
          .margin({
            right: 10
          })
          .maxLines(1)

          .fontSize(16)
          .textAlign(TextAlign.End)
        Image($r('app.media.next_image'))
          .size({ width: 18, height: 18 })
          .margin({
            left: 6,
            top: 19,
            bottom: 19,
            right: 16
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        if (this.chatGroupInfo.role === 400 || this.chatGroupInfo.role === 300) {
          this.chatSettingsViewModel.groupNameView(this.chatGroupInfo)
        }
      })

      Column() {
        Row() {
          Text('群公告')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
          Blank()
          Image($r('app.media.next_image'))
            .size({ width: 18, height: 18 })
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Text(this.chatGroupInfo.notification)
          .fontSize(13)
          .width('92%')
          .margin({ left: 10, right: 10 })
          .fontColor($r('app.color.color_66000000'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.chatSettingsViewModel.bulletinView(this.chatGroupInfo)
      })

      Column() {
        Row() {
          Text('群简介')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
          Blank()
          Image($r('app.media.next_image'))
            .size({ width: 18, height: 18 })
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Text(this.chatGroupInfo.introduction)
          .fontSize(13)
          .width('92%')
          .margin({ left: 10, right: 10 })
          .fontColor($r('app.color.color_66000000'))
      }
      .width('100%')
      .onClick(() => {
        this.chatSettingsViewModel.groupIntroductionView(this.chatGroupInfo)
      })

      Row() {
        Text('群备注')
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({
            left: 16,
            top: 19,
            bottom: 19,
            right: 16
          })
        Blank()
        Text(this.chatGroupInfo.groupRemark)
          .fontColor($r('app.color.color_66000000'))
          .fontSize(16)
          .width('40%')
          .margin({
            right: 6
          })
          .maxLines(1)
          .textAlign(TextAlign.End)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Image($r('app.media.next_image'))
          .size({ width: 18, height: 18 })
          .margin({
            left: 10,
            top: 19,
            bottom: 19,
            right: 16
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        if (this.chatGroupInfo.role === 400) {
          this.chatSettingsViewModel.groupNotesNameView(this.chatGroupInfo)
        }
      })

      if (this.chatGroupInfo.role === 400) {
        Row() {
          Text('群管理')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
          Blank()
          Image($r('app.media.next_image'))
            .size({ width: 18, height: 18 })
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          if (this.chatGroupInfo.role === 400) {
            this.chatSettingsViewModel.groupMemberRoleView(this.chatGroupInfo)
          }
        })
      }

    }
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 10 })
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  MiName() {
    Row() {
      Text('我在本群昵称')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({
          left: 16,
          top: 19,
          bottom: 19,
          right: 16
        })
      Blank()
      Text(this.chatGroupInfo.groupMiRemark ? this.chatGroupInfo.groupMiRemark : this.userInfo.nickName)
        .fontColor($r('app.color.color_66000000'))
        .fontSize(16)
        .width('40%')
        .textAlign(TextAlign.End)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Image($r('app.media.next_image'))
        .size({ width: 18, height: 18 })
        .margin({
          left: 16,
          top: 19,
          bottom: 19,
          right: 16
        })
    }
    .width('100%')
    .margin({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.Start)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .onClick(() => {
      if (this.chatGroupInfo.role === 400) {
        this.chatSettingsViewModel.miNameView(this.chatGroupInfo, this.userInfo)
      }
    })
  }

  @Builder
  RecordView() {
    ForEach(this.recordData, (item: string) => {
      ListItem() {
        Row() {
          Text(item)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ left: 16, top: 19, bottom: 19 })
          Blank()
          Image($r('app.media.next_image'))
            .size({ width: 18, height: 18 })
            .margin({
              left: 16,
              top: 19,
              bottom: 19,
              right: 16
            })
        }
        .width('100%')
      }
      .backgroundColor(Color.White)
      .onClick(() => {
        if (item === '查找聊天记录') {
          this.chatSettingsViewModel.chatHistorySearch(undefined, this.chatSettingsViewModel.groupId)
        } else if (item === '设置当前聊天背景') {
          this.chatBackgroundSkillUtil.chatBackgroundSkill(this.context, this.getUIContext())
        } else if (item === '删除聊天记录') {
          this.chatSettingsViewModel.deleteImConversation(this.chatSettingsViewModel.conversationID)
        }
      })
    }, (item: string) => JSON.stringify(item))
  }
}

@Builder
export function ChatSettingsPageBuilder(valueVM: TValueType) {
  ChatSettings({ valueVM: valueVM })
}