import { Constants, NavPathName } from 'constant';
import { common, Want } from '@kit.AbilityKit';
import { TenantInfo } from 'type';
import { CommonMap } from 'mapview';

@Component
export struct MapPage {
  @State isShow: boolean = true;
  @State tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @State tiltGesturesEnabled: boolean = false;
  @Link homeTabIndex: number;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        CommonMap({
          latitude: this.tenantInfo?.position[1],
          longitude: this.tenantInfo?.position[0],
          name: this.tenantInfo?.appName,
          isShow: this.isShow,
        }).height(Constants.FULL_SCREEN);

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

            Row() {
              Button('民宿详情', { type: ButtonType.Normal })
                .backgroundColor('#007DFF')
                .fontColor($r('sys.color.font_on_primary'))
                .width(160)
                .borderRadius($r('sys.float.corner_radius_level4'))
                .fontSize($r('sys.float.Body_L'))
                .onClick(() => {
                  // 返回酒店详情页面
                  this.mainPathStack.pushPathByName(NavPathName.HOTEL, null, false);
                });
              Button('导航', { type: ButtonType.Normal })
                .backgroundColor(Color.White)
                .fontColor(Color.Black)
                .fontSize($r('sys.float.Body_L'))
                .width(160)
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
    let context = getContext(this) as common.UIAbilityContext;
    context.startAbility(petalMapWant);
  }
}
