import { ComponentContent } from '@kit.ArkUI';
import { generateBarcode, scanCore } from '@kit.ScanKit';
import { image } from '@kit.ImageKit';
import { LogUtil, ToastUtil } from 'common';

@Preview
@ComponentV2
export struct PatientCardView {
  @Param patientName: string = ''
  @Param patientCardId: string = ''
  @Param picUrl: ResourceStr = ''
  @Param addMode: boolean = false // true则为展示“添加就诊人”，false展示就诊人信息
  @Param cardColor: Color | Resource | null = null
  @Param fontColor: Color | Resource = Color.White
  @Param showSwitch: boolean = false
  @Local barCodePixelMap: image.PixelMap | undefined = undefined
  @Local qrCodePixelMap: image.PixelMap | undefined = undefined
  @Param onPatientClick: () => void = () => {
  }

  build() {
    Stack() {
      if (!this.addMode) {
        Row() {
          Image(this.picUrl)
            .alt($r('app.media.ic_default_profile'))
            .width(44)
            .height(44)
            .borderRadius(100)

          Column({ space: 6 }) {
            Row({ space: 10 }) {
              Text(this.patientName)
                .textAlign(TextAlign.Start)
                .fontColor(this.fontColor)
                .fontSize(16)

              if (this.showSwitch) {
                Row({ space: 4 }) {
                  Image($r('app.media.ic_switch_patient'))
                    .width(14)
                    .height(14)
                  Text('切换就诊人')
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                }
                .padding({
                  left: 8,
                  right: 8,
                  top: 5,
                  bottom: 5
                })
                .backgroundColor($r('sys.color.ohos_id_color_primary_contrary'))
                .borderRadius(100)
              }
            }

            Text(`就诊码：${this.patientCardId}`)
              .textAlign(TextAlign.Start)
              .fontColor(this.fontColor)
              .fontSize(12)
          }
          .margin({
            left: 16
          })
          .alignItems(HorizontalAlign.Start)

          Blank()

          Image($r('app.media.ic_qrcode'))
            .width(28)
            .height(28)
            .fillColor(this.fontColor)
            .onClick(() => {
              LogUtil.info('patient card id: ' + this.patientCardId)
              Promise.all([generateBarcode.createBarcode(this.patientCardId.toString(), {
                scanType: scanCore.ScanType.CODE128_CODE,
                width: 600,
                height: 200,
              }), generateBarcode.createBarcode(this.patientCardId.toString(), {
                scanType: scanCore.ScanType.QR_CODE,
                width: 200,
                height: 200,
              })]).then(value => {
                this.getUIContext()
                  .getPromptAction()
                  .openCustomDialog(new ComponentContent(this.getUIContext(), wrapBuilder(qrCodeDialogBuilder),
                    {
                      patientName: this.patientName,
                      patientCardId: this.patientCardId,
                      barCodePixelMap: value[0],
                      qrCodePixelMap: value[1]
                    } as QRCodeDialogParam),
                    {
                      alignment: DialogAlignment.Center
                    })
              }).catch((error: object) => {
                ToastUtil.showToast(JSON.stringify(error))
              })
            })
        }.width('100%')
      } else {
        Row({ space: 10 }) {
          Image($r('app.media.ic_add'))
            .width(18)
            .height(18)
            .fillColor(this.fontColor)
          Text('添加就诊人')
            .fontColor(this.fontColor)
            .fontSize(14)
            .fontWeight(500)
        }
      }
    }
    .width('100%')
    .height(84)
    .linearGradient(!this.cardColor ? {
      angle: 125,
      colors: [['#6496FA', 0.0], ['#76A8FF', 0.99]],
    } : null)
    .backgroundColor(this.cardColor ? this.cardColor : undefined)
    .borderRadius(8)
    .padding(
      {
        top: 20,
        bottom: 20,
        left: 24,
        right: 24
      }
    )
    .onClick(() => {
      this.onPatientClick()
    })
  }
}

interface QRCodeDialogParam {
  patientName: string,
  patientCardId: string,
  barCodePixelMap: image.PixelMap | undefined,
  qrCodePixelMap: image.PixelMap | undefined
}

@Builder
function qrCodeDialogBuilder(param: QRCodeDialogParam) {
  Column({ space: 16 }) {
    Text(param.patientName)
      .fontSize(32)
      .margin({ bottom: 40 })

    Image(param.barCodePixelMap)
      .width(240)
      .height(80)
      .objectFit(ImageFit.Contain)

    Image(param.qrCodePixelMap)
      .width(200)
      .height(200)
      .objectFit(ImageFit.Contain)
  }
  .width('80%')
  .height('60%')
  .backgroundColor($r('sys.color.ohos_id_color_background'))
  .justifyContent(FlexAlign.Center)
  .borderRadius(20)
}