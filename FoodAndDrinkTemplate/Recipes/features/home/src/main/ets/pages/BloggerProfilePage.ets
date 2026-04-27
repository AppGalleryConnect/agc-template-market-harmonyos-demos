import { buildTitleBar, CommonConstants, RouterMap, RouterModule } from 'commonlib'
import { BloggerProfilePageVM } from '../viewModels/BloggerProfilePageVM'
import { LengthMetrics } from '@kit.ArkUI'
import { PersonalHomepage } from 'personal_homepage'
import { BloggerInfomation } from 'personal_homepage/src/main/ets/components/BloggerInfomation'
import { BaseTabs } from 'base_ui'

@Builder
export function BloggerProfilePageBuilder() {
  BloggerProfilePage()
}

@ComponentV2
struct RecipesHeader {
  @Param currentIndex: number = 1
  @Event changeTabs: (index: number) => void = () => {
  };

  build() {
    Row() {
      BaseTabs({
        tabsTitle: ['菜谱', '收藏'],
        currentIndex: this.currentIndex,
        changeTabs: this.changeTabs
      })
        .width(228)
        .align(Alignment.Center)

      Image($r('app.media.ic_title_search'))
        .width(40)
        .height(40)
        .onClick(() => {
          RouterModule.push(RouterMap.SEARCH)
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(56)
    .width('100%')
    .align(Alignment.Center)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}

@ComponentV2
struct BloggerProfilePage {
  @Local vm: BloggerProfilePageVM = new BloggerProfilePageVM()

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          BloggerInfomation({
            bloggerInfo: this.vm.bloggerInfo,
            isFollower: this.vm.isFollower,
            followCb: (isFollower: boolean) => {
              this.vm.followCb(isFollower)
            },
            jumpFollowers: () => {
              RouterModule.push(RouterMap.FOLLOWERS_PAGE, { 'id': this.vm.bloggerInfo.id } as Record<string, number>)
            },
            jumpMemberCenter: () => {
              RouterModule.push(RouterMap.MEMBER_CENTER_PAGE);
            }
          }).padding({ top: 12, left: 16, right: 16 })

          RecipesHeader({
            currentIndex: this.vm.currentIndex,
            changeTabs: (index: number) => {
              this.vm.changeTabs(index)
            },
          })

          PersonalHomepage({
            recipeList: this.vm.recipeList,
            currentIndex: this.vm.currentIndex,
            onClickCb: (id: number) => {
              RouterModule.push(RouterMap.DISHES, { 'id': id } as Record<string, number>)
            },
            jumpBloggerInfo: (id: number) => {
              RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
            }
          })
        }.backgroundColor($r('sys.color.comp_background_gray'))
      }.scrollBar(BarState.Off)
    }
    .title(buildTitleBar('', false), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: CommonConstants.STATUS_BAR_HEIGHT })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}