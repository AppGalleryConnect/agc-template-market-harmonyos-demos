import { SCALE_FRAME } from '../viewModel/EditViewModel';

@ComponentV2
export struct ScaleComponent {
  @Param @Require scaleVal: number = 0  //刻度值
  scaleFrame: number = SCALE_FRAME  //刻度间隔

  getScaleHeight() {
    if (this.scaleVal % this.scaleFrame === 0) {
      return 8
    } else {
      return 4
    }
  }

  getFormatScale(totalSeconds: number) {
    // 处理异常值：负数转为0，非数字转为0
    const sec = Math.max(Math.floor(Number(totalSeconds) || 0), 0);
    // 计算分钟和剩余秒数
    const minutes = Math.floor(sec / 60);
    const seconds = sec % 60;
    // 补零函数：确保数字为两位
    const padZero = (num: number) => num.toString().padStart(2, '0');
    return `${padZero(minutes)}:${padZero(seconds)}`;
  }

  build() {
    Column() {
      Divider()
        .vertical(true)
        .strokeWidth(1)
        .color('#99FFFFFF')
        .width(1)
        .height(this.getScaleHeight())
      if (this.scaleVal % this.scaleFrame === 0) {
        Text(this.getFormatScale(this.scaleVal))
          .width(26)
          .height(14)
          .fontSize(10)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .halfLeading(true)
          .position({ x: -13, y: 8 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}