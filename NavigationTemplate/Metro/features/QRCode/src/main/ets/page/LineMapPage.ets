import { webview } from '@kit.ArkWeb';
import { MainEntryVM } from 'commonlib';
import { BaseTitle } from 'componentlib';


@Builder
export function LineMapPageBuilder(name: string, param: Object) {
  LineMapPage()
}


@Component
export struct LineMapPage {
  controller: webview.WebviewController = new webview.WebviewController();
  @State scaleValue: number = 1
  @State pinchValue: number = 1
  @State pinchX: number = 0
  @State pinchY: number = 0
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  LineMapBuilder() {
    Text('线网图')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.LineMapBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Web({ src: $rawfile('LineMap.png'), controller: this.controller })
        .layoutMode(WebLayoutMode.NONE)
        .width('100%')
        .height('100%')
        .fileAccess(false)
        .geolocationAccess(false)
        .onGeolocationShow((event) => {
          if (event === undefined) {
            return
          }
          AlertDialog.show({
            message: '是否同意返回位置信息',
            confirm: {
              value: '同意',
              action: () => {
                event.geolocation.invoke(event.origin, true, true);
              }
            },
            cancel: () => {
              event.geolocation.invoke(event.origin, false, true);
            }
          })
        })
    }
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
  }
}