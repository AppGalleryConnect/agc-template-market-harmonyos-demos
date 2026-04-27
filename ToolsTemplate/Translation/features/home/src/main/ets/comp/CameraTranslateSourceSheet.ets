import { common } from '@kit.AbilityKit';
import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { BreakpointModel, GlobalContext } from 'common';
import { ImagePickerUtil } from '../utils/ImagePickerUtil';
import { CMPromptAction } from 'common/src/main/ets/util/CMPromptAction';

const TAG: string = 'CameraTranslateSourceSheet';

export interface ImageSourceSheetCallbacks {
  onImageSelected: (imageUri: string, source: 'camera' | 'album') => void;
  onDismiss: () => void;
}

/**
 * @usage: 拍照翻译来源选择弹窗管理类，提供居中弹窗方式的图片来源选择。用于折叠屏等大屏设备的图片来源选择。
 * 主要数据结构包括ImageSourceSheetCallbacks（回调接口）、CMPromptAction（弹窗管理工具）。
 * @layout: 弹窗采用Column垂直布局，包含三个按钮Row：拍照按钮、从相册选择按钮、取消按钮。整体灰色圆角卡片样式。
 * @constraints: 需要用户授权相机和相册访问权限
 * @domain: 翻译工具
 * @isGen: true
 * @zhName: 拍照翻译来源选择弹窗管理类
 * @fileType: component
 * @image:
 */
export class CameraTranslateSourceDialog {
  private constructor() {
  }

  static showDialog(callbacks: ImageSourceSheetCallbacks) {
    if (CMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildCameraSourcePopup), callbacks);
        CMPromptAction.uiContext = uiContext;
        CMPromptAction.contentNode = contentNode;
        CMPromptAction.options = {
          alignment: DialogAlignment.Center,
          autoCancel: true,
          onWillDismiss: (_reason: DismissDialogAction) => {
            CMPromptAction.closeDialog();
            callbacks.onDismiss();
            return true;
          }
        };
        CMPromptAction.openDialog();
      } else {
      }
    }
  }

  static closeDialog() {
    CMPromptAction.closeDialog();
  }
}

@ComponentV2
struct CameraSourcePopup {
  @Param @Require callbacks: ImageSourceSheetCallbacks;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      // 拍照按钮
      Row() {
        Text('拍照')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => {
        CameraTranslateSourceDialog.closeDialog();
        this.takePicture();
      })

      // 从相册选择按钮
      Row() {
        Text('从相册选择')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        CameraTranslateSourceDialog.closeDialog();
        this.selectFromAlbum();
      })

      // 取消按钮
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        CameraTranslateSourceDialog.closeDialog();
        this.callbacks.onDismiss();
      })
    }
    .width(this.breakpointModel.currentDisplayWidth > 400 ? 376 : this.breakpointModel.currentDisplayWidth - 32)
    .padding(16)
    .borderRadius(16)
    .backgroundColor('#F5F5F5')
  }

  private async takePicture() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.takePicture(context);
    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'camera');
    }
  }

  private async selectFromAlbum() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.selectFromAlbum(context);
    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'album');
    }
  }
}

@Builder
function buildCameraSourcePopup(callbacks: ImageSourceSheetCallbacks) {
  CameraSourcePopup({ callbacks: callbacks })
}


@ComponentV2
export struct CameraTranslateSourceSheet {
  @Param callbacks: ImageSourceSheetCallbacks = {
    onImageSelected: () => {
    },
    onDismiss: () => {
    }
  };

  build() {
    Column() {
      // 拍照按钮
      Row() {
        Text('拍照')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => {
        this.callbacks.onDismiss();
        this.takePicture();
      })

      // 从相册选择按钮
      Row() {
        Text('从相册选择')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        this.callbacks.onDismiss();
        this.selectFromAlbum();
      })

      // 取消按钮
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        this.callbacks.onDismiss();
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }

  private async takePicture() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.takePicture(context);
    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'camera');
    }
  }

  private async selectFromAlbum() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.selectFromAlbum(context);
    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'album');
    }
  }
}
