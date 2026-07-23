import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Constants, NavPathName } from 'constant';
import { TenantInfo } from 'type';
import { CommonMap } from 'travel_map';
import { CommonHeader } from 'component';
import { ColorMetrics } from '@kit.ArkUI';

@ComponentV2
export struct MapPage {
  @Local isShow: boolean = false;
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  hotelDetailSheetBuilder() {
    Column() {
      Text(`${this.tenantInfo?.appName}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width(Constants.FULL_SCREEN)
        .margin({ top: 10, bottom: 20 });

      Column() {
        Text(`${this.tenantInfo?.introduction}`)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(19)
      }
      .width(Constants.FULL_SCREEN)
      .padding(12)
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_primary'));

      Row({ space: 12 }) {
        Button('民宿详情', { type: ButtonType.Normal })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .layoutWeight(1)
          .height(36)
          .fontColor($r('sys.color.font_primary'))
          .borderRadius($r('sys.float.corner_radius_level10'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.isShow = false;
            this.mainPathStack.pushPathByName(NavPathName.HOTEL_HOME, null, false);
          });
        Button({ type: ButtonType.Normal }) {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.location_north_up_right_fill'))
              .fontColor([$r('sys.color.font_on_primary')])
              .fontWeight(FontWeight.Medium)
              .width(16)
              .height(16)
            Text('导航')
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
          }
        }
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .layoutWeight(1)
          .height(36)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .onClick(() => {
            this.routeToPetal();
          });
      }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ top: 24, bottom: 36 });
    }
    .width(Constants.FULL_SCREEN)
    .padding(16)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
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
                height: '100%',
                pointClickCallBack: () => {
                  this.isShow = true;
                },
              },
            },
          );
          CommonHeader({ title: '地图' })
        }.layoutWeight(1)
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .bindSheet($$this.isShow, this.hotelDetailSheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        backgroundColor: $r('sys.color.background_secondary'),
        showClose: true,
        dragBar: true,
      })
    }.hideTitleBar(true)
  }

  routeToPetal() {
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: 'com.atomicservice.5765880207855657821',
        destinationLatitude: Number(this.tenantInfo?.position[1]) ?? 0,
        destinationLongitude: Number(this.tenantInfo?.position[0]) ?? 0,
        destinationName: this.tenantInfo?.appName ?? '',
      },
    };
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.startAbility(petalMapWant).catch((err: BusinessError) => {
      UtilLog.error(`startAbility error ${err}`);
    });
  }
}
