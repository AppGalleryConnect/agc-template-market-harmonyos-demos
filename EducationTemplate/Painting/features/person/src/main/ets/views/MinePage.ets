import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { BreakpointModel, Constants, getMedia, RouterMap, UserInfo } from 'common'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenter'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder } from './LoginPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { MineItem } from '../viewmodel/MineModel'

@Builder
export function MinePageBuilder() {
  MinePage()
}

/**
 * @usage: 个人中心首页，展示用户信息卡片和功能入口列表（个人信息、意见反馈、设置），未登录用户点击功能入口会跳转到登录页。
 * @layout: 页面采用垂直滚动布局（Scroll + Column），顶部为标题行（Row），下方为用户信息卡片（Row 横向布局，左侧头像，
 * 右侧昵称和 ID 垂直排列），底部为功能列表（OuterFrameCard 包裹 List，每个 UserItem 横向排列）。
 * @constraints: mineArr 数组定义了功能入口，可根据需求增减，但每个 MineItem 必须包含 titleName、icon、builder、url 属性。
 * userInfo.isLogin 状态判断逻辑不可修改。设置页面（SET_UP_PAGE）的免登录访问逻辑不可删除。
 * @isGen: true
 * @fileType: page
 * @zhName: 个人中心首页
 * @domain: 绘画
 * @subPage: LoginPage,EditPersonalCenter,SetUpPage,FeedbackPage
 * @image: screenshots/person.jpg
 * @component: UserItem,OuterFrameCard
 */
@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('个人信息', $r('app.media.icon_personInfo'), wrapBuilder(EditPersonalCenterBuilder),
      RouterMap.PERSONAL_CENTER_PAGE),
    new MineItem('意见反馈', $r('app.media.icon_message'), wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE),
  ]

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

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text('我的')
            .fontSize($r('app.float.vp_26'))
            .width(Constants.FULL_SIZE)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
        }
        .padding({
          top: $r('app.float.vp_12'),
          bottom: $r('app.float.vp_12')
        })

        this.perMine()

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
        }
      }
    }
    .align(Alignment.TopStart)
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor('#f2f3f5')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}

