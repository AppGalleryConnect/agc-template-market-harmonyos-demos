import { Constant } from 'common';
import { FullLoadingComponent, SwiperComponent } from 'uicomponents';
import { AttractionLive } from 'attraction_live';
import { FunctionModuleData, getFunctionModuleInfo } from '../model/FunctionModuleInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';
import { getHotAreaInfo, HotAreaInfo } from '../model/HotAreaInfo';

@Builder
export function HomeBuilder() {
  HomeView();
}

@Extend(Row)
function realTimeRow() {
  .justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
}

@ComponentV2
export struct HomeView {
  vm: HomePageVM = HomePageVM.instance;
  @Local isShow: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  FunctionModuleBuilder() {
    Row() {
      ForEach(getFunctionModuleInfo(this.mainPathStack), (item: FunctionModuleData) => {
        Column() {
          Image(item.icon).size({ width: 48, height: 48 });
          Text(item.title).fontSize(12).margin({ top: 4 });
        }.onClick(item.click);
      }, (item: FunctionModuleData) => JSON.stringify(item));
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'))
    .padding(16)
    .borderRadius(8);
  }

  @Builder
  HotInfoBuilder(itemName: string, component: WrappedBuilder<[]>, routeEvent: (event: ClickEvent) => void) {
    Column() {
      Row() {
        Text(itemName).fontWeight(700).fontSize(18);
        Row() {
          Text('更多');
          Image($r('app.media.chevron_right')).size({ width: 12, height: 12 });
        }.onClick(routeEvent);
      }.realTimeRow().margin({ bottom: 8 });

      component.builder();
    }.margin({ top: 24 });
  }

  @Builder
  ScenicInfoBuilder() {
    Row() {
      // 展示首条
      Text(`${this.vm.bulletinList.getData(0)?.title ?? '查看公告'}`)
        .fontColor('rgb(43, 112, 80)')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%');
      Image($r('app.media.chevron_right')).size({ width: 12, height: 12 });
    }
    .onClick(() => {
      this.mainPathStack.pushPathByName('Bulletins', null, false);
    })
    .padding(12)
    .backgroundColor('#E3EDE6')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  aboutToAppear(): void {
    this.vm.getBulletinList();
  }

  build() {
    NavDestination() {
      if (this.vm.isLoading) {
        FullLoadingComponent();
      } else {
        List() {
          ListItem() {
            SwiperComponent(this.vm.scenicImages);
          };

          ListItem() {
            Column() {
              this.ScenicInfoBuilder();
              this.FunctionModuleBuilder();

              AttractionLive({ attractionLiveInfo: this.vm.attractionLiveInfo });
              ForEach(getHotAreaInfo(this.mainPathStack), (item: HotAreaInfo) => {
                this.HotInfoBuilder(item.itemTitle, item.component, item.routeEvent);
              }, (item: HotAreaInfo) => JSON.stringify(item.itemTitle));
            }.padding(12)
          };
        }
        .backgroundColor('#F1F3F5')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
    }.hideTitleBar(true);
  }
}