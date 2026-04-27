import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { AppStorageKeys, BreakpointModel, getMedia, RouterMap, StatusBarHeight, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder, LoginRedirectFlag } from './LoginPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { VipCenterPageBuilder } from './VipCenterPage'

/**
 * @usage: 个人中心主页面，提供用户信息管理和个人设置功能。包含用户信息展示、VIP会员卡片、意见反馈和设置入口。
 * 主要数据结构包括UserInfo（用户信息）、MineItem（菜单项模型）。包含if逻辑判断用户登录状态和VIP状态显示。
 * @layout: 页面采用Scroll滚动布局，内部Column垂直排列。顶部为标题Text，下方为用户信息卡片Row（头像Image和用户信息Column），
 * VIP会员卡片Row，常用服务列表OuterFrameCard包含UserItem列表项。
 * @constraints: 登录相关不可删除
 * @domain: 翻译工具
 * @fileType: page
 * @zhName: 个人中心主页面
 * @isGen: true
 * @subPage: LoginPage,SetUpPage,FeedbackPage,EditPersonalCenter,VipCenterPage
 * @component: UserItem,OuterFrameCard
 * @image: screenshot/person.jpg
 */
@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local statusBarHeight: StatusBarHeight =
    AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT, () => new StatusBarHeight())!;
  @Local mineArr: MineItem[] = [
    new MineItem('意见反馈',  wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]

  aboutToAppear(): void {
    // 如果未登录，确保VIP状态为false
    if (!this.userInfo.isLogin && this.userInfo.isVip) {
      this.userInfo.isVip = false;
    }
  }

  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl :
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
            Text(`ID：${this.userInfo?.id.toString().padStart(7, '0')}`)
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
        // 从我的页面登录，不需要跳转到VIP页面，重置标志
        const flag = AppStorageV2.connect(LoginRedirectFlag, () => new LoginRedirectFlag())!;
        flag.redirectToVip = false;
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      }else {
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

  @Builder
  vipCard() {
    Row() {
      Image($r('app.media.vip_logo'))
        .width(32)
        .height(32)
        .margin({ left: 12 })

      Text('尊享VIP')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FDDB9B')
        .margin({ left: 12 })

      Blank()

      if (this.userInfo.isVip) {
        // 已开通VIP
        Text('查看会员特权')
          .fontSize(14)
          .fontColor('#F5D061')
          .margin({ right: 16 })
      } else {
        // 未开通VIP
        Button('立即开通')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor('#F5D061')
          .borderRadius(20)
          .height(32)
          .padding({ left: 16, right: 16 })
          .margin({ right: 12 })
      }
    }
    .width('100%')
    .height(64)
    .backgroundColor('#1A1A1A')
    .borderRadius(16)
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.VIP_CENTER_PAGE,
          builder: wrapBuilder(VipCenterPageBuilder)
        })
      }
    })
  }

  build() {
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

        // VIP会员卡片
        this.vipCard()

        Text('常用服务')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 12, bottom: 4 })
          .width('100%')

        OuterFrameCard() {
          List() {
            ForEach(this.mineArr, (item: MineItem, index: number) => {
              UserItem({
                title: item.titleName,
                url: item.url,
                isLine: !(index === this.mineArr.length - 1),
                messageNum: item.messageNum
              })
                .onClick(() => {
                  // 设置多个点击
                  if (this.userInfo?.isLogin && item.url) {
                    phoneRouterControl.jumpPage({
                      pageName: item.url,
                      param: item.params,
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
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.LOGIN_PAGE,
                        builder: wrapBuilder(LoginPageBuilder)
                      })
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
        }
      }
    }
    .align(Alignment.TopStart)
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor('#f2f3f5')
    .padding({
      top: this.statusBarHeight.value,
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}

