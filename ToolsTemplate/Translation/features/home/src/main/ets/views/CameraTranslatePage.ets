/**
 * 拍照翻译页面
 */
import { CameraTranslateViewModel } from '../viewmodel/CameraTranslateViewModel';
import { ImageTranslateHelper } from '../model/ImageTranslateHelper';
import { CameraTranslateSelector } from '../comp/CameraTranslateSelector';
import { CameraTranslatePreview } from '../comp/CameraTranslatePreview';
import { OHPage, phoneRouterControl } from 'oh_router';

// 页面参数接口
interface CameraTranslatePageParam {
  imageUri?: string;
  imageSource?: string;
}

@Builder
export function CameraTranslatePageBuilder(params?: Record<string, Object>) {
  CameraTranslatePage({
    pageParams: params
  })
}

/**
 * @usage: 拍照翻译页面，支持通过拍照或相册选择图片进行OCR识别和翻译。API自动检测源语言并进行中英互译。
 * 主要数据结构包括CameraTranslateViewModel（相机翻译视图模型）、CameraTranslatePageParam（页面参数）。
 * 包含if逻辑判断显示选择界面或预览界面。
 * @layout: 页面采用OHPage包装，内部为Column垂直布局。根据showSelectionView状态切换显示：
 * 选择界面CameraTranslateSelector（拍照/相册选择按钮）或预览界面CameraTranslatePreview（图片预览和翻译按钮）。
 * @constraints: 需要用户授权相机和相册访问权限，图片翻译需要网络连接
 * @domain: 翻译工具
 * @zhName: 拍照翻译页面
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @component: CameraTranslateSelector,CameraTranslatePreview
 * @image: screenshot/home/CameraTranslatePage.jpg
 */
@ComponentV2
export struct CameraTranslatePage {
  @Param pageParams?: Record<string, Object> = undefined;
  @Local vm: CameraTranslateViewModel = new CameraTranslateViewModel();
  @Local sourceLanguage: string = 'zh';
  @Local targetLanguage: string = 'en';
  @Local capturedImageUri: string = '';
  @Local showSelectionView: boolean = true;
  @Local imageSource: 'camera' | 'album' | '' = '';

  aboutToAppear(): void {
    // 检查是否有传递的参数
    if (this.pageParams) {
      const param = this.pageParams as CameraTranslatePageParam;
      if (param.imageUri) {
        this.capturedImageUri = param.imageUri;
        const sourceParam = param.imageSource;
        this.imageSource = (sourceParam === 'camera' || sourceParam === 'album') ? sourceParam : 'camera';
        this.showSelectionView = false;
      }
    }
    // API会自动检测源语言，并选择合适的目标语言（中英互译）
    this.sourceLanguage = 'auto';
    this.targetLanguage = 'auto';
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: false,
      useSafePadding: false,
      pageBackgroundColor: Color.Black,
      expandSafeAreaEnabled: true
    })
  }

  @Builder
  render() {
    Column() {
      if (this.showSelectionView) {
        CameraTranslateSelector({
          callbacks: {
            onImageSelected: (imageUri: string, source: 'camera' | 'album') => {
              this.capturedImageUri = imageUri;
              this.imageSource = source;
              this.showSelectionView = false;
            },
            onBack: () => {
              phoneRouterControl.popPage();
            }
          }
        })
      } else if (this.capturedImageUri) {
        CameraTranslatePreview({
          imageUri: this.capturedImageUri,
          imageSource: this.imageSource,
          vm: this.vm,
          callbacks: {
            onBack: () => {
              phoneRouterControl.popPage();
            },
            onRetake: (newImageUri: string) => {
              // 直接更新图片URI，保持在预览页面
              this.capturedImageUri = newImageUri;
              this.imageSource = 'camera';
            },
            onReselect: (newImageUri: string) => {
              // 直接更新图片URI，保持在预览页面
              this.capturedImageUri = newImageUri;
              this.imageSource = 'album';
            },
            onTranslate: (imageUri: string) => {
              ImageTranslateHelper.translateImage(
                imageUri,
                this.sourceLanguage,
                this.targetLanguage,
                this.vm
              );
            }
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
