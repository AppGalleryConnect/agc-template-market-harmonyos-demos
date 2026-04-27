import { CommonMap } from 'travel_map';
import { phoneRouterControl } from 'oh_router';
import { BarVM, TValueType } from 'common';
import { HotelModel } from 'common_travel_guide';
import { MapPageVM } from '../viewmodel/MapPageVM';
import { common, Want } from '@kit.AbilityKit';

@Builder
export function MapPageBuilder(params: TValueType) {
  MapPage({
    pageParams: params as HotelModel
  })
}

@ComponentV2
export struct MapPage {
  vm: MapPageVM = new MapPageVM()
  @Param pageParams: HotelModel = Object()

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))

  }

  aboutToAppear(): void {
    this.getRating(this.pageParams?.star)
    this.vm.isCollect = this.pageParams.isCollect
  }

  getRating(str: string) {
    switch (str) {
      case '二星':
        this.vm.rating = '2星级'
        break;
      case '三星':
        this.vm.rating = '3星级'
        break;
      case '四星':
        this.vm.rating = '4星级'
        break;
      default:
        this.vm.rating = '5星级'
        break;
    }
    return this.vm.rating
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        CommonMap(
          {
            travelMapOptions: {
              location: {
                latitude: 31.968,
                longitude: 118.799,
              },
              icon: $r('app.media.point'),
              titleOptions: {
                name: this.pageParams?.name,
                strokeColor: 0xFFFFFFFF,
              },
              cameraSpeed: 1000,
              zoom: 10,
              height: '100%',
              pointClickCallBack: () => {
                this.vm.showTips = !this.vm.showTips
              },
            },
          });
        if (this.vm.showTips) {
          Column() {
            this.BottomBuilder()
          }.padding({ left: 16, right: 16 }).width('100%').margin({ bottom: 16 })
        }
      }

      Row() {
        Image($r('app.media.ic_back_black')).width(40).height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })
        Text('旅游地图')
          .fontSize(20)
          .fontColor('#000000')
          .fontWeight(500)
          .margin({ left: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.width('100%').margin({ top: BarVM.instance.staBarH, left: 16 })
    }

  }

  //底部卡片
  @Builder
  BottomBuilder() {
    Column() {
      Row() {
        Image($r('app.media.ic_map_hotel')).width(77).height(103).borderRadius(10)
        Column() {
          Text(this.pageParams?.name).fontColor('#333333').fontSize(13).fontWeight(700)
          Row() {
            Text(this.vm.rating)
              .fontSize(11)
              .fontColor('#333333')
              .padding(2)
              .backgroundColor('#FECC41')
              .borderRadius(7)
            Text(this.pageParams?.distance).fontSize(11).fontColor('#666666').margin({ left: 6 })
          }.alignItems(VerticalAlign.Center).margin({ top: 8 })

          Row({ space: 2 }) {
            ForEach(this.pageParams?.facility, (facility: string, index: number) => {
              Text(facility)
                .fontSize(10)
                .fontColor('#35619A')
                .backgroundColor('#F3F3F3')
                .padding({
                  top: 2,
                  bottom: 2,
                  left: 4,
                  right: 4
                })
                .borderColor('#E1E1E1')
                .borderWidth(0.5)
                .borderRadius(4)
            }, (facility: string) => JSON.stringify(facility))
          }.margin({ top: 8 })
        }.alignItems(HorizontalAlign.Start).margin({ left: 6 })
      }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row({ space: 4 }) {
          Image(this.vm.isCollect ? $r('app.media.ic_collect') : $r('app.media.ic_uncollect'))
            .width(22)
            .height(22)
          Text(this.vm.isCollect ? '已收藏' : '收藏').fontSize(11).fontColor('#333333')
        }.width('50%').justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.vm.isCollect = !this.vm.isCollect
          this.pageParams.isCollect = this.vm.isCollect
        })

        Row({ space: 4 }) {
          Image($r('app.media.ic_navigation')).width(22).height(22)
          Text('导航').fontSize(11).fontColor('#333333')
        }.width('50%').justifyContent(FlexAlign.Center)
        .onClick(() => {
          let petalMapWant: Want = {
            bundleName: 'com.huawei.hmos.maps.app',
            uri: 'maps://',
            parameters: {
              linkSource: 'com.huawei.travelguide',
              destinationLatitude: 31.968,
              destinationLongitude: 118.799,
              destinationName: this.pageParams.name,
              vehicleType: 0,
            }
          }
          let context = getContext(this) as common.UIAbilityContext;
          context.startAbility(petalMapWant);
        })
      }.height(42).width('100%')

    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(10)
  }
}
