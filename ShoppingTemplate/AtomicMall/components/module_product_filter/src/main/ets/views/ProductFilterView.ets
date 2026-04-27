import { FilterSelectionItemModel, FilterSelectionListModel } from '../commons/Models'
import { FilterOptionItem, FilterSelectionItem, FilterTypeInterface, ProductFilterOptions } from '../commons/Types'

@Builder
export function buildProductFilter(options?: ProductFilterOptions) {
  ProductFilterView({
    filterTypeList: options?.filterTypeList,
    initFilter: options?.initFilter,
    handleConfirm: options?.handleConfirm,
  })
}

@ComponentV2
struct ProductFilterView {
  @Param
  initFilter: FilterSelectionItem[] = []
  @Param
  filterTypeList: FilterTypeInterface[] = []
  @Event
  handleConfirm: (res: FilterSelectionItem[]) => void = () => {
  }
  @Local
  result: FilterSelectionListModel = new FilterSelectionListModel()

  aboutToAppear(): void {
    this.reset(this.initFilter)
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          ForEach(this.filterTypeList, (type: FilterTypeInterface) => {
            this.buildFilterType(type)
          }, (type: FilterTypeInterface) => type.id)
        }
        .layoutWeight(1)
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .margin({ bottom: 16 })

      Flex() {
        Button('重置')
          .flexGrow(1)
          .backgroundColor($r('app.color.background_color_button_grey'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.reset()
          })
        Blank().width(16)
        Button('确定')
          .flexGrow(1)
          .backgroundColor($r('app.color.theme_color'))
          .onClick(() => {
            const result: FilterSelectionItem[] = this.result.list.map((item) => {
              return {
                id: item.id,
                value: item.value,
              } as FilterSelectionItem
            })
            this.handleConfirm?.(result)
          })
      }
      .width($r('app.string.size_percent_full'))
      .margin({ bottom: $r('app.float.space_l') })
    }
    .height('100%')
    .padding($r('app.float.space_l'))
  }

  @Builder
  buildFilterType(type: FilterTypeInterface) {
    Column() {
      Text(type.label)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.space_l') })

      Grid() {
        ForEach(type.options, (item: FilterOptionItem) => {
          GridItem() {
            if (!type.mutiple) {
              Radio({ value: item.label, group: type.id })
                .contentModifier(new MyRadioStyle())
                .checked(this.isRadioChecked(type, item.key))
                .margin(0)
                .onChange((res) => {
                  if (res) {
                    const idx = this.result.list.findIndex((it) => it.id === type.id)
                    if (idx >= 0) {
                      this.result.list[idx].value = [item.key];
                    }
                  }
                })
            } else {
              Checkbox({ name: item.label, group: type.id })
                .contentModifier(new MyCheckBoxStyle())
                .margin(0)
                .select(this.isCheckBoxSelected(type, item.key))
                .onChange((res) => {
                  const idx = this.result.list.findIndex((it) => it.id === type.id)
                  if (idx < 0) {
                    return;
                  }
                  if (!res) {
                    this.result.list[idx].value = this.result.list[idx].value.filter((str) => str !== item.key)
                  }
                  if (res && !this.result.list[idx].value.includes(item.key)) {
                    this.result.list[idx].value.push(item.key);
                  }
                })
            }
          }
        }, (item: FilterOptionItem) => item.key + item.label)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
    }
    .width($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
  }

  isRadioChecked(type: FilterTypeInterface, value: string) {
    const group = this.result.list.find((item) => item.id === type.id)
    if (group) {
      return group.value[0] === value;
    }
    return false;
  }

  isCheckBoxSelected(type: FilterTypeInterface, value: string) {
    const group = this.result.list.find((item) => item.id === type.id)
    if (group) {
      return group.value.includes(value);
    }
    return false;
  }

  reset(initOption?: FilterSelectionItem[]) {
    this.result.list = []
    this.filterTypeList.forEach((type) => {
      const id = type.id;
      const value = initOption?.find((item) => item.id === id)?.value;
      this.result.list.push(new FilterSelectionItemModel(type.id, value ?? [type.options[0].key]))
    })
  }
}

class MyRadioStyle implements ContentModifier<RadioConfiguration> {
  public applyContent(): WrappedBuilder<[RadioConfiguration]> {
    return wrapBuilder(buildRadio);
  }
}

class MyCheckBoxStyle implements ContentModifier<CheckBoxConfiguration> {
  public applyContent(): WrappedBuilder<[CheckBoxConfiguration]> {
    return wrapBuilder(buildCheckBox);
  }
}

@Builder
function buildRadio(config: RadioConfiguration) {
  Row() {
    Text(config.value)
      .fontSize($r('app.float.font_size_14'))
      .fontColor(config.checked ? $r('app.color.font_color_level1_invert') : $r('app.color.font_color_level1'));
  }
  .optionButtonStyle(config.checked)
  .onClick(() => {
    if (!config.checked) {
      config.triggerChange(true);
    }
  });
}

@Builder
function buildCheckBox(config: CheckBoxConfiguration) {
  Row() {
    Text(config.name)
      .fontSize($r('app.float.font_size_14'))
      .fontColor(config.selected ? $r('app.color.font_color_level1_invert') : $r('app.color.font_color_level1'));
  }
  .optionButtonStyle(config.selected)
  .onClick(() => {
    config.triggerChange(!config.selected)
  });
}

@Extend(Row)
function optionButtonStyle(selected: boolean) {
  .justifyContent(FlexAlign.Center)
  .padding({
    top: $r('app.float.space_xs'),
    bottom: $r('app.float.space_xs'),
    left: $r('app.float.space_m'),
    right: $r('app.float.space_m'),
  })
  .height(36)
  .width('100%')
  .borderRadius($r('app.float.border_radius_xl'))
  .backgroundColor(selected ? $r('app.color.theme_color') :
    $r('app.color.background_color_button_grey'))
}