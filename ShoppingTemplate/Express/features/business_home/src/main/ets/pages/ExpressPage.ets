import { emitter } from '@kit.BasicServicesKit'
import { IGoods, IServicePoint, ITemplate, OrderType, RouterModule } from 'lib_foundation'
import { ISetting, Logger, methodList } from 'module_base'
import { CommonAddress } from 'module_address_card'
import { Authentication } from '../components/Authentication'
import { PurchaseBar } from '../components/PurchaseBar'
import { ShippingInfo } from '../components/ShippingInfo'
import { ExpressPageVM } from '../viewModels/ExpressPageVM'
import { HomeVisit } from '../components/HomeVisit'
import { TemplateManage } from 'module_template'


@Builder
export function ExpressPageBuilder() {
  ExpressPage()
}

@Entry
@ComponentV2
struct ExpressPage {
  vm: ExpressPageVM = ExpressPageVM.instance

  aboutToAppear(): void {
    this.vm.init()
    try {
      emitter.on('goods', (data) => {
        if (data.data) {
          this.vm.selectedGoods = data.data as IGoods
          this.vm.goodsName = this.vm.selectedGoods.name + ' ' + this.vm.selectedGoods.weight + 'kg'
          this.vm.getEstimatedPrice()
        }
      });
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    try {
      emitter.on('servicePoint', (data) => {
        if (data.data) {
          this.vm.selectedServicePoint = data.data as IServicePoint
          this.vm.getEstimatedPrice()
        }
      });
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    try {
      emitter.on('template', (data) => {
        if (data.data) {
          this.vm.getTemplateList()
        }
      });
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              if (this.vm.userInfoModel.realNameAuthFlag === 0) {
                Authentication()
              }
              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                List() {
                  ForEach(this.vm.templateList, (template: ITemplate) => {
                    ListItem() {
                      Row() {
                        Text(template?.name)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.vm.selectedTemplateId === template.id ? Color.White :
                            $r('sys.color.font_primary'))
                      }
                      .height(28)
                      .padding({ left: 16, right: 16 })
                      .backgroundColor(this.vm.selectedTemplateId === template.id ? $r('sys.color.icon_secondary') :
                        'rgba(0,0,0,0.05)')
                      .margin({ right: 8 })
                      .borderRadius(21)
                    }
                    .onClick(() => {
                      this.vm.changeTemplate(template)
                    })
                  }, (item: ITemplate[]) => JSON.stringify(item))
                }
                .scrollBar(BarState.Off)
                .height(28)
                .listDirection(Axis.Horizontal)
                .margin({ right: 8 })
                .flexGrow(1)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

                TemplateManage({
                  navPathStack: RouterModule.stack,
                  onBeforeNavigate: () => {
                    this.vm.isFresh = false
                    return true;
                  },
                }) {
                  Row() {
                    Text('添加模板')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 2 })
                    Image($r('app.media.ic_arrow_right'))
                      .width(12)
                      .height(12)
                  }
                  .width(110)
                  .height(28)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('rgba(0,0,0,0.05)')
                  .borderRadius(21)
                }
              }
              .width('100%')
              .margin({ bottom: 12 })

              CommonAddress({
                stack: RouterModule.stack,
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
                },
              })

              Row() {
                ForEach(methodList, (method: ISetting, index: number) => {
                  Button(method.text)
                    .height(36)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.vm.selectedMethod === method.value ? Color.White : $r('sys.color.font_primary'))
                    .backgroundColor(this.vm.selectedMethod === method.value ? '#0A59F7' : 'rgba(0,0,0,0.05)')
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.vm.selectedMethod = method.value
                      this.vm.getEstimatedPrice()
                    })
                }, (item: ISetting[]) => JSON.stringify(item))
              }
              .width('100%')
              .margin({ bottom: 12 })

              if (this.vm.selectedMethod === 1) {
                HomeVisit()
              } else {
                ShippingInfo()
              }
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .layoutWeight(1)

        PurchaseBar()
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .backgroundColor('#F1F3F5')
    .title('寄快递')
  }
}