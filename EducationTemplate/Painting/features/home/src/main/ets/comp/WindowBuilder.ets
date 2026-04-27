import { BarVM, BreakpointModel, Constants, WindowPopManager } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { BottomMenuBar } from './BottomMenuBar';
import { CommonConstants } from '../constants/Constant';

@ComponentV2
export struct WindowBuilder {
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @BuilderParam sheetBuilder: () => void
  @Param previewSize?: number = 3
  @Param previewColor?: string = '#fff'
  @Param isEraser?: boolean = false
  @Param isPreview?: boolean = false

  build() {
    Column() {
      Column() {
        Column() {
          if (this.isPreview) {
            Row() {
              Circle()
                .width(this.previewSize)
                .height(this.previewSize)
                .fill(this.isEraser ? Color.Transparent : this.previewColor)
                .strokeWidth(this.isEraser ? 1 : 0.5)
                .stroke('#4D000000')
            }
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.Center)
            .padding(4)
            .hitTestBehavior(HitTestMode.Default)
            .margin({ bottom: 20 })
          }
          Column() {
            this.sheetBuilder()
          }
          .onTouch((event) => {
            event.stopPropagation()
          })
        }
        .hitTestBehavior(HitTestMode.Transparent)
        .width(this.breakpointModel.currentDisplayWidth > 450 ? this.breakpointModel.currentDisplayWidth - 230 :
        Constants.FULL_SIZE)
        .clip(true)
        .borderRadius(this.breakpointModel.currentDisplayWidth > 450 ? $r('sys.float.corner_radius_level16') :
          { topLeft: $r('sys.float.corner_radius_level16'), topRight: $r('sys.float.corner_radius_level16') })
      }
      .layoutWeight(1)
      .width(Constants.FULL_SIZE)
      .justifyContent(this.breakpointModel.currentDisplayWidth > 450 ? FlexAlign.Center : FlexAlign.End)
      .backgroundColor($r('sys.color.mask_fourth'))
      .onTouch(()=>{
        WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
      })

      BottomMenuBar()
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .padding({bottom:BarVM.instance.aiBarH})
  }
}