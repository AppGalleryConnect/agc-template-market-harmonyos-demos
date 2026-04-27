import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, TValueTypes } from 'chat_window';
import { BreakpointModel, CommonHeader, TempBarHeight } from 'common';
import { CMChatFactory, CMChatGroupInfo, CMChatGroupMemberInfo, CMChatGroupMemberRole } from 'instant_messaging';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';

@Builder
export function DeleteGroupMemberRoleViewPageBuilder(param: TValueTypes) {
  DeleteGroupMemberRoleView({ chatGroupInfo: param as CMChatGroupInfo })
}

@ComponentV2
export struct DeleteGroupMemberRoleView {
  @Param @Require chatGroupInfo: CMChatGroupInfo
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
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
  @Local memberInfoData: CMChatGroupMemberInfo[] = []

  aboutToAppear(): void {
    for (let i = 0; i < this.chatGroupInfo.memberInfoList.length; i++) {
      if (this.chatGroupInfo.memberInfoList[i].role === 400 || this.chatGroupInfo.memberInfoList[i].role === 300) {
        this.memberRoleData.push(this.chatGroupInfo.memberInfoList[i])
      }
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig,
      useSafePadding: true,
      isFullScreen: true
    })
  }

  @Builder
  render() {
    CommonHeader({
      title: '删除管理员',
      onReturnClick: this.onReturnClick
    })

    List() {
      this.deleteGroupMemberRoleData()
    }
    .width('100%')
    .layoutWeight(1)
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider')
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    Button($r('app.string.delete_group_rule'))
      .fontColor($r('sys.color.warning'))
      .width('100%')
      .backgroundColor(Color.White)
      .margin({
        top: 10
      })
      .borderRadius(10)
      .onClick(() => {
        for (let i = 0; i < this.memberInfoData.length; i++) {
          if (this.memberRoleData[i].userId !== '') {
            CMChatFactory.instance.setGroupMemberRole(this.chatGroupInfo.groupId,
              this.memberInfoData[i].userId,
              CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_MEMBER)
            this.getUIContext().getPromptAction().showToast({
              message: '移除管理员成功'
            })
          }
          //完成后延迟释放
          setTimeout(() => {
            phoneRouterControl.popPage() // 延迟执行的释放函数
          }, 500); // 延迟到事件循环空闲时执行
        }
      })
  }

  @Builder
  deleteGroupMemberRoleData() {
    ForEach(this.memberRoleData, (item: CMChatGroupMemberInfo, index: number) => {
      ListItem() {
        Row() {
          if (item.role === 300) {
            Checkbox({ name: item.nickName, group: item.userId })
              .shape(CheckBoxShape.CIRCLE)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.memberInfoData.push(item)
                } else {
                  this.memberInfoData.slice(index, 1)
                }
              })
          } else if (item.role === 400) {
            Checkbox({ name: item.nickName, group: item.userId })
              .enabled(false)
              .select(false)
              .shape(CheckBoxShape.CIRCLE)
          }
          Image($r('app.media.' + item.avatarUrl))
            .width($r('app.float.vp_48'))
            .aspectRatio(1)
            .objectFit(ImageFit.Fill)
            .borderRadius($r('sys.float.corner_radius_level6'))
          Blank().width($r('app.float.vp_12'));
          Text(item.nickName)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_18'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
        }
      }
      .backgroundColor(Color.White)
      .width('100%')
      .height($r('app.float.vp_64'))
      .padding({
        top: $r('app.float.vp_8'),
        left: this.breakPointModel.pagePadding,
        bottom: $r('app.float.vp_8'),
        right: this.breakPointModel.pagePadding
      })
    }, (item: CMChatGroupMemberInfo) => JSON.stringify(item))
  }
}