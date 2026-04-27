import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { MineViewModel } from '../viewmodel/MineViewModel';
import { CMChatFriendInfo } from 'instant_messaging';

/**
 * @usage: 黑名单管理页（查看、勾选、移除）
 * @layout: 页面采用纵向布局：顶部是标题栏"黑名单管理"（左对齐带返回按钮），中间列表区域纵向排列黑名单项
 * （每项内部横向排列左对齐包含复选框、头像、昵称文本），底部是删除按钮（全宽居中，仅在有选中项时显示）
 * @constraints: 组件使用 @Local userInfo 和 @Local breakPointModel 通过持久化连接不可直接替换实例，
 * mineViewModel 和 onReturnClick 在初始化后不可修改
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 黑名单管理页
 * @subPage:
 * @component: OHPage,CommonHeader
 * @image: screenshot/person/person_blacklist.png
 */

/**
 * 黑名单列表页面
 */
@ComponentV2
export struct BlacklistListViewPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  mineViewModel: MineViewModel = new MineViewModel()
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  aboutToAppear(): void {
    this.mineViewModel.getBlackLists()
  }

  @Local userId: string[] = []
  @Local nickName: string[] = []

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.comp_background_gray')
    })
  }

  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.blacklist_management'),
      onReturnClick: this.onReturnClick
    })
    List() {
      ForEach(this.mineViewModel.cMChatFriendInfo, (item: CMChatFriendInfo, index: number) => {
        this.getBlackListsView(item, index)
      }, (item: CMChatFriendInfo) => JSON.stringify(item))
    }
    .layoutWeight(1)
    .width('100%')
    .height('80%')
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider')
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    if (this.userId.length > 0) {
      Row() {
        Text($r('app.string.delete'))
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor('#564AF7')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height($r('app.float.vp_46'))
          .borderRadius($r('sys.float.corner_radius_level6'))
          .onClick(async () => {
            //移除黑名单
            await this.mineViewModel.deleteFromBlackList(this.userId, this.nickName)
            this.userId.length = 0
          })
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .height(BarVM.instance.aiBarH)
      .padding({
        top: $r('app.float.vp_12'),
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    }
  }

  @Builder
  getBlackListsView(item: CMChatFriendInfo, index: number) {
    Row() {
      Checkbox({ name: item.nickName, group: item.userId })
        .shape(CheckBoxShape.CIRCLE)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.userId.push(item.userId)
            this.nickName.push(item.nickName)
          } else {
            if (this.userInfo) {
              this.userId.forEach((itemtow: string, indextow: number) => {
                if (itemtow === item.userId) {
                  this.userId.splice(indextow, 1)
                  this.nickName.splice(indextow, 1)
                }
              })
            }
          }
        })
      Blank().width($r('app.float.vp_12'));
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
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .padding({
      top: $r('app.float.vp_8'),
      left: this.breakPointModel.pagePadding,
      bottom: $r('app.float.vp_8'),
      right: this.breakPointModel.pagePadding
    })
  }
}

@Builder
export function BlacklistListViewPageBuilder() {
  BlacklistListViewPage()
}
