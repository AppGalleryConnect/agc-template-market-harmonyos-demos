import { PersistenceV2 } from '@kit.ArkUI'
import { CommonHeader, getMedia, RouterMap, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { OHPage, phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder } from 'aggregated_login'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { UserItem } from '../comp/UserItem'


/**
 * @usage: 个人中心主页面，提供用户信息管理和个人设置功能。包含用户信息编辑、隐私设置、反馈建议和应用更新等功能。
 * 主要数据结构包括UserInfo（用户信息）、MineItem（菜单项模型）。包含if逻辑判断用户登录状态和消息数量显示。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为用户信息卡片和功能菜单列表。
 * 用户信息卡片采用横向布局（Row），左侧头像右侧用户信息。功能菜单使用List组件垂直排列。
 * @constraints: 登录相关不可删除
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 个人中心主页面
 * @subPage: LoginPage,SetUpPage,FeedbackPage,EditPersonalCenter
 * @component: CommonHeader,OuterFrameCard,UserItem
 * @image: screenshot/person.jpg
 */
@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('意见反馈', $r('app.media.icon_feedback'), wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE)
  ]
  @Local onReturnClick: () => void = () => {
  }

  /**
   * 头像昵称组件
   */
  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin
        ? ((this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '')
          ? this.userInfo.avatarUrl
          : $r('app.media.path2x'))
        : $r('app.media.person'))
        .borderRadius($r('sys.float.corner_radius_level16'))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)

      Row() {
        Column() {
          Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '点击登录')
            .lineHeight($r('app.float.vp_24'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r('app.float.vp_16'), bottom: $r('app.float.vp_2') })

          if (this.userInfo?.isLogin) {
            Text(`ID：${this.userInfo?.id.toString().padStart(7, '0')}`)
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: $r('app.float.vp_16') })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.iconRight'))
          .width($r('app.float.vp_18'))
          .aspectRatio(1)
          .margin({ right: $r('app.float.vp_2') })
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
    .height($r('app.float.vp_72'))
    .padding($r('app.float.vp_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.person_mine_title'),
        onReturnClick: this.onReturnClick,
        backgroundColorParam: Color.Transparent,
        rowFlexAlign: FlexAlign.SpaceBetween,
      })

      Scroll() {
        Column({ space: 12 }) {
          this.perMine()
          Text($r('app.string.person_mine_normal_function'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_24'))
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_4') })
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
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.LOGIN_PAGE,
                        builder: wrapBuilder(LoginPageBuilder)
                      })
                    }
                  })
              }, (item: MineItem) => JSON.stringify(item))
            }
            .width('100%')
            .height('auto')
            .lanes(1)
            .borderRadius($r('sys.float.corner_radius_level8'))
            .backgroundColor($r('sys.color.comp_background_primary'))
            .divider({
              strokeWidth: '1px',
              color: $r('sys.color.comp_divider'),
              startMargin: $r('app.float.vp_12'),
              endMargin: $r('app.float.vp_12'),
            })
            .padding($r('app.float.vp_4'))
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          }
        }
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .layoutWeight(1)
    }
    .backgroundImage(getMedia('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .backgroundColor('#f2f3f5')
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }
}

@Builder
export function MinePageBuilder() {
  MinePage()
}


