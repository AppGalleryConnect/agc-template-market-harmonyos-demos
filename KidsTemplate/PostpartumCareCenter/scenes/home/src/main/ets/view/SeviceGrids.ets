import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { SERVICE_LIST } from '../constants/Constants';
import { ServiceGridItem } from '../model/ServiceGridItem';

@Preview
@ComponentV2
export struct ServiceGrids {
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Grid() {
      ForEach(SERVICE_LIST, (item: ServiceGridItem, index: number) => {
        GridItem() {
          Column() {
            Image(item.icon)
              .width(40)
              .height(40)
              .objectFit(ImageFit.Cover);
            Text(item.label)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.string.font_size_12'))
              .fontColor('rgba(0, 0, 0, 0.9)')
              .margin({ top: $r('app.string.margin_xxs') });
          };
        }
        .width(68)
        .onClick(() => {
          this.vm.navStack.pushPathByName('ServiceDetail', item.label);
        });
      }, (item: ServiceGridItem) => JSON.stringify(item));
    }
    .columnsGap(8) // 设置列间距
    .rowsGap(16) // 设置行间距
    .padding({
      top: $r('app.string.padding_12'),
      bottom: $r('app.string.padding_12'),
      right: $r('app.string.padding_16'),
      left: $r('app.string.padding_16')
    })
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor('#FFFFFF')
    .width('100%');
  }
}