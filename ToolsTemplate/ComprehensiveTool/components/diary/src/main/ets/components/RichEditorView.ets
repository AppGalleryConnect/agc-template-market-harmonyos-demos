import { display } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { CALLBACK_SCHEME, STATE_SCHEME, WEB_ID } from '../commons/Constant';
import { PageMode } from '../commons/Enum';
import { EditorController } from '../controller/EditorController';
import { KeyboardUtil } from '../utils/KeyboardUtil';
import { RichTextToolBar } from './RichTextToolBar';
import { SnapShotWebController } from '../controller/SnapShotWebController';
import { SnapshotPreview } from './SnapshotPreview';

const TAG = '[RichEditorView]'


@ComponentV2
export struct RichEditorView {
  @Param pageMode: PageMode = PageMode.CREATE;
  @Param editorController: EditorController = new EditorController();
  keyboardUtil: KeyboardUtil = new KeyboardUtil(this.getUIContext());
  @Param snapShotWebController: SnapShotWebController =
    new SnapShotWebController(this.editorController.webviewController);
  @Local bgWidth: Length = 0;
  @Local bgHeight: Length = 0;
  @Local isKeyboardShow: boolean = false;

  @Computed
  get bgColor() {
    return this.pageMode === PageMode.VIEW ? Color.Transparent :
      $r('sys.color.comp_background_tertiary')
  }

  aboutToAppear(): void {
    // 获取屏幕尺寸
    try {
      const displayData = display.getDefaultDisplaySync();
      this.snapShotWebController.displayWidth = this.getUIContext().px2vp(displayData.width);
      this.snapShotWebController.displayHeight = this.getUIContext().px2vp(displayData.height);
    } catch (error) {
      UtilLog.error(TAG, `getDefaultDisplaySync failed. error: ${JSON.stringify(error)}`);
    }

    // 注册软键盘监听
    this.keyboardUtil.registerKeyboardListener(
      () => { this.onKeyboardShow() },
      () => { this.onKeyboardHide() }
    )
  }

  aboutToDisappear(): void {
    this.keyboardUtil.unregisterKeyboardListener();
  }

  onKeyboardShow() {
    this.isKeyboardShow = true
  }

  onKeyboardHide() {
    this.isKeyboardShow = false
  }

  loadData() {
    const content = this.editorController.richTextContent
    if (content) {
      this.editorController.htmlModel.initialHtmlContent = content;
      this.editorController.textCount = this.editorController.parseHtmlContent(content).length
    }
    this.editorController.setNoteContent(content);
    // 查看日记时，web禁止输入
    this.editorController.setReadOnly(this.pageMode === PageMode.VIEW);
    // 创建日记时，设置默认字体大小
    this.editorController.setInitFontSize(this.pageMode === PageMode.CREATE);
    if (this.pageMode === PageMode.EDIT) {
      setTimeout(() => {
        this.editorController.focus()
      }, 200)
    }
  }

  build() {
    Column() {
      Column() {
        Stack() {
          if (this.snapShotWebController.webMaskImage) {
            Image(this.snapShotWebController.webMaskImage)
              .width('100%')
              .height('100%')
              .zIndex(this.snapShotWebController.webMaskImageZIndex)
          }

          Column() {
            Web({
              src: $rawfile('editor.html'),
              controller: this.editorController.webviewController,
              incognitoMode: true // 隐私模式：销毁后自动清除临时数据
            })
              .id(WEB_ID)
              .backgroundColor(Color.Transparent)
              .javaScriptAccess(true)
              .horizontalScrollBarAccess(false)
              .geolocationAccess(false)
              .verticalScrollBarAccess(false)
              .fileAccess(false)
              .zoomAccess(false)
              .width('100%')
              .layoutWeight(1)
              .defaultFontSize(18)
              .onPageVisible(() => {
                this.loadData()
              })
              .onControllerAttached(() => {
                const context = this.getUIContext().getHostContext() as Context
                try {
                  // 设置允许可以跨域访问的路径列表
                  this.editorController.webviewController.setPathAllowingUniversalAccess([
                    context.filesDir + '/diaryDir',
                  ])
                } catch (error) {
                  UtilLog.error(TAG, `setPathAllowingUniversalAccess failed. error: ${JSON.stringify(error)}`);
                }
              })
              .onLoadIntercept((event) => {
                const url = event.data.getRequestUrl();
                if (url.startsWith(CALLBACK_SCHEME)) {
                  // callback处理
                  this.editorController.richTextContent = decodeURI(url.substring(CALLBACK_SCHEME.length))
                  const htmlContent = this.editorController.richTextContent
                  this.editorController.textCount = this.editorController.parseHtmlContent(htmlContent).length
                  return true;
                } else if (url.startsWith(STATE_SCHEME)) {
                  // state处理（默认无）
                  return true;
                }
                return false;
              })
              .javaScriptProxy({
                object: this.editorController.htmlModel,
                name: 'htmlContentModel',
                methodList: this.editorController.htmlModel.htmlMethodList,
                controller: this.editorController.webviewController,
              })
              .onAreaChange((oldValue, newValue) => {
                this.snapShotWebController.webWidth = newValue.width as number;
                this.snapShotWebController.webHeight = newValue.height as number;
              })
              .onOverScroll((event) => {
                if (event?.yOffset > 0) {
                  this.snapShotWebController.webTouchBottom = true
                } else if (event?.yOffset === 0 && this.snapShotWebController.webTouchBottom) {
                  this.snapShotWebController.webTouchBottom = false
                }
              })
              .onScroll((event) => {
                this.snapShotWebController.curXOffset = event.xOffset;
                this.snapShotWebController.curYOffset = event.yOffset;
              })

            if (this.pageMode !== PageMode.VIEW) {
              Row() {
                Text(this.editorController.textCount + '字')
                  .fontSize(10)
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .width('100%')
              .height(36)
              .justifyContent(FlexAlign.End)
              .alignItems(VerticalAlign.Center)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .padding(this.pageMode === PageMode.VIEW ? null : {
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          })
          .backgroundColor(this.bgColor)
          .borderRadius(16)
        }
        .width('100%')
        .layoutWeight(1)
        .bindContentCover(
          $$this.snapShotWebController.isShowPreview,
          this.previewWindowComponent(),
          { modalTransition: ModalTransition.NONE },
        )
      }
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 16 })
      .layoutWeight(1)

      // 底部工具栏
      RichTextToolBar({
        editorController: this.editorController,
        showToolBar: this.isKeyboardShow,
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 截图预览小窗口。
   */
  @Builder
  previewWindowComponent() {
    Column() {
      SnapshotPreview({
        mergedImage: this.snapShotWebController.mergedImage,
        snapPopupPosition: this.snapShotWebController.snapPopupPosition,
        isLargePreview: this.snapShotWebController.isLargePreview,
        isShowPreview: this.snapShotWebController.isShowPreview,
        changeMergedImage: (mergedImage) => {
          this.snapShotWebController.mergedImage = this.snapShotWebController.mergedImage;
        },
        changeSnapPopupPosition: (snapPopupPosition) => {
          if (snapPopupPosition) {
            this.snapShotWebController.snapPopupPosition = snapPopupPosition;
          }
        },
        changeIsShowPreview: (showPreview: boolean) => {
          this.snapShotWebController.isShowPreview = showPreview;
        },
        changeIsLargePreview: (largePreview: boolean) => {
          this.snapShotWebController.isLargePreview = largePreview;
        },
      });
    };
  }
}