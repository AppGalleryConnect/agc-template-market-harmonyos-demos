import { BarVM } from 'common';

/**
 * 文档翻译进度弹窗组件
 */
@ComponentV2
export struct DocumentTranslateProgressDialog {
  @Param progress: number = 0;
  @Param currentStep: string = '';

  build() {
    Column() {
      // 占位区域
      Column()
        .layoutWeight(1)
        .width('100%')

      // 底部悬浮卡片
      Column() {
        // 标题
        Text('正在翻译')
          .fontSize(18)
          .fontColor('#1A1A1A')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        // 步骤说明
        Column({ space: 4 }) {
          Text('1. 正在识别文档文本')
            .fontSize(15)
            .fontColor('#1A1A1A')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text('2. 正在文本翻译')
            .fontSize(15)
            .fontColor('#1A1A1A')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .margin({ top: 16 })
        .alignItems(HorizontalAlign.Start)

        // 进度信息
        Row() {
          Text('正在翻译中...')
            .fontSize(14)
            .fontColor('#1A1A1A')

          Blank()

          Text(`${this.progress}%`)
            .fontSize(14)
            .fontColor('#1A1A1A')
        }
        .width('100%')
        .margin({ top: 16 })

        // 进度条
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(24)
          .color($r('sys.color.comp_background_emphasize'))
          .backgroundColor($r('sys.color.comp_background_secondary'))
          .margin({ top: 8 })
      }
      .width('90%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius($r('sys.float.corner_radius_level16'))
      .margin({ bottom: 24 + BarVM.instance.aiBarH })
    }
    .width('100%')
    .height(`calc(100% + ${BarVM.instance.staBarH + BarVM.instance.aiBarH}vp)`)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .margin({ top: -BarVM.instance.staBarH, bottom: -BarVM.instance.aiBarH })
  }
}
