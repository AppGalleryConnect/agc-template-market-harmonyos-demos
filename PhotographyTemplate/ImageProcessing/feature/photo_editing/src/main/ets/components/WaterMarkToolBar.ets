import { componentSnapshot } from '@kit.ArkUI';
import { CommonConstants, OperateType } from 'commonlib';
import { LayerType } from '../constant/Enum';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { ToolBarHeader } from './ToolBarHeader';


@ComponentV2
export struct WaterMarkToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;


  exitWaterMaker() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    });
  }

  saveWaterMaker() {
    this.vm.saveImage(LayerType.WATER);
    this.exitWaterMaker()
  }

  build() {
    Column({ space: 16 }) {
      // 头部
      ToolBarHeader({
        close: () => {
          this.exitWaterMaker();
        },
        confirm: () => {
          this.saveWaterMaker();
        },
      })

      Column({ space: 4 }) {
        Image($r('app.media.no_sign')).width(24);
        Text('还原').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
      }
      .onClick(() => {
        this.vm.operateType = OperateType.NONE;
      })
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}