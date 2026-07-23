import { CommonHeader } from 'component';
import { Constants } from 'constant';

@Builder
export function MyFavoritesBuilder() {
  MyFavorites();
}

@ComponentV2
export struct MyFavorites {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '我的收藏', showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }});


      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true);
  }
}
