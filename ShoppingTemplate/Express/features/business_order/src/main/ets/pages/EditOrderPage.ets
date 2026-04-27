import { EditOrderPageVM } from '../viewModels/EditOrderPageVM'
import { map, MapComponent } from '@kit.MapKit'
import { CustomContentDialog, TipsDialog, window } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { CommonButton, OrderType, RouterModule, ShippingMethod } from 'lib_foundation'
import { CommonLoading, Logger, TelUtil, toastUtil } from 'module_base'
import { CommonAddress } from 'module_address_card'
import { common } from '@kit.AbilityKit'

@Builder
export function EditOrderPageBuilder() {
  EditOrderPage()
}

@Entry
@ComponentV2
struct EditOrderPage {
  @Local isShow: boolean = true
  vm: EditOrderPageVM = EditOrderPageVM.instance
  windowClass: window.Window =
    (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
  payDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      },
    }),
  })
  cancelDialogController: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否取消寄件?',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '确定',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.cancelOrder()
        },
      },
    }),
  })
  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    if (statusType === window.WindowStatusType.FULL_SCREEN) {
      this.isShow = true
    }
    if (statusType === window.WindowStatusType.SPLIT_SCREEN) {
      this.isShow = false
    }
  }

  aboutToAppear() {
    this.vm.init()
    this.vm.initMap()
    this.windowClass.on('windowStatusChange', this.onStatusTypeChange);
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
          Flex() {
            Column() {
              Row() {
                Text(this.vm.getTitle(this.vm.orderInfo?.shippingMethod))
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              }
              .width('100%')
              .margin({ bottom: 12 })

              if (this.vm.orderInfo?.shippingMethod === ShippingMethod.PICK_UP_AT_HOME) {
                Row() {
                  Text(`预计${this.vm.orderInfo?.day}${this.vm.orderInfo?.time}上门取件`)
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .width('100%')
              }
            }
            .flexGrow(1)

            Row() {
              Text() {
                Span('寄件码')
                  .fontColor($r('sys.color.font_primary'))
                Span(this.vm.orderInfo?.mailCode.toString())
                  .fontColor('#0A59F7')
              }
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            }
            .width(128)
            .height(32)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .borderWidth(1)
            .borderColor('#0A59F7')
          }
          .padding({ left: 16, right: 16 })
          .margin({ bottom: 16 })

          Stack({
            alignContent: Alignment.TopStart,
          }) {
            MapComponent({
              mapOptions: this.vm.mapOptions,
              mapCallback: this.vm.callback,
              customInfoWindow: this.customInfoWindow,
            })
              .width('100%')
              .height('100%')

            if (this.vm.showTip) {
              Stack() {
                Row()
                  .width('100%')
                  .height(30)
                  .backgroundColor('#0A59F7')
                  .opacity(0.27)
                  .borderRadius(16)

                Row() {
                  Row() {
                    Image($r('app.media.ic_warning'))
                      .width(12)
                      .height(12)
                    Text('部分快递公司需要当面实名认证，请配合快递员出示证件。')
                      .fontSize(10)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(Color.White)
                      .margin({ left: 4 })
                  }

                  Image($r('app.media.ic_close'))
                    .width(12)
                    .height(12)
                    .onClick(() => {
                      this.vm.showTip = false
                    })
                }
                .width('100%')
                .height(30)
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: 12, right: 12 })
              }
              .padding({ left: 16, right: 16 })
              .position({ top: 16 })
            }

            if (this.isShow) {
              Column() {
                Column() {
                  Row() {
                    this.buttonBuilder('修改信息', $r('app.media.ic_edit'), () => {
                      this.vm.isEdit = true
                      toastUtil.showToast('可修改地址！');
                    })
                    this.buttonBuilder('取消寄件', $r('app.media.ic_cancel'), () => {
                      this.cancelDialogController.open()
                    })
                    this.buttonBuilder('支付运费', $r('app.media.ic_money'), () => {
                      this.payDialogController.open()
                    })
                    this.buttonBuilder('联系客服', $r('app.media.svg'), () => {
                      TelUtil.makeCall('联系客服', '10000000000');
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .backgroundColor(Color.White)
                  .borderRadius(16)
                  .padding(12)
                  .margin({ bottom: 12 })

                  CommonAddress({
                    stack: RouterModule.stack,
                    isEdit: this.vm.isEdit,
                    sendAddress: this.vm.sendAddress,
                    getAddress: this.vm.getAddress,
                    onSelect: (value) => {
                      if (value.type === OrderType.SEND) {
                        this.vm.sendAddress = value.address
                      } else {
                        this.vm.getAddress = value.address
                      }
                      this.vm.updateOrder()
                    },
                    onChange: () => {
                      const temp = this.vm.sendAddress
                      this.vm.sendAddress = this.vm.getAddress
                      this.vm.getAddress = temp
                      this.vm.updateOrder()
                      let info: emitter.EventData = {
                        data: {
                          index: 1,
                        },
                      };
                      try {
                        emitter.emit('index', info);
                      } catch (e) {
                        Logger.error(JSON.stringify(e))
                      }
                    },
                  })
                }
                .translate({ y: -34 })
              }
              .padding({ left: 16, right: 16 })
              .position({ bottom: -14 })
              .backgroundColor('#F1F3F5')
            }
          }
          .layoutWeight(1)
        }
      }
    }
    .backgroundColor('#F1F3F5')
    .title('寄快递')
  }

  @Builder
  buttonBuilder(text: string, image: ResourceStr, func: Function) {
    Column() {
      Image(image)
        .width(24)
        .height(24)
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .onClick(() => {
      func()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('支付金额')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('100')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FE543A')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          CommonButton({
            cancelFunc: () => {
              this.payDialogController.close()
            }, saveButton: () => {
              this.vm.prepay()
              this.payDialogController.close()
            },
          })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24,
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker) {
      Column() {
        Row() {
          Text($$.marker.getTitle())
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(25)
        .padding({ left: 8 })

        Row() {
          Text($$.marker.getSnippet())
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(25)
        .padding({ left: 8 })
      }
      .width($$.marker.getTitle() === '嗨，很高兴为您服务' ? 142 : 160)
      .height(50)
      .borderRadius(8)
      .backgroundColor('#3878F7')
    }
  }
}