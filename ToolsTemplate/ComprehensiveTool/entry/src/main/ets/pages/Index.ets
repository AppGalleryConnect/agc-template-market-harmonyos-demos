import { RouterUtils } from '../utils/RouterUtils';

@Entry
@ComponentV2
struct Index {
  aboutToAppear(): void {
    RouterUtils.replacePathByName('HwAdPage', null);
  }

  build() {
    Navigation(RouterUtils.getStack()) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%');
  }
}