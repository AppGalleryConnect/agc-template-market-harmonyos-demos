import { PersistenceV2 } from '@kit.ArkUI'
import { getMedia, RouterMap, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { OHPage, phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder } from './LoginPage'
import { VipCenterPageBuilder } from './VipCenterPage'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { UserItem } from '../comp/UserItem'
import { BarVM } from 'video_common'

/**
 * @usage: 用于展示个人中心页面。包含用户头像、昵称、ID信息展示，以及常用服务列表（VIP会员、意见反馈、设置）功能入口
 * @layout: 页面整体采用垂直布局（Column），顶部是用户信息卡片（perMine），
 * 下方是常用服务列表（OuterFrameCard + List），支持登录状态管理和页面跳转。
 * @constraints: userInfo.isLogin 控制登录状态显示；mineArr 存储服务列表数据；
 * phoneRouterControl.jumpPage 用于页面跳转
 * @zhName: 个人中心
 * @fileType: page
 * @isGen: true
 * @subPage: LoginPage, SetupPage, VipCenterPage
 * @image: screenshot/person.jpeg
 * @domain: 视频
 * @component: UserItem, OuterFrameCard, OHPage
 */
@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('VIP会员', $r('app.media.vip_icon'), wrapBuilder(VipCenterPageBuilder),
      RouterMap.VIPCENTER_PAGE),
    new MineItem('意见反馈', $r('app.media.icon_feedback'), wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE)
  ]

  aboutToAppear(): void {
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
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
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

  // 页面内容渲染
  @Builder
  render() {
    Scroll(){
      Column({ space: 12 }) {
        Row() {
          Text('我的')
            .size({ width: 328, height: 32 })
            .fontSize(20)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 12, bottom: 12 })
        }

        this.perMine()
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
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
      }
      .backgroundImage(getMedia('app.media.profile_background'))
      .backgroundImageSize(ImageSize.FILL)
      .backgroundColor('#f2f3f5')
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .align(Alignment.TopStart)
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
    })
  }
}

