import { BaseTabs } from 'base_ui';
import { RouterMap, RouterModule } from 'commonlib';

// 吸顶头部，普通态和吸顶态复用同一组件，通过 isSticky 区分阴影样式
@ComponentV2
export struct RecipesHeader {
  @Param isStickyEd: boolean = false
  @Param currentIndex: number = 1
  @Param gridCount: number = 2
  @Event changeTabs: (index: number) => void = () => {
  };

  build() {
    Row() {
      BaseTabs({
        tabsTitle: ['菜谱', '收藏'],
        mineWidth: 228,
        currentIndex: this.currentIndex,
        changeTabs: this.changeTabs
      })
        .align(Alignment.Center)

      if(this.gridCount === 2) {
        Image($r('app.media.ic_title_search'))
          .width(40)
          .height(40)
          .onClick(() => {
            RouterModule.push(RouterMap.SEARCH)
          })
      } else {
        Search({ placeholder: '输入关键词' })
          .width(328)
          .onClick(() => {
            RouterModule.push(RouterMap.SEARCH)
          })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(56)
    .width('100%')
    .align(Alignment.Center)
    .padding({ left: 16, right: 16 })
  }
}