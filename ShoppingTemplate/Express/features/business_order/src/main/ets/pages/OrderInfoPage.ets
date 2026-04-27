import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM';
import { MapComponent } from '@kit.MapKit';
import { CommonLoading, Logger } from 'module_base';
import { ExpressStatus } from 'lib_foundation';
import { OrderBar } from '../components/OrderBar';
import { LogisticInfo } from '../components/LogisticInfo';
import { CourierCard } from '../components/CourierCard';

@Builder
export function OrderInfoPageBuilder() {
  OrderInfoPage()
}

@Entry
@ComponentV2
struct OrderInfoPage {
  vm: OrderInfoPageVM = OrderInfoPageVM.instance
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down })

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext()
    this.vm.init(
      () => {
        this.customInfoWindowBuilder('始发地', this.vm.orderInfo!.sendPosition)
      },
      () => {
        this.customInfoWindowBuilder(this.vm.orderInfo?.expressStatus === ExpressStatus.SIGNED_FOR ? '已签收' :
          ' 签收地', this.vm.orderInfo!.getPosition)
      },
    )
    this.vm.initMap(
      () => {
        this.customInfoWindowBuilder('始发地', this.vm.orderInfo!.sendPosition)
      },
      () => {
        this.customInfoWindowBuilder(this.vm.orderInfo?.expressStatus === ExpressStatus.SIGNED_FOR ? '已签收' :
          ' 签收地', this.vm.orderInfo!.getPosition)
      },
    )
  }

  onPageShow(): void {
    // 将地图切换到前台
    if (this.vm.mapController) {
      this.vm.mapController.show();
    }
  }

  onPageHide(): void {
    // 将地图切换到后台
    if (this.vm.mapController) {
      this.vm.mapController.hide();
    }
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      if (this.vm.showLoadingMask) {
        CommonLoading({ showLoadingProgress: this.vm.showLoadingMask })
      } else {
        Column() {
          Stack({
            alignContent: Alignment.TopStart,
          }) {
            MapComponent({
              mapOptions: this.vm.mapOptions,
              mapCallback: this.vm.callback,
            })
              .width('100%')
              .height('100%');
            OrderBar()
            Column() {
              if (this.vm.orderInfo?.expressStatus !== ExpressStatus.PICKUP_PENDING) {
                CourierCard()
              }
              LogisticInfo()
            }
            .position({ bottom: -28 })
            .translate({ x: this.vm.offsetX, y: this.vm.offsetY, z: 0 }) // 以组件左上角为坐标原点进行移动
            // 左右滑动触发该手势事件
            .gesture(
              PanGesture(this.panOption)
                .onActionStart((event: GestureEvent) => {
                  Logger.info('Pan start')
                })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.vm.offsetX = this.vm.positionX + event.offsetX
                    const num = this.vm.positionY + event.offsetY
                    if (0 <= num && num < 240) {
                      this.vm.offsetY = num
                    }
                  }
                })
                .onActionEnd((event: GestureEvent) => {
                  this.vm.positionX = this.vm.offsetX
                  this.vm.positionY = this.vm.offsetY
                }),
            )
          };
        }
      }
    }
    .backgroundColor('#F1F3F5')
    .title('运单详情')
  }

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder(title: string, name: string) {
    Row() {
      Row() {
        Text(title)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(42)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 8, bottomLeft: 8 })

      Row() {
        Text(name)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(42)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E5E5EA')
      .borderRadius({ topRight: 8, bottomRight: 8 })
    }
    .width(84)
    .height(24)
    .borderRadius(8)
  }
}