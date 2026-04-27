import { MapComponent } from '@kit.MapKit';
import { CommonLoading, ParcelStatus, CommonUtil, CommonTitle, TelUtil } from 'lib_foundation';
import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM';
import { LogisticsInfo } from '../components/LogisticsInfo';
import { DetentsType } from '../constants';

@Extend(Text)
function textFancy() {
  .fontSize(18)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .lineHeight(24)
}

@Builder
export function OrderInfoPageBuilder() {
  OrderInfoPage()
}

@ComponentV2
struct OrderInfoPage {
  vm: OrderInfoPageVM = new OrderInfoPageVM();
  @Local isShowSheet: boolean = false;
  // 拖动面板的最大高度
  @Local panelMaxHeight: number = 0;
  // 中间高度
  @Local panelMidHeight: number = 0;
  // 最小高度
  @Local panelMinHeight: number = 240;
  // 拖动面板的高度
  @Local panelHeight: number = 240;
  // 拖动的距离
  @Local scrollY: number = 0;
  @Local yStart: number = 0;
  @Local isUp: boolean = true;
  // 面板当前所属的高度
  @Local detentsType: DetentsType = DetentsType.MIN;
  // 状态卡片高度
  @Local cardHeight: number = 200;
  senderFn: () => void = () => {
    this.customInfoWindowBuilder('始发地', this.vm.orderInfo!.senderCity)
  }

  receiveFn: () => void = () => {
    this.customInfoWindowBuilder(this.vm.orderInfo?.status === ParcelStatus.DELIVERED ? '已签收' :
      '签收地', this.vm.orderInfo!.receiverCity)
  }

  @Monitor('vm.windowModel.windowHeight', 'vm.windowModel.windowWidth')
  onWindowChange() {
    // 窗口高度
    const windowHeight = this.getUIContext().px2vp(this.vm.windowModel.windowHeight);
    // 最大高度
    this.panelMaxHeight = windowHeight - this.cardHeight;
    // 中间高度
    this.panelMidHeight = windowHeight * 0.55;

    const heightMap: Map<DetentsType, number> = new Map([
      [DetentsType.MIN, this.panelMinHeight],
      [DetentsType.MID, this.panelMidHeight],
      [DetentsType.MAX, this.panelMaxHeight],
    ])
    this.panelHeight = heightMap.get(this.detentsType) as number;

    if (this.vm.mapController) {
      this.vm.boundHeight = this.vm.windowModel.windowHeight / 2 - 300;
      this.vm.getLocationData(this.senderFn, this.receiveFn);
    }
  }

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext();
    this.vm.initMap();
    this.vm.initData(this.senderFn, this.receiveFn)

    // 窗口高度
    const windowHeight = this.getUIContext().px2vp(this.vm.windowModel.windowHeight);
    // 最大高度
    this.panelMaxHeight = windowHeight - this.cardHeight;
    // 中间高度
    this.panelMidHeight = windowHeight * 0.55;
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  touchMove(event: TouchEvent) {
    switch (event.type) {
      // 手指按下
      case TouchType.Down: {
        this.yStart = event.touches[0].y;
        break;
      }
      // 手指滑动
      case TouchType.Move: {
        // 手指离开屏幕时的纵坐标
        const yEnd = event.touches[0].y;
        // 手指在屏幕上的滑动距离
        const height = Math.abs(Math.abs(yEnd) - Math.abs(this.yStart));
        // 手指上滑操作，面板跟随手势滑动
        if (yEnd <= this.yStart) {
          this.isUp = true;
          const temHeight = this.panelHeight + height;
          if (temHeight > this.panelMaxHeight) {
            return
          }
          // 面板高度随滑动高度变化
          this.panelHeight = temHeight;
          this.scrollY = temHeight;
        }
        // 手指下滑操作，面板跟随手势滑动
        else {
          this.isUp = false;
          const temHeight = this.panelHeight - height;
          if (temHeight < this.panelMinHeight) {
            return
          }
          // 面板高度随滑动高度变化
          this.panelHeight = temHeight;
          this.scrollY = temHeight;
        }
        this.yStart = event.touches[0].y;
        break;
      }

      // 手指离开屏幕
      case TouchType.Up: {
        // 上滑时
        if (this.isUp) {
          if (this.scrollY > this.panelMinHeight && this.scrollY <= this.panelMidHeight) {
            this.scrollAnimateTo(this.panelMidHeight);
            this.detentsType = DetentsType.MID;
          } else {
            this.scrollAnimateTo(this.panelMaxHeight);
            this.detentsType = DetentsType.MAX;
          }
        } else {
          // 下滑
          if (this.scrollY >= this.panelMidHeight && this.scrollY < this.panelMaxHeight) {
            this.scrollAnimateTo(this.panelMidHeight);
            this.detentsType = DetentsType.MID;
          } else {
            this.scrollAnimateTo(this.panelMinHeight);
            this.detentsType = DetentsType.MIN;
          }
        }
      }
    }
  }

