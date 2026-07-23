import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointNameEnum } from '../common/GridRowColSetting';
import { BreakpointModel } from '../models/BreakpointModel';
import { CustomConfigModel } from '../models/CustomConfigModel';
import { FontModel } from '../models/FontModel';
import { SettingItem } from '../types/SettingItem';
import { SettingType } from '../types/SettingType';
import { SettingSelectPop } from './SettingSelectDialog';
import { CustomTouchItem } from '../common/CustomModifier';

@ComponentV2
export struct SettingCard {
  @Param title: ResourceStr = '';
  @Param list: SettingItem[] = [];
  @Param titleSize: number = 14;
  @Param labelSize: number = 16;
  @Param subLabelSize: number = 12;
  @Param textSize: number = 14;
  @Param enableLaneSetting: boolean = false;
  @Local configInfo: CustomConfigModel = AppStorageV2.connect(CustomConfigModel, () => new CustomConfigModel())!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local touchItem: CustomTouchItem = new CustomTouchItem();

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(this.fontModel.getFg(this.titleSize))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.PADDING_M,
        right: CommonConstants.PADDING_M,
        top: CommonConstants.PADDING_L,
        bottom: CommonConstants.PADDING_S,
      })
      .visibility(this.title ? Visibility.Visible : Visibility.None)

      List() {
        ForEach(this.list, (v: SettingItem) => {
          ListItem() {
            Row() {
              Column({ space: CommonConstants.SPACE_XXS }) {
                Text(v.label)
                  .fontSize(this.fontModel.getFg(this.labelSize))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start)
                Text(v.subLabel)
                  .fontSize(this.fontModel.getFg(this.subLabelSize))
                  .fontColor($r('sys.color.font_secondary'))
                  .visibility(v.subLabel ? Visibility.Visible : Visibility.None)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .accessibilityGroup(true)

              Row() {
                if (v.type === SettingType.SWITCH) {
                  this.toggleScene(v)
                } else if (v.type === SettingType.SELECT) {
                  this.selectScene(v)
                } else {
                  this.normalScene(v)
                }
              }
              .justifyContent(FlexAlign.End)
              .margin({
                left: CommonConstants.PADDING_L,
              })
            }
            .padding({
              top: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_M,
              left: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_S,
            })
            .constraintSize({ minHeight: 48 })
            .borderRadius($r('app.float.large_radius'))
            .attributeModifier(this.touchItem)
            .accessibilityLevel(v.type === SettingType.SWITCH ? 'no' : 'auto')
            .onTouchIntercept(() => {
              if (v.type === SettingType.SWITCH) {
                return HitTestMode.None;
              }
              if (v.type === SettingType.SELECT) {
                return HitTestMode.None;
              }
              return HitTestMode.Default;
            })
            .onClick(() => {
              // 自定义点击事件优先级最高
              if (v.onClick) {
                v.onClick();
                return;
              }
              if (v.routerParam?.routerName) {
                this.configInfo.pathStack.pushPathByName(v.routerParam?.routerName, v.routerParam?.routerParams,
                  v.routerParam?.onPop, v.routerParam?.animated);
              }
            })
          }
        }, (v: SettingItem) => v.id)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height('auto')
      .lanes(this.listLanes)
      .borderRadius($r('app.float.xl_radius'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(CommonConstants.PADDING_XS)
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider'),
        startMargin: CommonConstants.PADDING_M,
        endMargin: CommonConstants.PADDING_M,
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  toggleScene(v: SettingItem) {
    Toggle({ type: ToggleType.Switch, isOn: v.switchV })
      .selectedColor(this.configInfo.themeColor)
      .onTouchIntercept(() => {
        if (v.onClick) {
          v.onClick(!v.switchV);
        }
        return HitTestMode.None;
      })
  }

  @Builder
  selectScene(v: SettingItem) {
    Row() {
      Text(this.getSelectLabel(v))
        .fontSize(this.fontModel.getFg(this.textSize))
        .fontColor($r('sys.color.font_secondary'))
        .maxFontScale(1.3)
        .constraintSize({ maxWidth: CommonConstants.HALF_PERCENT })
      SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
        .fontSize($r('app.float.small_img_size'))
        .fontColor([$r('sys.color.font_fourth')])
        .margin({ left: CommonConstants.SPACE_XS })
    }
    .onClick(() => {
      v.setShowPop(true);
    })
    .bindPopup(v.showPop, {
      builder: this.selectDialog(v),
      enableArrow: false,
      autoCancel: true,
      placement: Placement.BottomRight,
      width: 224,
      offset: {
        x: 12,
        y: 8,
      },
      onWillDismiss: () => {
        v.setShowPop(false);
      },
    })
  }

  @Builder
  selectDialog(v: SettingItem) {
    SettingSelectPop({
      item: v,
    })
  }

  @Builder
  normalScene(v: SettingItem) {
    Text(v.normalText)
      .fontSize(this.fontModel.getFg(this.textSize))
      .fontColor($r('sys.color.font_secondary'))
      .maxFontScale(1.3)
      .constraintSize({ maxWidth: CommonConstants.HALF_PERCENT })
      .visibility(v.normalText ? Visibility.Visible : Visibility.None)
    SymbolGlyph($r('sys.symbol.chevron_right'))
      .fontSize($r('app.float.normal_img_size'))
      .fontColor([$r('sys.color.font_fourth')])
      .margin({ left: CommonConstants.SPACE_XS })
  }

  getSelectLabel(v: SettingItem) {
    if (v.selectOptions?.length) {
      return v.selectOptions[v.selectIndex ?? 0]?.label || '';
    }
    return '';
  }

  @Computed
  get listLanes() {
    if (!this.enableLaneSetting) {
      return 1;
    }
    if ([BreakpointNameEnum.SM,
      BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 1;
    }
    return 2;
  }
}
