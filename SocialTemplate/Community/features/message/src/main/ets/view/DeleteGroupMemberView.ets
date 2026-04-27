import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, TValueTypes } from 'chat_window';
import { BreakpointModel, CommonHeader, TempBarHeight } from 'common';
import { CMChatGroupInfo, CMChatGroupMemberInfo } from 'instant_messaging';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { MemberRoleViewViewModel } from '../viewmodel/MemberRoleViewViewModel';

@Builder
export function DeleteGroupMemberViewPageBuilder(pames: TValueTypes) {
  DeleteGroupMemberView({ chatGroupInfo: pames as CMChatGroupInfo })
}

@ComponentV2
export struct DeleteGroupMemberView {
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
  memberRoleViewViewModel: MemberRoleViewViewModel = new MemberRoleViewViewModel()
  @Local memberInfoData: string[] = []

  aboutToAppear(): void {
    for (let i = 0; i < this.chatGroupInfo.memberInfoList.length; i++) {
      if (this.chatGroupInfo.role === 400) {
        if (this.chatGroupInfo.memberInfoList[i].role !== 400) {
          this.memberRoleData.push(this.chatGroupInfo.memberInfoList[i])
        }
      } else if (this.chatGroupInfo.role === 300) {
        if (this.chatGroupInfo.memberInfoList[i].role !== 400 || this.chatGroupInfo.memberInfoList[i].role !== 300) {
          this.memberRoleData.push(this.chatGroupInfo.memberInfoList[i])
        }
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
      title: '移除群成员',
      onReturnClick: this.onReturnClick
    })

    List() {
      this.deleteGroupMemberData()
    }
    .width('100%')
    .layoutWeight(1)
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider')
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    Button($r('app.string.delete_group_member'))
      .fontColor($r('sys.color.warning'))
      .width('100%')
      .backgroundColor(Color.White)
      .margin({
        top: 10
      })
      .borderRadius(10)
      .onClick(() => {
        if (this.memberInfoData.length > 0) {
          this.memberRoleViewViewModel.deleteGroupMember(this.chatGroupInfo.groupId, this.memberInfoData, '', 0)
          //完成后延迟释放
          setTimeout(() => {
            phoneRouterControl.popPage() // 延迟执行的释放函数
          }, 500); // 延迟到事件循环空闲时执行
        }
      })
  }

  @Builder
  deleteGroupMemberData() {
    ForEach(this.memberRoleData, (item: CMChatGroupMemberInfo, index: number) => {
      ListItem() {
        Row() {
          Checkbox({ name: item.nickName, group: item.userId })
            .shape(CheckBoxShape.CIRCLE)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.memberInfoData.push(item.userId)
              } else {
                this.memberRoleData.slice(index, 1)
              }
            })
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
    }, (item : CMChatGroupMemberInfo) => JSON.stringify(item))
  }
}