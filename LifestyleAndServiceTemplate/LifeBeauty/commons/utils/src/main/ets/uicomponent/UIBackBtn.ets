import { RouterModule } from '../router/RouterModule';

/**
 * 自定义返回按钮，模拟系统NavDestination
 */
@ComponentV2
export struct UIBackBtn {
  @Event clickEvent: () => void = () => {
    RouterModule.pop();
  };

  build() {
    Button() {
      Image($r('app.media.ic_public_arrow_left')).width(16).height(16)
    }
    .width(40)
    .height(40)
    .backgroundColor('#0C000000')
    .margin({ left: 16 })
    .onClick(() => {
      this.clickEvent();
    })
  }
}