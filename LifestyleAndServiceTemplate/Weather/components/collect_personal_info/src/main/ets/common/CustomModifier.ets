import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigInfo } from './ConfigModel';
import { WindowModel } from './WindowModel';
import { Constants } from './Constant'

// 半模态column
@ObservedV2
export class SheetColumnModifier implements AttributeModifier<ColumnAttribute> {
  @Trace configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!;
  @Trace windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Trace needAvoidBottom: boolean = true;
  @Trace paddingTop: number = Constants.PADDING_L;

  constructor(paddingTop?: number) {
    if (paddingTop) {
      this.paddingTop = paddingTop;
    }
  }

  applyNormalAttribute(instance: ColumnAttribute): void {
    instance
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .padding({
        left: Constants.PADDING_L,
        right: Constants.PADDING_L,
        top: this.paddingTop,
        bottom: this.configInfo.sheetType === SheetType.CENTER
          ? Constants.PADDING_L
          : Constants.PADDING_L + (this.needAvoidBottom ? this.windowModel.windowBottomPadding : 0),
      })
  }
}

// 确定按钮
@ObservedV2
export class ConfirmButtonModifier implements AttributeModifier<ButtonAttribute> {
  @Trace configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance
      .width(Constants.FULL_PERCENT)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_on_primary'))
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.configInfo.themeColor)
  }
}

// 半模态内部标题
@ObservedV2
export class InnerTitleModifier implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize($r('sys.float.Title_M'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .padding({
        top: Constants.PADDING_XL,
        bottom: Constants.PADDING_7XL,
      })
      .transition(TransitionEffect.OPACITY
        .animation({ duration: 150, curve: Curve.Sharp, delay: 50 }),
      )
  }
}