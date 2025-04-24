import { ServiceItem } from '../types';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct MainService {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      Grid() {
        ForEach(this.vm.twoPicsService, (item: ServiceItem) => {
          GridItem() {
            this.mainServiceCardBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('app.string.margin_s'))
      .rowsGap($r('app.string.margin_s'))
      .scrollBar(BarState.Off)
      .margin({
        bottom: $r('app.string.margin_s'),
      });

      Grid() {
        ForEach(this.vm.threePicsService, (item: ServiceItem) => {
          GridItem() {
            this.mainServiceCardBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap($r('app.string.margin_s'))
      .rowsGap($r('app.string.margin_s'))
      .scrollBar(BarState.Off)
      .margin({
        bottom: $r('app.string.margin_m'),
      });

      Grid() {
        ForEach(this.vm.iconServiceList, (item: ServiceItem) => {
          GridItem() {
            this.otherServiceListBuilder(item);
          };
        }, (item: ServiceItem) => JSON.stringify(item));
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap($r('app.string.margin_s'))
      .rowsGap($r('app.string.margin_s'))
      .scrollBar(BarState.Off)
      .margin({
        bottom: $r('app.string.margin_m'),
      });
    };

  }

  @Builder
  mainServiceCardBuilder(item: ServiceItem) {
    Column() {
      Image(item.image);
    }
    .onClick(() => {
      this.vm.jumpToServicePage(item.link);
    });
  }

  @Builder
  otherServiceListBuilder(item: ServiceItem) {
    Column() {
      Image(item.image)
        .width(32)
        .height(32)
        .objectFit(ImageFit.Contain)
        .margin({
          bottom: $r('app.string.margin_s'),
        });
      Text(item.title)
        .fontSize($r('app.string.font_size_24'));
    }
    .onClick(() => {
      this.vm.jumpToServicePage(item.link);
    });
  }
}