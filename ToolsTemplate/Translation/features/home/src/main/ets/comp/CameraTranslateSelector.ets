/**
 * 相机图片选择组件 - 选择界面
 */
import { common } from '@kit.AbilityKit';
import { ImagePickerUtil } from '../utils/ImagePickerUtil';

export interface CameraImageSelectorCallbacks {
  onImageSelected: (imageUri: string, source: 'camera' | 'album') => void;
  onBack: () => void;
}

@ComponentV2
export struct CameraTranslateSelector {
  @Param callbacks: CameraImageSelectorCallbacks = {
    onImageSelected: () => {
    },
    onBack: () => {
    }
  };

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .fontWeight(FontWeight.Normal)
        }
        .width(40)
        .height(40)
        .type(ButtonType.Circle)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.callbacks.onBack();
        })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 选择按钮区域
      Column() {
        // 拍照按钮
        Column() {
          Text('拍照')
            .fontSize(20)
            .fontColor($r('sys.color.brand'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .onClick(() => {
          this.takePicture();
        })

        // 从相册选择按钮
        Column() {
          Text('从相册选择')
            .fontSize(20)
            .fontColor($r('sys.color.brand'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 16 })
        .onClick(() => {
          this.selectFromAlbum();
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  //从相册选择
  private async selectFromAlbum() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.selectFromAlbum(context);

    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'album');
    }
  }

  //拍照
  private async takePicture() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.takePicture(context);

    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'camera');
    }
  }
}
