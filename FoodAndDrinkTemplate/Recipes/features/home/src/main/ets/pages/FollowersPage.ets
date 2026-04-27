import { AccountUtil, buildTitleBar, RouterMap, RouterModule } from 'commonlib'
import { LengthMetrics } from '@kit.ArkUI'
import { FollowersPageVM } from '../viewModels/FollowersPageVM'
import { BloggerFollower } from 'network'

@Builder
export function FollowersPageBuilder() {
  FollowersPage()
}

@ComponentV2
struct FollowersPage {
  @Local vm: FollowersPageVM = new FollowersPageVM()

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.vm.followerList, (item: BloggerFollower, index: number) => {
          ListItem() {
            Row() {
              Row() {
                Image($r(`app.media.${item.authorAvatar}`)).width(40).height(40).borderRadius(20)
                Text(item.author).fontSize(16).fontColor($r('sys.color.font_primary')).margin({ left: 8 })
              }

              Button(item.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
                .fontSize($r('sys.float.Body_M'))
                .fontColor(item.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
                .backgroundColor(item.isFollower ? '#33FD4238' : '#FD4238')
                .margin({right: 18})
                .onClick(() => {
                  if (!AccountUtil.getUserInfo().isLogin) {
                    RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
                    return
                  }
                  item.isFollower = !item.isFollower
                })
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 12, bottom: 12 })

          }
        }, (item: BloggerFollower) => JSON.stringify(item))
      }
      .padding({ left: 16 })
      .contentStartOffset(12)
      .contentEndOffset(12)
      .scrollBar(BarState.Off)
      .lanes(this.vm.getLanes)
    }
    .title(buildTitleBar(`${this.vm.authorName}关注的人`), { paddingStart: LengthMetrics.vp(16) })
    .padding({top: 40})
  }
}