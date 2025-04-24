import { RouterModule, silentLogin, Logger, RouterMap } from 'utils';

@Entry
@ComponentV2
struct Index {
  private intervalId = 0;

  aboutToAppear() {
    Logger.info('Index Page onCreate');
    silentLogin().then((isSuccess) => {
      if (isSuccess) {
        RouterModule.replace({ url: RouterMap.MAIN });
      }
    });
  }

  aboutToDisappear(): void {
    // 清除定时器
    clearInterval(this.intervalId);
  }

  build() {
    Navigation(RouterModule.getStack()) {
    }.hideNavBar(true)
  }
}