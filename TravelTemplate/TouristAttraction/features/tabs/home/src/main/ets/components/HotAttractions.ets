import { Constant } from 'common';
import { AttractionInfo } from 'types';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotAttractionsBuilder() {
  HotAttractions();
}

@ComponentV2
export struct HotAttractions {
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      List({ space: 12 }) {
        LazyForEach(this.vm.hotAttractionList, (item: AttractionInfo) => {
          ListItem() {
            Stack() {
              Image(item.banner).size({ width: 100, height: 80 }).borderRadius(8);
              Text(item.name).fontColor(Color.White).fontWeight(500);
            };
          }.onClick(() => {
            this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
          });
        });
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width(Constant.FULL_PERCENT)
      .align(Alignment.Start)
      .edgeEffect(EdgeEffect.Spring);
    }.height(80).backgroundColor('#F1F3F5');
  }
}