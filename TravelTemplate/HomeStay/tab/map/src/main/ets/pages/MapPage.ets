import { Constants, NavPathName } from 'constant';
import { common, Want } from '@kit.AbilityKit';
import { TenantInfo } from 'type';
import { CommonMap } from 'travel_map';

@ComponentV2
export struct MapPage {
  @Local isShow: boolean = true;
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Local tiltGesturesEnabled: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
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
                strokeColor: 0xFFFFFFFF,
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

        if (this.isShow) {
          Column() {
            Flex() {
              Text(`${this.tenantInfo?.appName}`).fontSize(18).fontWeight(500);
            };

            Text(`${this.tenantInfo?.introduction}`)
              .fontSize(12)
              .fontColor(Color.Gray)
              .margin({ top: 16 })
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Row({ space: 12 }) {
              Button('民宿详情', { type: ButtonType.Normal })
                .backgroundColor('#007DFF')
                .layoutWeight(1)
                .fontColor($r('sys.color.font_on_primary'))
                .borderRadius($r('sys.float.corner_radius_level4'))
                .fontSize($r('sys.float.Body_L'))
                .onClick(() => {
                  // 返回酒店详情页面
                  this.mainPathStack.pushPathByName(NavPathName.HOTEL, null, false);
                });
              Button('导航', { type: ButtonType.Normal })
                .backgroundColor(Color.White)
                .fontColor(Color.Black)
                .layoutWeight(1)
                .fontSize($r('sys.float.Body_L'))
                .border({ width: 1, color: Color.Black, radius: $r('sys.float.corner_radius_level4') })
                .onClick(() => {
                  // 跳转到花瓣地图导航
                  this.routeToPetal();
                });
            }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ top: 16 });
          }
          .width(Constants.FULL_SCREEN)
          .height(160)
          .backgroundColor(Color.White)
          .padding(16)
          .borderRadius({ topLeft: 8, topRight: 8 })
          .gesture(
            // 绑定滑动手势且限制仅在竖直方向滑动时触发
            SwipeGesture({ direction: SwipeDirection.Vertical })
              .onAction((event: GestureEvent) => {
                if (event) {
                  this.isShow = false;
                }
              }),
          )
          .transition(TransitionEffect.OPACITY.animation({ duration: 500, curve: Curve.Ease }));
        }
      };
    }.hideTitleBar(true);
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
    context.startAbility(petalMapWant);
  }
}
