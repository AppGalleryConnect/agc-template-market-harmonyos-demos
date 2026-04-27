import { OrderItem } from '../../viewmodel/MyOrderPageVM';

@ComponentV2
export struct MyOrderProcessStepsView {
  @Require @Param order: OrderItem;
  // 订单流程的步骤
  @Param processIndex: number = 0
  // 偏移的比例：-0.5-0.5
  @Param offsetRaito: number = 0.0
  // 组件的宽度
  @Local componentWidth: number = 0

  // 构建实线类型一：符号右侧
  @Builder
  buildLineTypeOne(index: number) {
    Divider()
      .width(this.calculateLineWidth(index))
      .height(1)
      .backgroundColor('rgba(255, 75, 75, 1)')
      .margin({ top: 12, left: this.calculateLineMargin(index) })
  }

  // 构建虚线类型一：符号右侧
  @Builder
  buildAbstractLineTypeOne(num: number, lineNum: number = 0) {
    Row() {
      ForEach(Array.from({ length: this.calculateLineNum(num) }),
        (item: number, index) => {
          if (this.calculateLineNum(num - 1) !== 0 && this.calculateLineNum(num - 1) % 2 === 1) {
            if (index % 2 === 0) {
              Row().width(4).height(1).backgroundColor('rgba(255, 255, 255, 1)')
            } else {
              Row().width(4).height(1).backgroundColor('rgba(226, 226, 226, 1)')
            }
          } else {
            if (index % 2 === 0) {
              Row().width(4).height(1).backgroundColor('rgba(226, 226, 226, 1)')
            } else {
              Row().width(4).height(1).backgroundColor('rgba(255, 255, 255, 1)')
            }
          }
        }, (item: number, index: number) => JSON.stringify(item) + index)
    }
    .width(this.calculateLineWidth(num))
    .height(1)
    .margin({ top: 12, left: this.calculateLineMargin(num) })
  }

  // 构建实线类型二：符号左侧
  @Builder
  buildLineTypeTwo(index: number) {
    Divider()
      .width(this.calculateLineWidth(index))
      .height(1)
      .backgroundColor('rgba(255, 75, 75, 1)')
      .margin({ top: 12, right: this.calculateLineMargin(index) })
  }

  // 构建虚线类型二：符号左侧
  @Builder
  buildAbstractLineTypeTwo(num: number, lineNum: number = 0) {
    Row() {
      ForEach(Array.from({ length: this.calculateLineNum(num) }),
        (item: number, index) => {
          if (this.calculateLineNum(num - 1) !== 0 && this.calculateLineNum(num - 1) % 2 === 1) {
            if (index % 2 === 0) {
              Row().width(4).height(1).backgroundColor('rgba(255, 255, 255, 1)')
            } else {
              Row().width(4).height(1).backgroundColor('rgba(226, 226, 226, 1)')
            }
          } else {
            if (index % 2 === 0) {
              Row().width(4).height(1).backgroundColor('rgba(226, 226, 226, 1)')
            } else {
              Row().width(4).height(1).backgroundColor('rgba(255, 255, 255, 1)')
            }
          }
        }, (item: number, index: number) => JSON.stringify(item) + index)
    }
    .width(this.calculateLineWidth(num))
    .height(1)
    .margin({ top: 12, right: this.calculateLineMargin(num) })
  }

  @Builder
  buildLine(index: number) {
    // type：0表示完成的线，1表示进行中的线
    if (this.order.orderConfig.orderProcess.processList.length !== 1) {
      if (this.processIndex >= index) {
        if (index === 0) {
          this.buildLineTypeOne(index)
        } else if (index === this.order.orderConfig.orderProcess.processList.length - 1) {
          this.buildLineTypeTwo(index)
        } else {
          this.buildLineTypeOne(index)
          this.buildLineTypeTwo(index)
        }
      } else {
        if (index === 0) {
          this.buildAbstractLineTypeOne(index)
        } else if (index === this.order.orderConfig.orderProcess.processList.length - 1) {
          this.buildAbstractLineTypeTwo(index)
        } else {
          this.buildAbstractLineTypeOne(index)
          this.buildAbstractLineTypeTwo(index)
        }
      }
    }
  }

  // 计算虚线中的实线数量
  calculateLineNum(index: number): number {
    return Math.floor((this.componentWidth / 2 - (this.processIndex === index ? 8 : 5) +
      this.offsetRaito * this.componentWidth) / 4)
  }

  // 计算线的长度
  calculateLineWidth(index: number): number {
    return this.componentWidth / 2 - (this.processIndex === index ? 8 : 5) + this.offsetRaito * this.componentWidth
  }

  // 计算线的边距
  calculateLineMargin(index: number): number {
    return this.componentWidth / 2 + (this.processIndex === index ? 8 : 5) - this.offsetRaito * this.componentWidth
  }

  // 单个步骤项
  @Builder
  buildProcessStep(index: number) {
    RelativeContainer() {
      if (this.processIndex === index) {
        // 当前的步骤
        Image($r('app.media.ic_process_step_ok'))
          .width(24)
          .height(24)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .margin({
            left: index % 2 === 0 ? 0 : this.offsetRaito * this.componentWidth * 2,
            right: index % 2 === 0 ? this.offsetRaito * this.componentWidth * 2 : 0
          })
          .id('icon')
      } else if (this.processIndex > index) {
        // 步骤已完成
        Row() {
          Row()
            .width(8)
            .height(8)
            .backgroundColor('rgba(255, 75, 75, 1)')
            .borderRadius(4)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .width(24)
        .height(24)
        .backgroundColor('rgba(255, 255, 255, 1)')
        .margin({
          left: index % 2 === 0 ? 0 : this.offsetRaito * this.componentWidth * 2,
          right: index % 2 === 0 ? this.offsetRaito * this.componentWidth * 2 : 0
        })
        .id('icon')
      } else {
        // 步骤未完成
        Row() {
          Row()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor('rgba(226, 226, 226, 1)')
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .width(24)
        .height(24)
        .backgroundColor('rgba(255, 255, 255, 1)')
        .margin({
          left: index % 2 === 0 ? 0 : this.offsetRaito * this.componentWidth * 2,
          right: index % 2 === 0 ? this.offsetRaito * this.componentWidth * 2 : 0
        })
        .id('icon')
      }

      Text(this.order.orderConfig.orderProcess.processList[index])
        .font({ size: 12, weight: FontWeight.Regular })
        .fontColor('rgba(0, 0, 0, 0.9)')
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top: { anchor: 'icon', align: VerticalAlign.Bottom }
        })
        .margin({
          top: 7,
          left: index % 2 === 0 ? 0 : this.offsetRaito * this.componentWidth * 2,
          right: index % 2 === 0 ? this.offsetRaito * this.componentWidth * 2 : 0
        })

      // 右侧或者左侧的延长线
      this.buildLine(index)
    }
    .layoutWeight(1)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.componentWidth = Number.parseInt(newValue.width.toString())
    })
  }

  build() {
    Row() {
      ForEach(this.order.orderConfig.orderProcess.processList, (item: string, index) => {
        // 构建单元
        this.buildProcessStep(index)
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }.width('100%')
  }
}