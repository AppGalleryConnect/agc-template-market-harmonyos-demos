import { EmptyContent } from './EmptyContent'
import { Profile } from './Profile'
import { AppStorageV2, NavDestinationModifier } from '@kit.ArkUI'
import { RouterMap, RouterModule, } from '@agctemplate/router_module'
import { Audience } from 'live_interaction'
import { BarVM, ColorMode } from '@agctemplate/widgets'
import { getMyFollowing, getMyFollower } from '../models/AudienceData'
import { ConfigurationConstant } from '@kit.AbilityKit'
import { UserInfo } from 'live_interaction'

@ComponentV2
export struct ProfilePage {
  @Local currentIndex: number = 0
  private controller: TabsController = new TabsController()
  tabsContent: string[] = ['投稿', '动态']
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier()
  @Local audience: Audience = new Audience()
  @Local isMyself: boolean = false
  @Local logoUser: UserInfo = RouterModule.getNavParam<UserInfo>({ url: RouterMap.PROFILE_PAGE })!
  @Local mutualFollow: string[] = []
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!

  aboutToAppear(): void {
    const params = RouterModule.getNavParam<string | UserInfo | Audience>({ url: RouterMap.PROFILE_PAGE })!
    if (RouterModule.getSourcePage() === 'MainPage') {
      this.isMyself = true
      this.getAudience()
    } else {
      this.audience = params as Audience
    }
  }

  // 获取粉丝和关注id交集,真是互关
  getMutualConnections(followingList: string[], followersList: string[]): string[] {
    return followingList.filter(id => followersList.includes(id))
  }

  async getAudience() {
    this.audience!.followingList = await getMyFollowing()
    this.audience!.followersList = await getMyFollower()
    this.audience!.id = this.logoUser.id.toString().padStart(7, '0')
    this.audience!.nickName = this.logoUser.name
    this.audience!.avatar = this.logoUser.avatar
    this.audience!.gender = this.logoUser.sex === '女' ? 0 : 1
    this.audience!.bio = this.logoUser.bio
    this.audience!.likesCount = this.logoUser.likesCount
    this.mutualFollow = this.getMutualConnections(this.audience!.followingList, this.audience!.followersList)
  }

  // 监控用户数据,同步变化,pop返回不触发回调
  @Monitor('logoUser.name', 'logoUser.sex', 'logoUser.bio', 'logoUser.avatar')
  onChange(monitor: IMonitor) {
    monitor.dirty.forEach(() => {
      this.audience = new Audience()
      this.getAudience()
    })
  }

  @Builder
  Tab(tabName: string, tabIndex: number) {
    Column() {
      Text(tabName)
        .fontSize(16)
        .fontWeight(tabIndex === this.currentIndex ? 700 : 400)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 8 })
      if (tabIndex === this.currentIndex) {
        Divider()
          .width(16)
          .borderRadius(1)
          .strokeWidth(2)
          .color($r('sys.color.comp_divider'))
      }
    }
    .margin({ right: 16 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex)
      this.currentIndex = tabIndex
    })
  }

  build() {
    NavDestination() {
      Profile({
        audience: this.audience!,
        isMyself: this.isMyself,
        mutualFollow: this.mutualFollow,
        popCall: () => {
          this.audience = new Audience()
          this.getAudience()
        }
      })

      Column() {
        Column() {
          Scroll() {
            Row() {
              ForEach(this.tabsContent, (item: string, index: number) => {
                this.Tab(item, index)
              },(item: string, index: number) => { return index + '__' + JSON.stringify(item); })
            }
            .justifyContent(FlexAlign.Start)
          }
          .align(Alignment.Start)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('80%')
          .margin({ top: 18, left: 16 })

          Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
            ForEach(this.tabsContent, (item: string, index: number) => {
              TabContent() {
                if (index === 0) {
                  EmptyContent({ text: item })
                } else {
                  EmptyContent({ text: item })
                }
              }
            },(item: string, index: number) => { return index + '__' + JSON.stringify(item); })
          }
          .barHeight(0)
          .animationDuration(100)
          .onContentWillChange((currentIndex, comingIndex) => {
            this.currentIndex = comingIndex
            return true
          })
        }
        .alignItems(HorizontalAlign.Start)

      }
      .backgroundColor($r('sys.color.background_tertiary'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .backgroundImage(this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '' :
      $r('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .hideTitleBar(false)
    .attributeModifier(this.navDestinationModifier)
    .padding({ top: BarVM.instance.staBarH })
  }

  @Builder
  title() {
    Row() {
      Image($r('app.media.arrow_back'))
        .width(40)
        .aspectRatio(1)
        .onClick(() => {
          RouterModule.pop()
        })
    }
    .margin({ top: 8, bottom: 8, left: 16 })
  }
}

export function jumpProfilePage(liveInfo?: Audience | UserInfo, callback?: (popInfo: PopInfo) => void) {
  RouterModule.push({
    url: RouterMap.PROFILE_PAGE,
    param: liveInfo
  })
}

@Builder
export function ProfilePageBuilder() {
  ProfilePage()
}
