import { CommonConstants } from 'commonlib';
import { BeautyActionBar } from '../components/BeautyActionBar';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { BeautyHeaderView } from '../views/BeautyHeaderView';
import { BeautyContentView } from '../views/BeautyContentView';


@Builder
export function PictureBeautificationBuilder() {
  PictureBeautification();
}

@ComponentV2
export struct PictureBeautification {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  aboutToAppear(): void {
    // 注册字体
    this.vm.registerFont();
    // 初始化图片信息
    this.vm.initImageData();
  }

  aboutToDisappear(): void {
    // 页面销毁时，需要重置对象
    PhotoBeautificationVM.instance = new PhotoBeautificationVM();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        // 头部
        BeautyHeaderView()

        Column({ space: 12 }) {
          BeautyContentView()
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
          BeautyActionBar()
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .padding({ top: 56 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .onBackPressed(() => {
      if (this.vm.totalLayerCount > 1) {
        this.vm.showDiscardDialog();
        return true;
      } else {
        return false;
      }
    });
  }
}