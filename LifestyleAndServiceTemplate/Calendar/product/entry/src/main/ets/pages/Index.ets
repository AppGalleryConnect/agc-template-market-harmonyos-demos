import { ThemeModel } from 'common';
import { TabContainer } from './TabContainer'
import { PersistenceV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () =>new ThemeModel())!;
  @Provider('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  build() {
    Navigation(this.pageInfos) {
      TabContainer()
    }
    .hideTitleBar(true)
    .backgroundColor(this.theme.themeState.current)
    .mode(NavigationMode.Stack)
  }
}