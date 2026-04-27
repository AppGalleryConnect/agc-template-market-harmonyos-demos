import { CustomContentDialog } from '@kit.ArkUI';
import { RouterMap, CommonCounter, ISetting, shippingMethodList, payMethodList } from 'module_base';
import { CommonAddress } from 'module_address_card'
import { OrderType } from '../common/Constant';
import { TemplatePageVM } from '../viewmodel/TemplatePageVM';
import { IGoods } from '../http/Type';

@Builder
export function TemplatePageBuilder() {
  TemplatePage()
}

@Entry
@ComponentV2
struct TemplatePage {
  vm: TemplatePageVM = TemplatePageVM.instance
  timeDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.timeBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0
    },
    alignment: DialogAlignment.Bottom,
  })

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              Row() {
                Text('我的模板')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                Image($r('app.media.ic_arrow_right'))
                  .width(12)
                  .height(12)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .backgroundColor(Color.White)
              .padding(12)
              .margin({ bottom: 12 })
              .borderRadius(16)
              .onClick(() => {
                this.vm.stack.pushPath({
                  name: RouterMap.TEMPLATE_LIST_PAGE,
                });
              })

              CommonAddress({
                stack: this.vm.stack,
                sendAddress: this.vm.sendAddress,
                getAddress: this.vm.getAddress,
                onSelect: (value) => {
                  if (value.type === OrderType.SEND) {
                    this.vm.sendAddress = value.address
                  } else {
                    this.vm.getAddress = value.address
                  }
                },
                onChange: () => {
                  const temp = this.vm.sendAddress
                  this.vm.sendAddress = this.vm.getAddress
                  this.vm.getAddress = temp
                }
              })

              Column() {
                Row() {
                  this.titleBuilder('物品类型')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                  ForEach(this.vm.goodsList, (goods: IGoods, index: number) => {
                    Row() {
                      Text(goods.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor(this.vm.selectedGoodsId === goods.id ? Color.White : $r('sys.color.font_primary'))
                    }
                    .width(72)
                    .height(28)
                    .justifyContent(FlexAlign.Center)
                    .borderRadius(8)
                    .backgroundColor(this.vm.selectedGoodsId === goods.id ? '#0A59F7' : '#C4C4C4')
                    .margin({ bottom: 8 })
                    .onClick(() => {
                      this.vm.selectedGoodsId = goods.id
                      this.vm.weight = goods.weight
                    })
                  }, (item: IGoods[]) => JSON.stringify(item))
                }
              }
              .padding({
                top: 12,
                bottom: 4,
                left: 12,
                right: 12
              })
              .borderRadius(8)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })

              Row() {
                this.titleBuilder('预估重量')
                CommonCounter({
                  weight: this.vm.weight ?? 0, unit: 'kg', onChange: (value) => {
                    this.vm.weight = value
                  }
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(12)
              .borderRadius(8)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })

              Column() {
                Row() {
                  this.titleBuilder('寄件方式')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  ForEach(shippingMethodList, (shippingMethod: ISetting) => {
                    Row() {
                      Text(shippingMethod.value === 3 && this.vm.selectedTime ? this.vm.selectedTime :
                      shippingMethod.text)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor(this.vm.selectedShippingMethod === shippingMethod.value ? Color.White :
                        $r('sys.color.font_primary'))
                        .margin(shippingMethod.value === 3 ? { right: 4 } : {})
                      if (shippingMethod.value === 3) {
                        Image($r('app.media.ic_arrow_right'))
                          .width(12)
                          .height(12)
                      }
                    }
                    .height(28)
                    .borderRadius(8)
                    .backgroundColor(this.vm.selectedShippingMethod === shippingMethod.value ? '#0A59F7' :
                      '#C4C4C4')
                    .padding({
                      top: 4,
                      bottom: 4,
                      left: 8,
                      right: 8
                    })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.vm.selectedShippingMethod = shippingMethod.value
                      if (this.vm.selectedShippingMethod === 3) {
                        this.timeDialogController.open()
                      }
                    })
                  }, (item: ISetting[]) => JSON.stringify(item))
                }
                .width('100%')
              }
              .padding(12)
              .borderRadius(8)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })

              Column() {
                Row() {
                  this.titleBuilder('付款方式')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  ForEach(payMethodList, (payMethod: ISetting) => {
                    Row() {
                      Text(payMethod.text)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor(this.vm.selectedPaymentMethod === payMethod.value ? Color.White :
                        $r('sys.color.font_primary'))
                    }
                    .width(72)
                    .height(28)
                    .justifyContent(FlexAlign.Center)
                    .borderRadius(8)
                    .backgroundColor(this.vm.selectedPaymentMethod === payMethod.value ? '#0A59F7' : '#C4C4C4')
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.vm.selectedPaymentMethod = payMethod.value
                    })
                  }, (item: ISetting[]) => JSON.stringify(item))
                }
                .width('100%')
              }
              .padding(12)
              .borderRadius(8)
              .backgroundColor(Color.White)
              .margin({ bottom: 12 })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .height('calc(100% - 52vp)')

        Row() {
          Button('保存模板')
            .width('100%')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0A59F7')
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              if (this.vm.template) {
                this.vm.updateTemplate()
              } else {
                this.vm.addTemplate()
              }
            })
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor('#F1F3F5')
    .title('自定义模板')
    .onReady((context) => {
      this.vm.setStack(context.pathStack);
    })
  }

  @Builder
  titleBuilder(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
  }

  // 自定义弹出框的内容区
  @Builder
  timeBuilder(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('时间选择')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.ic_close'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.timeDialogController.close()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .margin({ bottom: 30 })

          Row() {
            TextPicker({ range: this.vm.timePickerList, selected: this.vm.selectedTimeIndex })
              .width(200)
              .onChange((value) => {
                this.vm.tempTime = value as string
              })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')

          Row() {
            Row() {
              Button('取消')
                .width('100%')
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
            }
            .width('calc(50% - 6vp)')
            .margin({ right: 12 })
            .onClick(() => {
              this.timeDialogController.close()
            })

            Row() {
              Button('确认')
                .width('100%')
                .fontColor(Color.White)
                .backgroundColor('#0A59F7')
            }
            .width('calc(50% - 6vp)')
            .onClick(() => {
              this.vm.selectedTime = this.vm.tempTime
              this.vm.selectedTimeIndex = this.vm.getSelectedIndex(this.vm.tempTime, this.vm.timePickerList)
              this.timeDialogController.close()
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }
}