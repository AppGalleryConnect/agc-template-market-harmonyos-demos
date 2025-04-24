import { NavBarView } from './NavBarView';
import { Constants } from 'utils';

export interface NavBarInfo {
  image: ResourceStr;
  text: string;
  pageName: string;
}

@ComponentV2
export struct NavBarListView {
  @Param pathStack: NavPathStack = new NavPathStack();
  @Require @Param navBarList: NavBarInfo[] = [];

  @Builder
  BuildEachBar(item: NavBarInfo) {
    NavBarView({
      pathStack: this.pathStack,
      image: item.image,
      text: item.text,
      pageName: item.pageName,
    });
  }

  @Styles
  ListItemStyle() {
    .margin({ left: 10, right: 10 }).height(50);
  }

  build() {
    Column() {
      List() {
        ForEach(this.navBarList, (item: NavBarInfo) => {
          ListItem() {
            this.BuildEachBar(item);
          }.ListItemStyle();
        }, (item: NavBarInfo) => item.text);
      }
      .alignListItem(ListItemAlign.Center)
      .divider({
        strokeWidth: 1,
        color: '#F1F3F5',
        startMargin: 10,
        endMargin: 10,
      })
      .width('90%')
      .borderRadius(16)
      .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR)
      .margin({ top: 30 });
    };
  }
}