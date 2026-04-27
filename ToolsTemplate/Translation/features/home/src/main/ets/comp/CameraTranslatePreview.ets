/**
 * 相机图片预览组件
 */
import { CameraTranslateViewModel } from '../viewmodel/CameraTranslateViewModel';
import { common } from '@kit.AbilityKit';
import { ImagePickerUtil } from '../utils/ImagePickerUtil';
import { BarVM } from 'common';

export interface CameraImagePreviewCallbacks {
  onBack: () => void;
  onRetake: (newImageUri: string) => void;
  onReselect: (newImageUri: string) => void;
  onTranslate: (imageUri: string) => void;
}

@ComponentV2
export struct CameraTranslatePreview {
  @Param imageUri: string = '';
  @Param imageSource: 'camera' | 'album' | '' = '';
  @Param vm: CameraTranslateViewModel = new CameraTranslateViewModel();
  @Param callbacks: CameraImagePreviewCallbacks = {
    onBack: () => {
    },
    onRetake: (_newImageUri: string) => {
    },
    onReselect: (_newImageUri: string) => {
    },
    onTranslate: (_imageUri: string) => {
    }
  };

  build() {
    Stack() {
      // 图片展示
      Stack() {
        Image(this.imageUri)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)

        // 加载中遮罩
        if (this.vm.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('sys.color.comp_background_list_card'))
            Text('翻译中...')
              .fontColor(Color.White)
              .fontSize(14)
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#80000000')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)

      // 顶部导航栏 - 悬浮在图片上
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Normal)
        }
        .width(40)
        .height(40)
        .type(ButtonType.Circle)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .onClick(() => {
          this.callbacks.onBack();
        })

        Blank()

        Text(this.imageSource === 'camera' ? '重拍' : '重选')
          .fontSize(14)
          .fontColor(Color.White)
          .onClick(() => {
            if (this.imageSource === 'camera') {
              this.takePicture();
            } else {
              this.selectFromAlbum();
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16, top: BarVM.instance.staBarH })
      .position({ top: 0 })

      // 翻译按钮（底部）
      Column() {
        Button('图片转文字')
          .width('80%')
          .height(48)
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.callbacks.onTranslate(this.imageUri);
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 32 })
      .alignItems(HorizontalAlign.Center)
      .position({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /**
   * 拍照（原生相机）
   */
  private async takePicture() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.takePicture(context);

    if (imageUri) {
      this.callbacks.onRetake(imageUri);
    }
  }

  /**
   * 从相册选择
   */
  private async selectFromAlbum() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.selectFromAlbum(context);

    if (imageUri) {
      this.callbacks.onReselect(imageUri);
    }
  }
}
