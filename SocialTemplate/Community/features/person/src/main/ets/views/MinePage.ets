import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { BarVM, BreakpointModel, RouterMap, TCLogger, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { MyCollectPageBuilder } from './MyCollectPage'
import { MineViewModel } from '../viewmodel/MineViewModel'
import { BlacklistListViewPageBuilder } from './BlacklistListViewPage'

@Builder
export function MinePageBuilder() {
  MinePage()
}

/**
 * @usage: 我的主页面 支持展示用户信息与常用入口（收藏、意见反馈、设置、黑名单管理、二维码）
 * @layout: 页面采用纵向布局，从上到下依次为：顶部渐变背景条、标题"我的"（左对齐）、个人信息卡片
 * （横向排列：左侧头像+昵称/手机号+右侧箭头图标）、消息通知设置列表（每行横向排列：左对齐文本+右对齐开关按钮）、
 * 功能入口列表（收藏/意见反馈/设置，每行横向排列：左对齐标题+右侧箭头）、黑名单管理（横向排列：左对齐文本+右侧箭头）、
 * 二维码入口（横向排列：左对齐文本+右侧箭头），所有卡片内容均左对齐，交互元素（箭头、开关）右对齐
 * @constraints: 登录态（userInfo.isLogin）控制所有功能入口访问权限（除设置页面外），用户信息（UserInfo）
 * 通过持久化存储管理不可随意修改，消息通知开关状态必须在登录后才能切换，路由跳转必须通过phoneRouterControl统一管理，
 * 顶部渐变背景、安全边距（BarVM.instance.staBarH）和分割线样式为固定UI规范不可更改
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 我的主页面
 * @subPage: EditPersonalCenter,ChatHistoryCollectionPage,FeedbackSubmitPage,SetUpPage,BlacklistListViewPage,QRCodePage
 * @component: UserItem
 * @image: screenshot/person_page.png
 */

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('收藏', undefined, wrapBuilder(MyCollectPageBuilder),
      RouterMap.MY_COLLECT_PAGE),
    new MineItem('意见反馈', undefined, wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', undefined, wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]
  @Local messageNotification: string[] = [
    '消息提示音',
    '消息振动提醒',
    '群消息振动提醒'
  ]
  mineViewModel: MineViewModel = new MineViewModel()

  aboutToAppear(): void {
    TCLogger.info(this.logTag, 'aboutToAppear ' + JSON.stringify(this.userInfo));
  }

  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? $r('app.media.' + this.userInfo.avatarUrl) :
        $r('app.media.path2x') :
      $r('app.media.person'))
        .borderRadius(40)
        .width(48)
        .aspectRatio(1)

      Row() {
        Column() {
          Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '点击登录')
            .height(24)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16, bottom: 2 })

          if (this.userInfo?.isLogin) {
            Text(`${this.userInfo?.telephone.toString().padStart(7, '0')}`)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: 16 })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.iconRight'))
          .width(18)
          .aspectRatio(1)
          .margin({ right: 2 })
      }
      .layoutWeight(1)
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        this.mineViewModel.isLoginMethod()
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PERSONAL_CENTER_PAGE,
          builder: wrapBuilder(EditPersonalCenterBuilder)
        })
      }
    })
    .width('100%')
    .height(72)
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }

  build() {
    Column() {
      Row()
        .width('100%')
        .height(104 + BarVM.instance.staBarH)
        .linearGradient({
          angle: 0,
          colors: [['#00b8d1fe', 0.0], ['#ffcfd2ff', 1.0]]
        }).position({top:0, left: 0})

      Scroll() {
        Column({ space: 12 }) {
          Row() {
            Text('我的')
              .fontSize($r('sys.float.Title_M'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .height(36)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          this.perMine()
          List() {
            ForEach(this.messageNotification, (item: string, index: number) => {
              this.messageNotificationView(item, index)
            }, (item: string, index: number) => item + '_' + index)
          }
          .width('100%')
          .height('auto')
          .lanes(1)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: 12,
            endMargin: 12,
          })
          .padding({
            left: 4,
            right: 4,
            top: 4,
            bottom: 4,
          })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

          OuterFrameCard() {
            List() {
              ForEach(this.mineArr, (item: MineItem, index: number) => {
                UserItem({
                  title: item.titleName,
                  image: item.icon,
                  url: item.url,
                  isLine: !(index === this.mineArr.length - 1),
                  messageNum: item.messageNum
                })
                  .onClick(() => {
                    // 设置多个点击
                    if (this.userInfo?.isLogin && item.url) {
                      phoneRouterControl.jumpPage({
                        pageName: item.url,
                        param: index === 1 ? ({ top: BarVM.instance.staBarH } as Padding) : item.params,
                        builder: item.builder
                      })
                    } else {
                      if (item.url && item.url === RouterMap.SET_UP_PAGE) {
                        // 设置页面不登录也可进入
                        phoneRouterControl.jumpPage({
                          pageName: item.url,
                          param: item.params,
                          builder: item.builder
                        })
                      } else {
                        // 非设置页面需要登录
                        this.mineViewModel.isLoginMethod()
                      }
                    }
                  })
              }, (item: MineItem) => JSON.stringify(item))
            }
            .width('100%')
            .height('auto')
            .lanes(1)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .divider({
              strokeWidth: 0.5,
              color: $r('sys.color.comp_divider'),
              startMargin: 12,
              endMargin: 12,
            })
            .padding({
              left: 4,
              right: 4,
              top: 4,
              bottom: 4,
            })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          }

          //黑名单列表调用
          this.blacklistLabelView()
          //二维码列表调用
          this.qrcodeView()
        }
      }
      .align(Alignment.TopStart)
      .padding({
        top: BarVM.instance.staBarH,
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5')
  }

  /**
   * 群通知列表布局
   * @param item
   * @param index
   */
  @Builder
  messageNotificationView(item: string, index: number) {
    ListItem() {
      Row() {
        Text(item)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Blank()
        if (index === 0) {
          Toggle({ type: ToggleType.Switch, isOn: $$this.userInfo.messageNotificationTone })
            .margin({ right: 16 })
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .onClick(() => {
              if (this.userInfo?.isLogin) {
                if (this.userInfo.messageNotificationTone) {
                  this.userInfo.messageNotificationTone = false
                } else {
                  this.userInfo.messageNotificationTone = true
                }
              } else {
                this.mineViewModel.isLoginMethod()
              }
            })
        } else if (index === 1) {
          Toggle({ type: ToggleType.Switch, isOn: $$this.userInfo.messageVibrationAlert })
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .margin({ right: 16 })
            .onClick(() => {
              if (this.userInfo?.isLogin) {
                if (this.userInfo.messageVibrationAlert) {
                  this.userInfo.messageVibrationAlert = false
                } else {
                  this.userInfo.messageVibrationAlert = true
                }
              } else {
                this.mineViewModel.isLoginMethod()
              }
            })
        } else {
          Toggle({ type: ToggleType.Switch, isOn: $$this.userInfo.groupMessageNotificationTone })
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .margin({ right: 16 })
            .onClick(() => {
              if (this.userInfo?.isLogin) {
                if (this.userInfo.groupMessageNotificationTone) {
                  this.userInfo.groupMessageNotificationTone = false
                } else {
                  this.userInfo.groupMessageNotificationTone = true
                }
              } else {
                this.mineViewModel.isLoginMethod()
              }
            })
        }

      }
      .width('100%')
      .margin({ left: 10, top: 10 })
      .justifyContent(FlexAlign.Start)
    }
    .padding({
      top: 5,
      bottom: 5,
      left: 8,
      right: 8,
    })
  }

  /**
   * 黑名单列表布局
   */
  @Builder
  blacklistLabelView() {
    Row() {
      Text($r('app.string.blacklist_management'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      Image($r('app.media.iconRight'))
        .size({ width: 18, height: 18 })
        .margin({ right: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      left: 20,
      right: 4,
      top: 22,
      bottom: 16,
    })
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.BLACKLIST_LIST_VIEW_PAGE,
          builder: wrapBuilder(BlacklistListViewPageBuilder)
        })
      } else {
        this.mineViewModel.isLoginMethod()
      }
    })
  }

  /**
   * 二维码列表
   */
  @Builder
  qrcodeView() {
    Row() {
      Text($r('app.string.qrcode'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      Image($r('app.media.iconRight'))
        .size({ width: 18, height: 18 })
        .margin({ right: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      left: 20,
      right: 4,
      top: 22,
      bottom: 16,
    })
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (this.userInfo?.isLogin) {
        this.mineViewModel.qrcodeViewMethod()
      } else {
        this.mineViewModel.isLoginMethod()
      }
    })
  }
}

