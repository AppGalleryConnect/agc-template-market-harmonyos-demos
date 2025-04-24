import { MainEntryVM, StoreCard, StoreModel } from '@ohos_agcit/postpartum_care_center_uicomponents';

@Preview
@ComponentV2
export struct StoreList {
  @Param cityName: string = '';
  @Param cityId: string = '';
  vm: MainEntryVM = MainEntryVM.instance;

  build() {
    Column() {

      Scroll() {
        List({ space: 12 }) {
          if (this.cityName === '附近') {
            ForEach(this.vm.storeList.storeList, (item: StoreModel) => {
              ListItem() {
                StoreCard({ store: item });
              };
            }, (item: StoreModel) => JSON.stringify(item));
          } else {
            ForEach(this.vm.storeList.storeList, (item: StoreModel) => {
              if (item.city === this.cityName) {
                ListItem() {
                  StoreCard({ store: item });
                };
              }
            }, (item: StoreModel) => JSON.stringify(item));
          }
        }
        .padding({
          left: $r('app.string.padding_16'),
          right: $r('app.string.padding_16'),
          top: $r('app.string.padding_8'),
          bottom: $r('app.string.padding_8'),
        });
      }
      .width('100%')
      .height('auto');

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }

}