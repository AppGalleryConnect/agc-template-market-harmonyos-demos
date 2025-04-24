import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { imagePreview } from '../imagePreview/imagePreview';

class NativeShare {
  constructor() {
  }

  share(): string {
    /*
     * 可能需要跳转到应用中进行分享操作
     * */
    return 'ArkUI Web Component';
  }

  preview(srcList: string[], index: number) {
    /*
     * 调用原生组件查看图片
     * */
    imagePreview.show(srcList, {
      startIndex: index,
    })
  }
}

@ComponentV2
export struct WebCommon {
  controller: webview.WebviewController = new webview.WebviewController();
  @Param loadUrl: string = ''
  @Local nativeShareObj: NativeShare = new NativeShare();
  @Require @Param title: string

  build() {
    NavDestination() {
      Column() {
        Web({ src: '', controller: this.controller })
          .onControllerAttached(() => {
            this.controller.loadUrl($rawfile(this.loadUrl));
            try {
              this.controller.registerJavaScriptProxy(this.nativeShareObj, 'nativeShare', ['share', 'preview'],
              );
            } catch (error) {
              console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
          .geolocationAccess(false)
      }
    }.padding({ top: Number(AppStorage.get('topRectHeight')) }).title(this.title)
  }
}