import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, TValueTypes } from 'chat_window';
import { CMChatGroupInfo, CMChatGroupMemberInfo } from 'instant_messaging';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BreakpointModel, GroupProfileButton, TempBarHeight } from 'common';
import { MemberRoleViewViewModel } from '../viewmodel/MemberRoleViewViewModel';

@ComponentV2
export struct GroupIntroductionView {
  @Param @Require memberInfoList: CMChatGroupInfo
  controller: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controller };
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param leftImageMargin: Length = this.chatBreakpoint.pagePadding;
  @Param fontWightParam: FontWeight | number = 700
  @Param isShowLeftImage: boolean = true;
  @Local plainText: string = ''
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  memberRoleViewViewModel :MemberRoleViewViewModel = new MemberRoleViewViewModel()
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local onCompleteClick: () => void = () => {
    if(this.memberRoleViewViewModel.strOverByteLength(this.plainText)){
      this.getUIContext().getPromptAction().showToast({
        message: '修改失败，内容长度超出！',
        alignment:Alignment.Center
      })
      return
    }
    this.memberRoleViewViewModel.groupIntroduction(this.memberInfoList,this.plainText)
    if (this.onReturnClick) {
      //完成后延迟释放
      setTimeout(() => {
        this.onReturnClick?.() // 延迟执行的释放函数
      }, 500); // 延迟到事件循环空闲时执行
    }
  }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local cMChatGroupMemberInfo : CMChatGroupMemberInfo = new CMChatGroupMemberInfo()
  timestamp: number = Date.now();
  @Local currentTime: string = ''
  @Local year: number = 0
  @Local month: string = ''
  @Local day: string = ''
  @Local hour: number = 0
  @Local min: number = 0
  @Local sec: number = 0
  aboutToAppear(): void {
    this.memberInfoList.memberInfoList.forEach((item : CMChatGroupMemberInfo) => {
      if (item.role === 400){
        this.cMChatGroupMemberInfo = item
      }
    })
    // 转换为可读时间格式
    let date = new Date(this.timestamp);
    this.year = date.getFullYear();
    this.month = ('0' + (date.getMonth() + 1)).slice(-2);
    this.day = ('0' + date.getDate()).slice(-2);
    this.hour = date.getHours();
    this.min = date.getMinutes();
    this.sec = date.getSeconds();
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
    GroupProfileButton({
      titles: '群简介',
      onReturnClick : this.onReturnClick,
      memberInfoList :this.memberInfoList,
      onCompleteClick : this.onCompleteClick ,
    }) .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })

    if (this.memberInfoList.role === 400) {
      TextArea({ text: this.memberInfoList.introduction, placeholder: '请输入群简介' })
        .width('92%')
        .enabled(true)
        .margin({ left: 10, right: 10 ,top : 10 })
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.plainText = value; // 存储到状态变量
        })
    } else {
      Column(){
        Row(){
          Image($r('app.media.' + this.cMChatGroupMemberInfo.avatarUrl))
            .width(50)
            .height(50)
            .borderRadius(16)
          Column(){
            Text(this.cMChatGroupMemberInfo.nickName)
              .size({ height: $r('app.float.vp_16') })
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(this.fontWightParam)
              .fontColor($r('sys.color.font_primary'))
              .margin({bottom : 10 , left : 5})
              .textAlign(TextAlign.Start)
            Text(`${this.year}年${this.month }月${this.day}日${this.hour}时${this.min}分`)
              .fontSize(13)
              .fontColor($r('app.color.color_66000000'))
              .textAlign(TextAlign.Start)
              .margin({left : 10 , top : 10})
          }
          .alignItems(HorizontalAlign.Start)
          .margin({left :7})
        }.width('100%')
        .margin({bottom : 10 , top : 5 })
        TextArea({ text: this.memberInfoList.introduction, placeholder: '这个群主很懒什么都没留下' })
          .width('100%')
          .enabled(false)
          .backgroundColor(Color.White)
      }
      .width('92%')
      .enabled(false)
      .margin({ left: 10, right: 10 ,top : 10 })
    }
  }
}

@Builder
export function GroupIntroductionViewPageBuilder(pames: TValueTypes) {
  GroupIntroductionView({ memberInfoList: pames as CMChatGroupInfo })
}