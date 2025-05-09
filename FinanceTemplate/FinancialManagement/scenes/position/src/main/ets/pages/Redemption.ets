import { RedemptionVM } from '../viewModels/RedemptionVM';
import { CustomContentDialog } from '@kit.ArkUI';
import { FormatUtil, RouterMap } from 'commonlib';
import { IRedemptionButton } from '../types';

@Builder
export function RedemptionBuilder() {
  Redemption()
}

@Entry
@ComponentV2
struct Redemption {
  vm: RedemptionVM = RedemptionVM.instance
  controller: TextInputController = new TextInputController()
  dialogControllerRedemption: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0
      }
    }),
    cancel: () => {
      this.vm.clearTimer()
    },

  })

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              Row() {
                Text(this.vm.positionRedemption?.productName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              }
              .width('100%')
              .padding({
                top: 18,
                bottom: 17,
                left: 16,
                right: 16
              })
              .margin({ bottom: 8 })
              .backgroundColor(Color.White)

              Column() {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Text('赎回份额')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.font_primary'))
                  Text('交易规则')
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#E4480C')
                    .onClick(() => {
                      FormatUtil.jumpToNext(RouterMap.RULE, { id: this.vm.positionRedemption?.id, index: 1 })
                    })
                }

                Row() {
                  TextInput({
                    text: this.vm.share,
                    placeholder: '请输入赎回份额',
                    controller: this.controller,
                  })
                    .type(InputType.Number)
                    .placeholderColor($r('sys.color.font_tertiary'))
                    .placeholderFont({ size: 16, weight: FontWeight.Regular })
                    .backgroundColor(Color.White)
                    .width('100%')
                    .fontSize(16)
                    .fontColor(Color.Black)
                    .padding({ left: 0 })
                    .onChange((value: string) => {
                      this.vm.share = value
                    })
                }
                .height(48)
                .alignItems(VerticalAlign.Center)

                Divider().color($r('sys.color.comp_divider')).margin({ bottom: 8 })

                Row() {
                  Text() {
                    Span('当前最高可赎回')
                    Span(this.vm.positionRedemption?.share + '')
                      .fontColor('#E4480C')
                    Span('份')
                  }
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ bottom: 16 })
                }
                .width('100%')

                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  ForEach(this.vm.redemptionButton, (item: IRedemptionButton, index: number) => {
                    Button(item.text)
                      .buttonStyles()
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(this.vm.selectedMoneyIndex === index ? '#E4480C' : $r('sys.color.font_primary'))
                      .borderColor(this.vm.selectedMoneyIndex === index ? '#E4480C' : 'rgba(0,0,0,0.20)')
                      .onClick(() => {
                        this.vm.getRedemptionButton(item.index)
                        this.vm.selectedMoneyIndex = item.index
                      })
                  }, (item: IRedemptionButton[]) => JSON.stringify(item))
                }
              }
              .padding({
                top: 15,
                bottom: 12,
                left: 16,
                right: 16
              })
              .backgroundColor(Color.White)
            }
          }
          .scrollBar(BarState.Off)
        }
        .height('calc(100% - 40vp)')


        Row() {
          Button('确认赎回')
            .width('100%')
            .height('100%')
            .fontColor(Color.White)
            .backgroundColor('#E4480C')
            .enabled(this.vm.checkShare())
            .onClick(() => {
              if (this.vm.share && this.vm.share !== '0') {
                this.dialogControllerRedemption.open()
              }
            })
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 16 })
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title('赎回')
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

  @Builder
  contentBuilder(text: string) {
    Row() {
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .width(73)
    .height(28)
    .justifyContent(FlexAlign.Center)
    .borderWidth(1)
    .borderRadius('50%')
    .borderColor('rgba(0,0,0,0.20)')
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text('赎回份额')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ bottom: 8 })
            Text(this.vm.share)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
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
              Text(this.vm.positionRedemption?.productName)
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
              Text('手机号码')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('37.5%')

            Row() {
              Text(FormatUtil.encryptPhoneNo(this.vm.userInfo?.cellphone ?? ''))
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.End)
          }
          .margin({ bottom: 12 })

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Row() {
              TextInput({ text: this.vm.verificationCode, placeholder: '短信验证码' })
                .type(InputType.Number)
                .backgroundColor(Color.White)
                .padding({ left: 0 })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({ size: 16, weight: FontWeight.Regular })
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .onChange((value) => {
                  this.vm.verificationCode = value
                })
            }
            .width('37.5%')

            Row() {
              Text(this.vm.getTimeText())
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.End)
            .onClick(() => {
              if (!this.vm.timer) {
                this.vm.countdown()
              }
            })
          }
          .height(48)

          Divider()
            .margin({ bottom: 4 })
            .color(this.vm.checkVerificationCode() ? $r('sys.color.comp_divider') : '#E84026')

          if (this.vm.timer) {
            Row() {
              if (this.vm.checkVerificationCode()) {
                Text() {
                  Span(`已发送至您尾号${this.vm.userInfo?.cellphone.slice(7, 11)}的手机，请在`)
                  Span('2分钟')
                    .fontColor('#E84026')
                  Span('内输入')
                }
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.40)')
              } else {
                Text('验证码不正确，请重新输入123456')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('#E84026')
              }
            }
            .width('100%')
          }

          Row() {
            Row() {
              Text('取消')
            }
            .width('50%')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.vm.clearTimer()
              this.dialogControllerRedemption.close()
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
              const res = await this.vm.submit()
              if (res) {
                this.vm.clearTimer()
                this.dialogControllerRedemption.close()
              }
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
    }
  }
}