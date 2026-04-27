import { webview } from '@kit.ArkWeb';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { RawEditorOptions } from '../options/tinymce'
import { EasyEditorBridge } from '../utils/Bridge';
import { EasyEditorController } from '../utils/Controller';
import { bindWith } from '../utils/Index'

const TAG = '[EasyEditor]';

@ComponentV2
export struct EasyEditor {
  @Local _privateController: webview.WebviewController = new webview.WebviewController();
  @Local _privateDisposer?: Callback<void>
  @Param darkMode: boolean = false
  @Param @Once config: string | RawEditorOptions = ''
  @Param @Once controller?: EasyEditorController = undefined
  @Param @Once content: string = ''
  @Param @Once javascriptProxies?: Array<JavaScriptProxy> = []
  @Param hideRichOperation: boolean = false
  @Event onContentChange?: Callback<string> = undefined
  private customDialogComponentId: number = 0

  @Monitor('content')
  contentChanged(_: IMonitor) {
    this.onContentChange && this.onContentChange(this.content)
  }

  @Monitor('hideRichOperation')
  hideRichOperationChange(_: IMonitor) {
    this.onHideOperation()
  }

  @Builder
  customDialogComponent(confirm: () => void) {
    Column() {
      Text('温馨提示').fontSize(20).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Bold)
      Text('您确定将重置所有样式？')
        .fontSize(16).fontColor($r('sys.color.font_primary'))
      Row({ space: 120 }) {
        Text('取消')
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              UtilLog.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(error));
            }
          })
        Text('确认')
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            confirm()
            try {
              this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId)
            } catch (error) {
              UtilLog.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(error));
            }
          })
      }
    }.height(160).padding({ top: 16, bottom: 26 }).justifyContent(FlexAlign.SpaceBetween)
  }

  removeFormat(confirm: () => void) {
    this.getUIContext()
      .getPromptAction()
      .openCustomDialog({
        builder: () => {
          this.customDialogComponent(confirm)
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason !== DismissReason.TOUCH_OUTSIDE) {
            dismissDialogAction.dismiss()
          }
        },
      })
      .then((dialogId: number) => {
        this.customDialogComponentId = dialogId
      })
      .catch((e: BusinessError) => {
        UtilLog.error(TAG, 'openCustomDialog fail, error: ' + JSON.stringify(e));
      })
  }

  aboutToAppear(): void {
    /*
     * get set方法绑定到controller中
     * */
    this._privateDisposer = bindWith(this, this.controller, {
      'setContent': 'setContent',
      'getContent': 'getContent',
      'onHideOperation': 'onHideOperation',
      'setDarkMode': 'setDarkMode',
    })
    webview.WebviewController.setWebDebuggingAccess(false);
  }

  aboutToDisappear(): void {
    this._privateDisposer && this._privateDisposer()
  }

  build() {
    Web({ src: '', controller: this._privateController })
      .geolocationAccess(false)
      .domStorageAccess(true)
      .mixedMode(MixedMode.None)
      .fileAccess(false)
      .imageAccess(true)
      .javaScriptAccess(true)
      .backgroundColor($r('sys.color.background_primary'))
      .onlineImageAccess(true)
      .databaseAccess(true)
      .darkMode(WebDarkMode.Auto)
      .forceDarkAccess(true)
      .onControllerAttached(() => {
        try {
          this._privateController.registerJavaScriptProxy(new EasyEditorBridge(this),
            'EasyEditorBridge',
            ['fetchConfig', 'onContentChanged', 'fetchContent', 'darkMode', 'removeFormat'], [],
            `{"javascriptProxyPermission":{"urlPermissionList":[{"scheme":"resource","host":"rawfile","port":"","path":""}]}}`)
          if (this.javascriptProxies?.length) {
            this.javascriptProxies.forEach(proxy => {
              this._privateController.registerJavaScriptProxy(proxy.object,
                proxy.name,
                proxy.methodList ?? [],
                proxy.asyncMethodList ?? [],
                proxy.permission ??
                  `{"javascriptProxyPermission":{"urlPermissionList":[{"scheme":"resource","host":"rawfile","port":"","path":""}]}}`)
            })
          }
          this._privateController.loadUrl($rawfile('easy_tinymce/index.html'));
        } catch (e) {
          UtilLog.error(TAG, 'onControllerAttached fail, error: ' + JSON.stringify(e));
        }
      })
      .onShowFileSelector((event) => {
        if (event) {
          this.selectFile(event.result);
        }
        return true;
      })
      .width('100%')
      .layoutWeight(1)
  }

  async selectFile(result: FileSelectorResult): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const chooseFile: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
      result.handleFileList(chooseFile.photoUris);
    } catch (e) {
      UtilLog.error(TAG, `Failed to select photo, code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 设置内容
   * @param content 要设置的内容
   */
  setContent(content: string) {
    this.content = content
    this._privateController.runJavaScript(`window.injectContent()`).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'setContent runJavaScript fail, error: ' + JSON.stringify(e));
    });
  }

  /**
   * 获取内容
   * @returns 获取到的内容
   */
  getContent() {
    return this.content
  }

  /**
   * 设置操作栏显示
   * @returns 操作栏显示状态
   */
  onHideOperation() {
    this._privateController.runJavaScript(`window.toggleToolbar(${this.hideRichOperation})`)
      .catch((e: BusinessError) => {
        UtilLog.error(TAG, 'onHideOperation runJavaScript fail, error: ' + JSON.stringify(e));
      });
  }
}