  scrollAnimateTo(height: number) {
    this.getUIContext()?.animateTo({
      duration: 150,
      curve: Curve.EaseInOut
    },() => {
      this.panelHeight = height;
    });
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '运单详情'
      })
      Stack() {
        Stack({ alignContent: Alignment.Bottom }) {
          Stack({ alignContent: Alignment.Top }) {
            MapComponent({
              mapOptions: this.vm.mapOptions,
              mapCallback: this.vm.callback,
            })
              .width('100%')
              .height('100%')

            // 状态卡片
            this.waybillStatusCard()
          }
          .width('100%')
          .height('100%')

          // 可拖动区域
          Column() {
            Row() {
              Image($r('app.media.ic_drag_bar'))
                .width(96)
                .height(16)
                .margin({ top: 4 })
            }
            .width('100%')
            .height(42)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Top)
            .onTouch((event: TouchEvent) => {
              this.touchMove(event)
            })
            .hitTestBehavior(HitTestMode.Block)

            this.orderInfoPanel()
          }
          .width('100%')
          .height(this.panelHeight)
          .backgroundColor('#FFFFFF')
          .padding({ bottom: this.vm.windowModel.windowBottomPadding })
          .borderRadius({
            topLeft: 16, topRight: 16
          })
        }
        .width('100%')
        .height('100%')

        if (this.vm.showLoadingMask) {
          Column() {
            CommonLoading({ showLoadingProgress: this.vm.showLoadingMask })
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.background_secondary'))
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
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

  @Builder
  waybillStatusCard() {
    Row() {
      Column() {
        Row({ space: 4 }) {
          Text(this.vm.snText)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_on_primary'))
            .lineHeight(13)
          SymbolGlyph($r('sys.symbol.plus_square_on_square'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')])
            .onClick(() => {
              CommonUtil.copyText(this.vm.orderInfo?.parcelNumber || '')
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .borderRadius({ topLeft: 16, topRight: 16 })
        .linearGradient({
          angle: 90,
          colors: [['#4c4430', 0], ['#f5f3ef', 1]],
        })

        Row() {
          Column({ space: 8 }) {
            Text(this.vm.statusText)
              .textFancy()
            Text(this.vm.dateTimeText)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(13)
          }

          Row({ space: 12 }) {
            Row() {
              Text(this.vm.orderInfo?.senderCity ?? '')
                .textFancy()
                .fontSize(16)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)

            SymbolGlyph($r('sys.symbol.arrow_right'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_emphasize')])
              .flexShrink(0)

            Text(this.vm.orderInfo?.receiverCity ?? '')
              .textFancy()
              .fontSize(16)
              .layoutWeight(1)
              .constraintSize({ maxWidth: 160 })
          }
          .layoutWeight(1)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .padding(12)
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
    .margin({ top: 8 })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      if (newValue.globalPosition.y) {
        const offsetY = Number(newValue.globalPosition.y) + Number(newValue.height);
        this.cardHeight = offsetY + 8;
        this.panelMaxHeight = this.getUIContext().px2vp(this.vm.windowModel.windowHeight) - offsetY - 8;
      }
    })
  }

  // 物流信息面板
  @Builder
  orderInfoPanel() {
    Column({ space: 12 }) {
      Row() {
        Image($r('app.media.ic_courier_avatar'))
          .width(32)
          .height(32)

        Column({ space: 6 }) {
          Text(this.vm.curLogisticInfo?.operatorName || '赵师傅')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(400)
            .lineHeight(19)

          Text(this.vm.orderInfo?.expressCompany ?? '')
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(500)
            .lineHeight(13)
        }
        .margin({ left: 6 })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button() {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_emphasize')])
        }
        .width(24)
        .height(24)
        .backgroundColor($r('sys.color.comp_emphasize_secondary'))
        .onClick(() => {
          const phone = this.vm.curLogisticInfo?.operatorPhone || '12345678900'
          TelUtil.makeCall('联系快递员', phone);
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_tertiary'))

      Row() {
        Text('物流详情')
          .fontColor(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')

      Scroll() {
        LogisticsInfo({
          logisticsList: this.vm.logisticsList
        })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, bottom: 12 })
    .alignItems(HorizontalAlign.Center)
  }
}