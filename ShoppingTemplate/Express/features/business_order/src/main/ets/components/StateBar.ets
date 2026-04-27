import { SymbolGlyphModifier, TextModifier } from '@kit.ArkUI';
import { TabBtnItem } from '../models/Model';
import { QueryPageVM } from '../viewModels/QueryPageVM'

@ComponentV2
export struct StateBar {
  vm: QueryPageVM = QueryPageVM.instance;
  textModifier: TextModifier = new TextModifier();
  symbolGlyphModifier: SymbolGlyphModifier = new SymbolGlyphModifier();
  @Local textWidth: number = this.getUIContext().getMeasureUtils().measureText({
    textContent: '三个字',
    fontSize: 14
  });

  aboutToAppear(): void {
    this.textWidth = this.getUIContext().px2vp(this.textWidth / 2);
    this.textModifier
      .fontSize(14)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(500)
      .lineHeight(19)
      .textAlign(TextAlign.Center)

    this.symbolGlyphModifier
      .fontSize(16)
      .fontColor([$r('sys.color.icon_primary')])
      .position({ right: '50%' })
      .translate({ x: this.textWidth + 6, y: 2 })
  }

  build() {
    Row({ space: 12 }) {
      ForEach(this.vm.tabBarList, (item: TabBtnItem, index: number) => {
        Button() {
          Text(`${item.label}${item.count}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.vm.selectedIndex === index ? Color.White : $r('sys.color.font_primary'))
        }
        .width('calc((100% - 36vp) / 4)')
        .height(36)
        .backgroundColor(this.vm.selectedIndex === index ?
          $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary')
        )
        .onClick(() => {
          this.vm.selectedIndex = index;
          this.vm.type = item.type;
          // 刷新列表
          this.vm.isRefreshing = true;
        })
      }, (item: TabBtnItem) => JSON.stringify(item))

      // 筛选框
      Select(this.vm.filterData)
        .width('calc((100% - 36vp) / 4)')
        .value(this.vm.selectedExpressStatus)
        .font({ size: $r('sys.float.Body_M'), weight: 500 })
        .fontColor($r('sys.color.font_primary'))
        .textModifier(this.textModifier)
        .arrowModifier(this.symbolGlyphModifier)
        .selectedOptionFont({ size: $r('sys.float.Body_L'), weight: 500 })
        .optionFont({ size: $r('sys.float.Body_L'), weight: 500 })
        .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
        .optionWidth(120)
        .optionHeight(300)
        .onSelect((index: number, value: string) => {
          this.vm.selectedExpressStatus = value;
          // 刷新列表
          this.vm.isRefreshing = true;
        })
        .visibility(this.vm.selectedIndex === 2 ? Visibility.Hidden : Visibility.Visible)
    }
    .width('100%')
    .padding({ top: 18, bottom: 18 })
  }
}