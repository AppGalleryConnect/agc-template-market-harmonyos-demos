import { Constant, LazyDataSource } from 'common';
import { SwiperComponent, TitleBar } from 'components';
import { AttractionInfo } from 'types';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function AttractionsBuilder() {
  Attractions();
}

@ComponentV2
export struct Attractions {
  vm: HomePageVM = HomePageVM.instance;
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  AttractionItemBuilder(attraction: AttractionInfo) {
    Row() {
      Image(attraction.banner).size({ width: 96, height: 96 }).borderRadius(8);
      Column() {
        Text(attraction.name).fontWeight(500);
        Row() {
          ForEach(attraction.labels, (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#2EB78A' })
              .padding(2)
              .fontColor('#2EB78A')
              .margin({ right: 4 });
          }, (item: string) => item);
        }.margin({ top: 4, bottom: 8 });

        Row() {
          ForEach(attraction.detailImages, (item: ResourceStr) => {
            Image(item).size({ height: 48, width: 48 }).borderRadius(8).margin({ right: 8 });
          }, (item: ResourceStr) => item.toString());
        };
      }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).margin({ left: 8 });
    }.onClick(() => {
      this.mainPathStack.pushPathByName('AttractionDetail', attraction.attractionId);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '景点列表', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          Column() {
            SwiperComponent(this.vm.attractionListBanner);

            Column() {
              List({ space: 12 }) {
                LazyForEach(this.vm.attractionList, (item: AttractionInfo) => {
                  this.AttractionItemBuilder(item);
                });
              };
            }.padding(12);
          };
        }.height('90%').align(Alignment.Top).scrollBar(BarState.Off);
      };
    }.hideTitleBar(true);
  }
}