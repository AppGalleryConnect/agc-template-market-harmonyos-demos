import { PurchaseVM } from '../viewModels/PurchaseVM'
import { CustomContentDialog, window, KeyboardAvoidMode } from '@kit.ArkUI'
import { RouterMap } from 'commonlib'
import { FormatUtil } from 'commonlib'
import { IButtonMoney } from '../types'
import { common } from '@kit.AbilityKit'
import { CommonRowThird } from '../components/productInfo/CommonRowThird'

@Builder
export function PurchaseBuilder() {
  Purchase()
}

const context: Context = getContext(this);

@ComponentV2
struct Purchase {
  vm: PurchaseVM = PurchaseVM.instance
  private windowClass: window.Window = (context as common.UIAbilityContext).windowStage.getMainWindowSync();
  dialogControllerPurchase: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      }
    }),
  })
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContentInvestment();
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
    this.windowClass.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text() {
                Span(this.vm.productInfo?.name)
                Span('(' + this.vm.productInfo?.number + ')')
              }
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            }
            .width('100%')

            Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 14 })

            CommonRowThird({ text: '剩余额度', value: this.vm.productInfo?.remainingPurchaseAmount + '元' })
          }
          .padding({
            top: 14,
            bottom: 13,
            left: 16,
            right: 16
          })
          .margin({ bottom: 8 })
          .backgroundColor(Color.White)

          Column() {
            CommonRowThird({ text: '卡号', value: FormatUtil.encryptBankCardNo(this.vm.account.bankCardNo) })

            Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 14 })

            CommonRowThird({ text: '可用余额', value: this.vm.account.bankAmount + '元' })
          }
          .padding({
            top: 14,
            bottom: 13,
            left: 16,
            right: 16
          })
          .margin({ bottom: 8 })
          .backgroundColor(Color.White)

          Column() {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text('购买金额')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
              Text('交易规则')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor('#E4480C')
                .onClick(() => {
                  FormatUtil.jumpToNext(RouterMap.RULE, { id: this.vm.productInfo?.id, index: 0 })
                })
            }
            .padding({ bottom: 9 })

            Row() {
              Text('￥')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              TextInput({
                text: this.vm.money,
                placeholder: `${this.vm.productInfo?.minimumPurchaseAmount}元起购，${this.vm.productInfo?.minimumPurchaseAmount}元递增`
              })
                .type(InputType.NUMBER_DECIMAL)
                .backgroundColor(Color.White)
                .borderRadius(0)
                .padding({ left: 0 })
                .placeholderFont({ size: 16, weight: FontWeight.Regular })
                .placeholderColor($r('sys.color.font_tertiary'))
                .onChange((value: string) => {
                  this.vm.money = value
                })
            }
            .height(48)
            .alignItems(VerticalAlign.Center)

            Divider().color($r('sys.color.comp_divider')).margin({ bottom: 16 })


            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.vm.buttonMoney, (item: IButtonMoney, index: number) => {
                Button(item.text)
                  .buttonStyles()
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.vm.selectedMoneyIndex === index ? '#E4480C' : $r('sys.color.font_primary'))
                  .borderColor(this.vm.selectedMoneyIndex === index ? '#E4480C' : 'rgba(0,0,0,0.20)')
                  .onClick(() => {
                    this.vm.getButtonMoney(item.index)
                    this.vm.selectedMoneyIndex = item.index
                  })
              }, (item: IButtonMoney[]) => JSON.stringify(item))
            }
            .margin({ bottom: 16 })

            Row() {
              Text(`购买费率${this.vm.productBuyRule ? this.vm.productBuyRule.purchaseRate :
                0}元，仅供参考，以实际收取为准`)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('100%')
          }
          .padding({
            top: 15,
            bottom: 16,
            left: 16,
            right: 16
          })
          .margin({ bottom: 8 })
          .backgroundColor(Color.White)

          Column() {
            if (this.vm.isPurchase) {
              CommonRowThird({ text: '扣款日期', value: FormatUtil.formatDate(new Date()) })
            } else {
              CommonRowThird({ text: '定投周期', value: this.vm.cycle + this.vm.date })
            }


            Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 4 })

            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text('推荐人代码')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              TextInput({ text: this.vm.recommendationCode, placeholder: '选填' })
                .placeholderFont({ size: 14, weight: FontWeight.Regular })
                .placeholderColor($r('sys.color.font_tertiary'))
                .textAlign(TextAlign.End)
                .backgroundColor(Color.White)
                .width('40%')
                .onChange((value) => {
                  this.vm.recommendationCode = value
                })
            }
          }
          .padding({
            top: 14,
            bottom: 4,
            left: 16,
            right: 16
          })
          .backgroundColor(Color.White)

          Column() {
            Flex({ alignItems: ItemAlign.Start }) {
              Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
                .select($$this.vm.isCheckedAgreement)
                .selectedColor(0x39a2db)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .margin({ right: 10 })
              Row() {
                Text() {
                  Span('我的风险评估结果为：进取型，')
                    .fontWeight(FontWeight.Regular)
                    .fontColor('rgba(0,0,0,0.60)')
                  Span('我已仔细阅读并同意')
                    .fontColor($r('sys.color.font_primary'))
                  Span('《理财产品合同》')
                    .fontColor('#E4480C')
                    .onClick(() => {
                      FormatUtil.jumpToNext(RouterMap.PRIVACY, '理财产品合同')
                    })
                  Span('，接受载明的所有条款，充分了解清楚知晓本产品存在的风险，并愿意承担投资风险。')
                    .fontColor($r('sys.color.font_primary'))
                }
                .fontWeight(FontWeight.Medium)
                .fontSize(12)
              }
              .flexGrow(1)
              .flexShrink(1)
            }
            .margin({ bottom: 24 })

            Button('下一步')
              .width('100%')
              .height(40)
              .backgroundColor('#E4480C')
              .fontColor(Color.White)
              .margin({ bottom: 24 })
              .enabled(this.vm.checkPurchaseInformation())
              .onClick(() => {
                this.dialogControllerPurchase.open()
              })

            Row() {
              Text('温馨提示：本产品非保本浮动收益理财产品，并不保证理财资金和收益，投资者应充分认识投资风险，请谨慎选择！')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .width('100%')
          }
          .padding({
            top: 14,
            bottom: 13,
            left: 16,
            right: 16
          })
        }
        .margin({ top: 8 })
      }
      .scrollBar(BarState.Off)
    }
    .title(this.vm.isPurchase ? '理财购买' : '理财定投')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }

  @Styles
  buttonStyles(){
    .width(73)
    .height(28)
    .backgroundColor(Color.White)
    .borderWidth(1)
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text('购买金额（元）')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ bottom: 8 })
            Text(this.vm.money)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 16 })

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Text('产品名称')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('37.5%')

            Row() {
              Text(this.vm.productInfo.name)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.End)
          }
          .margin({ bottom: 12 })

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Text('资产账户')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('37.5%')

            Row() {
              Text(FormatUtil.encryptBankCardNo(this.vm.account?.bankCardNo))
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.End)
          }
          .margin({ bottom: 12 })

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Text('预计确认日')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('37.5%')

            Row() {
              Text('2025/03/03')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.End)
          }
          .margin({ bottom: 16 })

          Row() {
            Text('温馨提示：本产品非保本浮动收益理财产品，并不保证理财资金和收益，投资者应充分认识投资风险，请谨慎选择！')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor('#E84026')
          }
          .width('100%')

          Row() {
            Row() {
              Text('取消')
            }
            .width('50%')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.dialogControllerPurchase.close()
            })

            Row() {
              Button('确认')
                .width('100%')
                .height(40)
                .backgroundColor('#E4480C')
            }
            .width('50%')
            .height(40)
            .onClick(async () => {
              if (this.vm.checkPurchaseInformation()) {
                await this.vm.prepay()
                this.dialogControllerPurchase.close()
              }
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
    }
  }

  // 自定义弹出框的内容区
  @Builder
  buildContentInvestment(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('定投周期')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.ic_close'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.dialogController.close()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .margin({ bottom: 33 })

          Flex() {
            TextPicker({ range: this.vm.cycleData })
              .onChange((value: string | string[], index: number | number[]) => {
                this.vm.tempCycle = value as string
                if (value === '每周' || value === '每两周') {
                  this.vm.currentData = this.vm.dateData1
                  this.vm.tempDate = this.vm.currentData[0]
                }
                if (value === '每月') {
                  this.vm.currentData = this.vm.dateData2
                  this.vm.tempDate = this.vm.currentData[0]
                }
              })
              .width(200)
            TextPicker({ range: this.vm.currentData })
              .onChange((value: string | string[], index: number | number[]) => {
                this.vm.tempDate = value as string
              })
              .width(200)
          }
          .width('100%')
          .margin({ bottom: 11 })

          Row() {
            Row() {
              Button('取消')
                .width('100%')
                .height(40)
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
            }
            .width('calc(50% - 6vp)')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .margin({ right: 12 })
            .onClick(() => {
              this.dialogController.close()
            })

            Row() {
              Button('确认')
                .width('100%')
                .height(40)
                .fontColor(Color.White)
                .backgroundColor('#E4480C')
            }
            .width('calc(50% - 6vp)')
            .height(40)
            .onClick(async () => {
              this.vm.cycle = this.vm.tempCycle
              this.vm.date = this.vm.tempDate
              this.dialogController.close()
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
    }
  }
}