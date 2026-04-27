/**
 * @usage: 个人中心页面,作为个人中心模块的一级页面,展示用户信息、VIP会员状态,
 * 提供个人信息编辑、VIP会员中心、设置等功能入口。支持登录/未登录状态展示、VIP等级显示、
 * 快速跳转到各功能页面。未登录用户点击需要登录的功能时会引导至登录页面,设置页面不登录也可进入。
 * @layout: 页面采用Scroll滚动容器包裹Column垂直布局,顶部为用户信息展示区域(头像、昵称、VIP等级),
 * 中间为功能列表区域(使用OuterFrameCard卡片容器包裹List列表),包含个人信息、VIP会员、设置等功能项。
 * 背景使用profile_background图片铺满。
 * @constraints: 个人信息和VIP会员功能需要登录后才能访问,未登录时点击会跳转到登录页。
 * 设置页面不需要登录即可访问。
 * @domain: 音频编辑
 * @zhName: 个人中心页面
 * @isGen: true
 * @fileType: page
 * @subPage: EditPersonalCenterPage,VipCenterPage,SetupPage,LoginPage
 * @component: UserItem,OuterFrameCard
 * @image: screenshots/person.jpg
 */
import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI'
import { BarVM, BreakpointModel, getMedia, RouterMap, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { LoginPageBuilder } from './LoginPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { VipCenterPageBuilder } from './VipCenterPage'

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('vip会员', $r('app.media.icon_message2'), wrapBuilder(VipCenterPageBuilder),
      RouterMap.VIP_CENTER_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder),
      RouterMap.SET_UP_PAGE),
  ]



  // 获取头像资源
  getAvatarSource(): ResourceStr {
    if (!this.userInfo.isLogin) {
      return $r('app.media.person');
    }
    if (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') {
      return this.userInfo.avatarUrl;
    }
    return $r('app.media.path2x');
  }

  // 获取VIP文本
  getVipText(): string {
    const level = this.userInfo?.vipLevel ?? 0;
    if (level === 1) {
      return 'VIP用户';
    } else if (level === 2) {
      return '超级VIP用户';
    }
    return '普通用户';
  }

  // 获取VIP左边距
  getVipMarginLeft(): number {
    const level = this.userInfo?.vipLevel ?? 0;
    return level === 0 ? 16 : 17;
  }

  @Builder
  perMine() {
    Row() {
      Image(this.getAvatarSource())
        .borderRadius(76)
        .width(76)
        .aspectRatio(1)

      Row() {
        Column() {
          Row() {
            Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '未登录')
              .height(24)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bolder)
              .margin({ left: 16, bottom: 2 })
            if (this.userInfo?.isLogin && this.userInfo?.vipLevel !== 0) {
              Image($r('app.media.icon_vip_mini'))
                .width(16)
                .height(16)
                .margin({ left: 12 })

            }
          }

          if (this.userInfo?.isLogin) {
            Text(this.getVipText())
              .fontSize(14)
              .fontColor('#5A606C')
              .fontWeight(FontWeight.Medium)
              .margin({ left: this.getVipMarginLeft() })
          }
        }
        .alignItems(HorizontalAlign.Start)

      }
      .layoutWeight(1)
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder),
          param: {
            'pageType': 'mine'
          } as Record<string, string>
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
    .margin({ top: 20, bottom: 20 })

  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.perMine()
        OuterFrameCard() {
          List() {
            UserItem({
              title: '个人信息',
              isGrid: true
            })
              .onClick(() => {
                if (this.userInfo?.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.PERSONAL_CENTER_PAGE,
                    builder: wrapBuilder(EditPersonalCenterBuilder)
                  })
                } else {
                  promptAction.showToast({ message: '请先登录' });
                }
              })
            ForEach(this.mineArr, (item: MineItem, index: number) => {
              UserItem({
                title: item.titleName,
                url: item.url,
                messageNum: item.messageNum,
                listLength: this.mineArr.length,
                index: index
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
                        builder: wrapBuilder(LoginPageBuilder),
                        param: {
                          'pageType': 'mine'
                        } as Record<string, string>
                      })
                    }
                  }
                })
            }, (item: MineItem) => JSON.stringify(item))
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .scrollBar(BarState.Off)
          .width('100%')
          .height('auto')
          .lanes(1)
          .borderRadius(16)

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
    .backgroundColor('#F5F5F5')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH
    })
  }
}

