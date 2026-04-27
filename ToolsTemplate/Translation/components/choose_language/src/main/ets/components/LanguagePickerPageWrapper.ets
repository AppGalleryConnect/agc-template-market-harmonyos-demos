import { LanguagePickerPage } from '../views/LanguagePickerPage';
import { LanguageViewModel } from '../viewmodel/LanguageViewModel';

/**
 * 语言选择页面包装器组件
 * 用于NavDestination导航
 */
@ComponentV2
export struct LanguagePickerPageWrapper {
  @Local routerModule: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      LanguagePickerPage({
        viewModel: new LanguageViewModel(),
        routerModule: this.routerModule
      })
    }
    .onReady((context) => {
      this.routerModule = context.pathStack;
    })
    .hideTitleBar(true)
  }
}
