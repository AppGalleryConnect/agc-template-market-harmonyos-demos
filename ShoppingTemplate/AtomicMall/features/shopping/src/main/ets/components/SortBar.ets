import { SortTypeMap } from '../commons/Enums';

@ComponentV2
export struct SortBar {
  // 排序类型
  @Local
  sortType: SortTypeMap = SortTypeMap.DEFAULT;
  @Event
  handleSortTypeChange:(type:SortTypeMap)=>void = ()=>{}

  build() {
    Row({ space: 8 }) {
      Text('默认')
        .sortLabelStyle(this.isSortActive([SortTypeMap.DEFAULT]))
        .onClick(() => {
          this.switchSortType(SortTypeMap.DEFAULT);
        });
      Row() {
        Text('价格')
          .sortLabelStyle(this.isSortActive([SortTypeMap.PRICE_LOW_TO_HIGH,
            SortTypeMap.PRICE_HIGH_TO_LOW]));
        Column() {
          Image($r('app.media.ic_triangle_up'))
            .sortIconStyle(this.isSortActive([SortTypeMap.PRICE_LOW_TO_HIGH]));
          Image($r('app.media.ic_triangle_down'))
            .sortIconStyle(this.isSortActive([SortTypeMap.PRICE_HIGH_TO_LOW]));
        };
      }
      .onClick(() => {
        if(this.sortType === SortTypeMap.PRICE_LOW_TO_HIGH){
          this.switchSortType(SortTypeMap.PRICE_HIGH_TO_LOW)
        }else{
          this.switchSortType(SortTypeMap.PRICE_LOW_TO_HIGH);
        }
      });

      Text('销量')
        .sortLabelStyle(this.isSortActive([SortTypeMap.SALE]))
        .onClick(() => {
          this.switchSortType(SortTypeMap.SALE);
        });
    }
  }

  isSortActive(type: SortTypeMap[]) {
    return type.some((item) => item === this.sortType)
  }

  switchSortType(type: SortTypeMap) {
    this.sortType = type;
    this.handleSortTypeChange?.(type);
  }
}

@Extend(Text)
function sortLabelStyle(isActive: boolean) {
  .fontColor(isActive ? $r('app.color.font_color_level1') : $r('app.color.font_color_level3'))
  .fontSize($r('app.float.font_size_14'))
  .margin({ left: $r('app.float.space_m') });
}

@Extend(Image)
function sortIconStyle(isActive: boolean) {
  .width(12)
  .height(8)
  .fillColor(isActive ? $r('app.color.font_color_level1') : $r('app.color.font_color_level3'));
}