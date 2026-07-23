import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constant';

@ComponentV2
export struct FeatureItem {
  @Param @Require icon: Resource;
  @Param @Require label: ResourceStr;
  @Param isSymbolGraph: boolean = true;
  @Event onItemClick: (context: common.UIAbilityContext) => void = () => {
  }

  // 截取前2个字符
  @Computed
  get truncateLabel(): string {
    let currentText = '';
    if (typeof this.label === 'string') {
      currentText = this.label.slice(0, 2);
    } else {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      try {
        const textValue = context.resourceManager.getStringSync(this.label.id);
        currentText = textValue.slice(0, 2);
      } catch (error) {
        hilog.error(0x00ff, 'FeatureItem', 'fail to get string sync')
      }
    }
    return currentText;
  }

  build() {
    Column({ space: Constants.SPACE_S }) {
      if (this.isSymbolGraph) {
        SymbolGlyph(this.icon)
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize(Constants.ICON_SIZE)
      } else {
        Image(this.icon)
          .width(Constants.ICON_SIZE)
          .height(Constants.ICON_SIZE)
      }
      Text(this.truncateLabel)
        .fontSize($r('sys.float.Caption_L'))
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height(Constants.EXPAND_ITEM_HEIGHT)
    .width(Constants.FULL_PERCENT)
    .padding(Constants.PADDING_XL)
    .borderRadius(Constants.RADIUS_ITEM)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onItemClick(this.getUIContext().getHostContext() as common.UIAbilityContext)
    })
  }
}