import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { ISelectOption, SettingItem } from '../types/SettingItem';
import { CustomTouchItem } from '../common/CustomModifier';
import { FontModel } from '../models/FontModel';

@ComponentV2
export struct SettingSelectPop {
  @Require @Param item: SettingItem;
  @Local touchItem: CustomTouchItem = new CustomTouchItem();
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      List() {
        ForEach((this.item.selectOptions ?? []), (option: ISelectOption, index: number) => {
          ListItem() {
            Row() {
              Text(option.label)
                .fontSize(this.fontModel.getFg(16, 1.3))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxFontScale(1.45)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize($r('app.float.normal_img_size'))
                .fontColor([$r('sys.color.font_primary')])
                .margin({
                  left: CommonConstants.PADDING_XS,
                })
                .visibility(this.item.selectIndex === index ? Visibility.Visible : Visibility.Hidden)
            }
            .width(CommonConstants.FULL_PERCENT)
            .borderRadius($r('app.float.large_radius'))
            .padding(CommonConstants.PADDING_M)
            .attributeModifier(this.touchItem)
            .onClick(() => {
              this.item.setSelectIndex(index);
              if (this.item.onSelect) {
                this.item.onSelect(index);
              }
              if (this.item.autoClose) {
                this.item.setShowPop(false);
              }
            })
          }
        }, (option: ISelectOption) => option.id + option.label)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider'),
        startMargin: CommonConstants.PADDING_S,
        endMargin: CommonConstants.PADDING_S,
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}
