import { BalanceChangeType } from '../commons/Enums';
import { BalanceResourceModel, BalanceResourceItemModel } from '../commons/Models';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';

const NO_FILTER_TYPE = -1;

@ComponentV2
export struct TypeFilterSheet {
  @Param
  resource: BalanceResourceModel = new BalanceResourceModel();
  @Param
  initResource: number = NO_FILTER_TYPE;
  @Local
  checkedResource: number = NO_FILTER_TYPE;
  @Local
  checkedType: BalanceChangeType = BalanceChangeType.EXPENSE;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Event
  handleCancel: () => void;
  @Event
  handleConfirm: (type: BalanceChangeType, key: number) => void;

  @Computed
  get typeGridTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr 1fr 1fr'
    }
    return '1fr 1fr 1fr 1fr 1fr 1fr'
  }

  aboutToAppear(): void {
    if (this.initResource) {
      this.checkedResource = this.initResource;
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('全部类型')
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level1'));
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius($r('app.string.border_radius_capsule'))
          .width(76)
          .padding({
            top: $r('app.string.space_s'),
            bottom: $r('app.string.space_s'),
          })
          .margin({ bottom: $r('app.string.space_l') })
          .backgroundColor(this.getItemBackground(-1))
          .onClick(() => {
            this.checkedResource = NO_FILTER_TYPE;
          });


          this.typeGroupBuilder(BalanceChangeType.EXPENSE, Array.from(this.resource.expense));

          this.typeGroupBuilder(BalanceChangeType.INCOME, Array.from(this.resource.income));
        }
        .alignItems(HorizontalAlign.Start);
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Blank();
      Flex() {
        Button('取消')
          .backgroundColor($r('app.color.system_color_background_grey_level2'))
          .fontColor($r('sys.color.font_primary'))
          .flexGrow(1)
          .onClick(() => {
            this.handleCancel?.();
          });
        Blank().width($r('app.string.space_m'));
        Button('确定')
          .backgroundColor($r('app.color.system_theme_color'))
          .flexGrow(1)
          .onClick(() => {
            this.handleConfirm?.(this.checkedType, this.checkedResource);
          });
      }
      .width($r('app.string.width_percent_full'))
      .margin({ bottom: $r('app.string.space_l') })
    }
    .padding($r('app.string.space_l'))
    .height($r('app.string.height_percent_full'));
  }

  @Builder
  typeGroupBuilder(type: BalanceChangeType, list: BalanceResourceItemModel[]) {
    Column() {
      Text(type === BalanceChangeType.INCOME ? '收入' : '支出')
        .fontSize($r('app.string.font_size_16'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'))
        .margin({ bottom: $r('app.string.space_m') });
      Grid() {
        ForEach(list, (item: BalanceResourceItemModel) => {
          GridItem() {
            Text(item.name)
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level1'));
          }
          .backgroundColor(this.getItemBackground(item.key))
          .width(76)
          .padding({
            top: $r('app.string.space_s'),
            bottom: $r('app.string.space_s'),
          })
          .borderRadius($r('app.string.border_radius_capsule'))
          .onClick(() => {
            this.checkedType = type;
            this.checkedResource = item.key;
          });
        }, (item: BalanceResourceItemModel) => item.key + '__' + item.name);
      }
      .columnsTemplate(this.typeGridTemplate)
      .columnsGap($r('app.string.space_s'))
      .rowsGap($r('app.string.space_s'));
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: $r('app.string.space_xl') });

  }

  getItemBackground(key: number) {
    if (key === this.checkedResource) {
      return '#6694b982';
    }
    return $r('app.color.system_color_background_grey_level2');
  }
}