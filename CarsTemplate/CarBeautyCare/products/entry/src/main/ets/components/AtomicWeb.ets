import { webview } from '@kit.ArkWeb';

@Builder
export function AtomicWebBuilder() {
  AtomicWeb()
}

@ComponentV2
struct AtomicWeb {
  topRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack()
  @Param title:string = '';
  controller: webview.WebviewController = new webview.WebviewController();
  @Local path: string = 'developer.huawei.com';

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    let path:string = this.appPathStack.getParamByIndex(this.appPathStack.size() - 1) as string;
    this.path = path;
  }

  build() {
    NavDestination() {
      Web({ src: this.path, controller: this.controller })
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .title(this.title)
    .margin({
      top:px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}