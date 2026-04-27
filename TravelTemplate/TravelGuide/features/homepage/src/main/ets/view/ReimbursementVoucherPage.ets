import { BarVM, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { RemarksModel } from '../common/model/RemarksModel';
import { ReimbursementVoucherPageVM } from '../viewmodel/ReimbursementVoucherPageVM';
import { promptAction } from '@kit.ArkUI';

@Builder
export function ReimbursementVoucherPageBuilder(params: TValueType) {
  ReimbursementVoucherPage({
    pageParams: params as string
  })
}

phoneRouterControl.registerPageBuilder(
  RouterMap.REIMBURSEMENT_VOUCHER_PAGE,
  wrapBuilder(ReimbursementVoucherPageBuilder)
)

@ComponentV2
export struct ReimbursementVoucherPage {
  vm: ReimbursementVoucherPageVM = new ReimbursementVoucherPageVM()
  @Param @Require pageParams: string

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        Row() {
          Image($r('app.media.ic_back_black')).width(40).height(40)
            .onClick(() => {
              phoneRouterControl.popPage()
            })
          Text('报销凭证').fontSize(20).fontColor('订单详情').margin({ left: 8 })
        }.justifyContent(FlexAlign.Start).width('100%').padding({ left: 16, right: 16 })

        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('选择开票类型')
                  .fontSize(20)
                  .fontColor('#000000')
                  .fontWeight(500)
                  .lineHeight(21)
              }.width('100%').margin({ bottom: 17 }).justifyContent(FlexAlign.Start)

              Row() {
                Image(this.vm.check ? $r('app.media.ic_checked') : $r('app.media.ic_unchecked'))
                  .width(18)
                  .height(18)
                  .onClick(() => {
                    this.vm.check = !this.vm.check
                  })
                Column() {
                  Text('电子普通发票').titleTextStyle().lineHeight(14).margin({ top: 2 })
                  Image($r('app.media.ic_invoice')).width(54).height(41).margin({ top: 8 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 9 })
              }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 18 }).alignItems(VerticalAlign.Top)

              Row() {
                Image($r('app.media.ic_unchecked'))
                  .width(18)
                  .height(18)

                Column() {
                  Text('电子行程单').placeHolderTextStyle().lineHeight(14).margin({ top: 2 })
                  Text('由于政策原因，您的订单不支持该类型')
                    .fontColor('rgba(0, 0, 0, 0.30)')
                    .fontSize(12)
                    .fontWeight(400)
                    .margin({ top: 8 })
                }.alignItems(HorizontalAlign.Start)
                .margin({ left: 9 })
              }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 18 }).alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 20 })
            .padding({
              left: 16,
              right: 16,
              top: 14,
              bottom: 14
            })

            Column() {
              Row() {
                Text('填写开票信息')
                  .fontSize(20)
                  .fontColor('#000000')
                  .fontWeight(500)
                  .lineHeight(21)
              }.width('100%').margin({ bottom: 17 }).justifyContent(FlexAlign.Start)

              Row() {
                Text('抬头')
                TextInput({
                  placeholder: '必填，公司名称',
                  text: $$this.vm.title
                })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .placeholderColor($r('sys.color.font_secondary'))
                  .placeholderFont({ size: $r('sys.float.Body_L')})
              }.margin({ bottom: 20 }).width('100%').justifyContent(FlexAlign.Start)

              Row() {
                Text('发票备注')
              }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 16 })

              Grid() {
                ForEach(this.vm.remarks, (item: RemarksModel, index: number) => {
                  GridItem() {
                    Column() {
                      Text(item.title)
                        .fontSize(14)
                        .fontColor('#000000')
                        .fontWeight(400)
                    }
                    .justifyContent(FlexAlign.Center)
                  }
                  .onClick(() => {
                    item.choosen = !item.choosen
                  })
                  .height(40)
                  .backgroundColor(item.choosen ? '#FFE431' : '#F6F8F9')
                  .borderRadius(10)
                }, (item: RemarksModel) => item.toString())
              }
              .columnsTemplate('1fr 1fr 1fr') // 三列等宽
              .columnsGap(10) // 列间距
              .rowsGap(10) // 行间距
              .width('100%')
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 })
            .padding({
              left: 12,
              right: 12,
              top: 16,
              bottom: 16
            })

            Column() {
              Row() {
                Text('请填写收件信息')
                  .fontSize(20)
                  .fontColor('#000000')
                  .fontWeight(500)
                  .lineHeight(21)
              }.width('100%').margin({ bottom: 17 }).justifyContent(FlexAlign.Start)

              Row() {
                Text('电子邮箱')
                TextInput({
                  placeholder: '邮箱用于接收电子凭证',
                  text: $$this.vm.email
                })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .placeholderColor($r('sys.color.font_secondary'))
                  .placeholderFont({ size: $r('sys.float.Body_L')})
              }.margin({ bottom: 20 }).width('100%').justifyContent(FlexAlign.Start)

            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 })
            .padding({
              left: 14,
              right: 14,
              top: 16,
              bottom: 16
            })
          }.padding({ left: 16, right: 16, bottom: 130 }).width('100%').alignItems(HorizontalAlign.Start)
        }
        .padding({ bottom: BarVM.instance.staBarH })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)

      }.width('100%').height('100%').padding({ top: BarVM.instance.staBarH })

      Column() {
        Text() {
          Span('开票金额 ').fontColor('#000000')
          Span(`¥${this.pageParams}`).fontColor('#FF4A26')
        }
        .fontSize(14)
        .fontWeight(500)
        .margin({ top: 12, bottom: 12 })

        Row() {
          Text('提交')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(500)
        }
        .onClick(() => {
          if (!this.vm.check) {
            promptAction.showToast({ message: '请选择开票类型' });
            return
          }
          if (!this.vm.title) {
            promptAction.showToast({ message: '请完善公司抬头' });
            return
          }
          if (!this.vm.isValidEmailDetailed(this.vm.email)) {
            promptAction.showToast({ message: '请填写公司邮箱' });
            return
          }
          promptAction.showToast({ message: '提交成功' });
        })
        .width('100%')
        .height(40)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .borderRadius(24)
        .backgroundColor('#FFE431')
      }
      .height(123)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .alignItems(HorizontalAlign.End)
    }
    .width('100%').height('100%')

  }
}


@Extend(Text)
function titleTextStyle() {
  .fontColor('#000000')
  .fontSize(14)
  .fontWeight(500)
}

@Extend(Text)
function placeHolderTextStyle() {
  .fontColor('rgba(0, 0, 0, 0.30)')
  .fontSize(14)
  .fontWeight(400)
}


