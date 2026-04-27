import { Language } from '../model/LanguageModel';
import { LanguageListConstants, IconSizeConstants } from '../constants/LanguageConstants';

/**
 * @usage: 语言列表项组件，用于展示单个语言选项。支持语言名称显示、VIP图标标识、选中状态指示。
 * 主要数据结构包括Language（语言模型）、isSelected（选中状态）、isVipUser（VIP用户标识）。
 * 包含if逻辑判断VIP图标和选中指示器显示。
 * @layout: 组件采用Row横向布局。左侧Row包含语言名称Text和VIP图标Image（可选），右侧为选中指示器SymbolGlyph（可选）。
 * @constraints: 无
 * @fileType: component
 * @isGen: true
 * @zhName: 语言列表项组件
 * @image: screenshot/translate/LanguageListItem.jpg
 */
@ComponentV2
export struct LanguageListItem {
  @Require @Param language: Language = {} as Language;
  @Require @Param isSelected: boolean = false;
  @Param isVipUser: boolean = false;
  @Param onSelect?: (language: Language) => void = undefined;

  build() {
    Row() {
      // 语言名称和VIP图标
      Row({ space: 8 }) {
        Text(this.language.name)
          .fontSize(LanguageListConstants.ITEM_FONT_SIZE)
          .fontColor($r('sys.color.font_primary'))

        // VIP图标：VIP语言始终显示图标
        if (this.language.isVip) {
          Image($r('app.media.VIP'))
            .width(LanguageListConstants.VIP_ICON_WIDTH)
            .height(LanguageListConstants.VIP_ICON_HEIGHT)
            .objectFit(ImageFit.Contain)
        }
      }
      .layoutWeight(1)

      // 选中指示器
      if (this.isSelected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(IconSizeConstants.CHECKMARK_ICON_SIZE)
          .fontColor([$r('sys.color.icon_emphasize')])
      }
    }
    .width('100%')
    .height(LanguageListConstants.ITEM_HEIGHT)
    .padding({ left: 0, right: 0 })
    .onClick(() => {
      this.handleSelect();
    })
  }

 //处理选择
  private handleSelect(): void {
    if (this.onSelect) {
      this.onSelect(this.language);
    }
  }
}
