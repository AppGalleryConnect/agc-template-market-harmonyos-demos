import { AiBarHeight, AppStorageKeys, BreakPoint, BreakPointValue, FontModel } from '@agctemplate/widgets';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * 单个Tab
 */
@ComponentV2
export struct Tab {
  @Param isFirstTimeIn: boolean = false; // 优化首次进入无弹跳效果
  @Param isSelected: boolean = false;
  @Param isDark: boolean = false;
  @Param tabHeaderInfo: TabHeaderInfo = new TabHeaderInfo(undefined!, false, undefined!);
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center
    }) {
      SymbolGlyph(this.tabHeaderInfo.icon)
        .fontSize(24)
        .fontColor(this.isSelected ? ['#EC6E45'] : [$r('sys.color.icon_primary')])

      Text(this.tabHeaderInfo.name)
        .fontColor(this.isSelected ? '#EC6E45' : $r('sys.color.font_primary'))
        .fontSize(this.fontModel.getFg(10))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .padding(4)
  }
}

export class TabHeaderInfo {
  index: number = 0;
  name: Resource;
  showSearch: boolean = false;
  icon: Resource;

  constructor(name: Resource, showSearch: boolean, icon: Resource, index?: number) {
    this.name = name;
    this.showSearch = showSearch;
    this.icon = icon;
    if (index) {
      this.index = index
    }
  }
}

