import { Constants } from 'constant';
import { SurroundingsInfoResp } from 'network';
import { CommonMap } from 'travel_map';
import { TenantInfo } from 'type';
import { Logger } from 'util';
import { HomePageVM } from '../viewmodel/HomePageVM';

@ComponentV2
export struct Surroundings {
  vm: HomePageVM = HomePageVM.instance;
  @Param @Require tenantInfo: TenantInfo;
  @Param foodList: SurroundingsInfoResp[] = [];
  @Param attractionsList: SurroundingsInfoResp[] = [];

  @Builder
  SurroundingItemBuilder(item: SurroundingsInfoResp) {
    Stack() {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.End,
        alignItems: ItemAlign.Start,
      }) {
        Column() {
          Text(item.name)
            .fontSize(12)
            .fontColor($r('sys.color.font_on_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(item.instance)
            .fontSize(10)
            .fontColor($r('sys.color.font_on_primary'))
            .margin({ top: 2 });
        }
        .backgroundColor('#4C000000')
        .padding(4)
        .borderRadius(12);
      }.zIndex(1).width(Constants.FULL_SCREEN).padding(8);

      Image(item.image).borderRadius(16);
    }.size({ width: 120, height: 120 });
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 8 }) {
        Text(`周边信息`)
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start);

        CommonMap(
          {
            travelMapOptions: {
              location: {
                latitude: Number(this.tenantInfo?.position[1]),
                longitude: Number(this.tenantInfo?.position[0]),
              },
              icon: $r('app.media.point'),
              titleOptions: {
                name: this.tenantInfo?.appName ?? '',
              },
              cameraSpeed: 1000,
              zoom: 10,
              height: 172,
              pointClickCallBack: () => {
                Logger.info('click point annotation');
              },
            },
          },
        );
      }

      if (this.foodList.length > 0) {
        Column({ space: 8 }) {
          Text(`周边美食`)
            .fontSize(18)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start);

          List({ space: 12 }) {
            ForEach(this.foodList, (item: SurroundingsInfoResp) => {
              ListItem() {
                this.SurroundingItemBuilder(item);
              };
            }, (item: SurroundingsInfoResp, index: number) => `${index}`)
          }
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .alignListItem(ListItemAlign.Start)
          .width(Constants.FULL_SCREEN);
        }
      }

      if (this.attractionsList.length > 0) {
        Column({ space: 8 }) {
          Text(`周边景点`)
            .fontSize(18)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start);

          List({ space: 12 }) {
            ForEach(this.attractionsList, (item: SurroundingsInfoResp) => {
              ListItem() {
                this.SurroundingItemBuilder(item);
              };
            }, (item: SurroundingsInfoResp, index: number) => `${index}`)
          }
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .alignListItem(ListItemAlign.Start)
          .width(Constants.FULL_SCREEN);
        }
      }
    };
  }
}
