import { OrderItem } from '../../viewmodel/MyOrderPageVM';
import { CommonTimeLine, OrderDetailBean } from 'module_time_line';
import { OffsetRatio, ProcessStepsView } from 'recyclingservice_process_step';
import { CopyBoardUtil } from '../../utils/CopyBoardUtil';

@ComponentV2
export struct MyOrderProcessThreeView {
  @Param @Require order: OrderItem;
  // 订单类型
  @Param orderType: string = ''
  // 步骤流程图数组
  @Local orderProcessList: Array<string> = []

  aboutToAppear(): void {
    if (this.orderType === '取消订单') {
      this.order.orderConfig.orderProcess.processList = ['提交订单', '订单已取消']
    } else if (this.orderType === '平台质检-取消订单-确认收货' || this.orderType === '平台质检-取消订单-确认收货2') {
      this.order.orderConfig.orderProcess.processList = ['提交订单', '邮寄寄出', '平台质检', '取消订单', '商品签收']
    } else if (this.orderType === '邮件寄出') {
      this.order.orderConfig.orderProcess.processList = ['提交订单', '邮寄寄出', '取消订单', '商品签收']
    } else {
      this.order.orderConfig.orderProcess.processList = ['提交订单', '邮寄寄出', '平台质检', '确认收款', '隐私清除']
    }
    this.orderProcessList = this.order.orderConfig.orderProcess.processList
  }

  // 根据订单类型进行判断
  getTimeLineListByOrderType(): Array<OrderDetailBean> {
    this.order.orderConfig.orderProcess.processArray.forEach((item: OrderDetailBean, index: number) => {
      if (index === this.getMaxStepByOrderType() - 1) {
        item.nodeStatus = 1
      } else {
        item.nodeStatus = 0
      }
    })
    return this.order.orderConfig.orderProcess.processArray.filter((item: OrderDetailBean, index: number) => {
      if (index <= this.getMaxStepByOrderType() - 1) {
        return true
      }
      return false
    })
  }

  // 根据订单类型获取
  getBackTimeLineListByOrderType() {
    if (this.orderType === '邮件寄出') {
      this.order.orderConfig.orderProcessBack2.processArray.forEach((item: OrderDetailBean, index: number) => {
        if (index === this.getBackMaxStepByOrderType() - 1) {
          item.nodeStatus = 1
        } else {
          item.nodeStatus = 0
        }
      })
      return this.order.orderConfig.orderProcessBack2.processArray.filter((item: OrderDetailBean, index: number) => {
        if (index <= this.getBackMaxStepByOrderType() - 1) {
          return true
        }
        return false
      })
    } else {
      this.order.orderConfig.orderProcessBack1.processArray.forEach((item: OrderDetailBean, index: number) => {
        if (index === this.getBackMaxStepByOrderType() - 1) {
          item.nodeStatus = 1
        } else {
          item.nodeStatus = 0
        }
      })
      return this.order.orderConfig.orderProcessBack1.processArray.filter((item: OrderDetailBean, index: number) => {
        if (index <= this.getBackMaxStepByOrderType() - 1) {
          return true
        }
        return false
      })
    }
  }

  // 根据订单类型获取最大步骤数
  getMaxStepByOrderType(): number {
    if (this.orderType === '运输中') {
      return 2
    } else if (this.orderType === '派件中') {
      return 3
    } else if (this.orderType === '已送达') {
      return 4
    } else if (this.orderType === '确认收款') {
      return 4
    } else if (this.orderType === '取消订单') {
      return 0
    } else if (this.orderType === '已完成') {
      return 4
    } else if (this.orderType === '平台质检-取消订单-确认收货') {
      return 4
    } else if (this.orderType === '平台质检-取消订单-确认收货2') {
      return 4
    } else {
      return 0
    }
  }

  // 邮件寄出订单类型最大步骤数
  getBackMaxStepByOrderType(): number {
    if (this.orderType === '邮件寄出') {
      return 5
    } else if (this.orderType === '平台质检-取消订单-确认收货') {
      return 3
    } else if (this.orderType === '平台质检-取消订单-确认收货2') {
      return 4
    } else {
      return 0
    }
  }

  // 根据订单类型获取流程下标
  getProcessIndexByOrderType(): number {
    if (this.orderType === '运输中') {
      return 1
    } else if (this.orderType === '派件中') {
      return 1
    } else if (this.orderType === '已送达') {
      return 2
    } else if (this.orderType === '确认收款') {
      return 3
    } else if (this.orderType === '取消订单') {
      return 1
    } else if (this.orderType === '已完成') {
      return 4
    } else if (this.orderType === '平台质检-取消订单-确认收货') {
      return 3
    } else if (this.orderType === '平台质检-取消订单-确认收货2') {
      return 4
    } else if (this.orderType === '邮件寄出') {
      return 2
    } else {
      return 0
    }
  }

  build() {
    Column() {
      if (this.orderType !== '取消订单') {
        // 订单地址信息
        Column() {
          if (this.orderType !== '邮件寄出') {
            Column() {
              Column() {
                // 物流信息
                Column() {
                  Text('物流信息')
                    .font({ size: 16, weight: FontWeight.Medium })
                    .fontColor('rgba(0, 0, 0, 1)')
                    .height(21)

                  Row() {
                    Text(`运单号：${this.order.orderConfig.expressNo}`)
                      .fontColor('rgba(0, 0, 0, 0.6)')
                      .font({ size: 12, weight: FontWeight.Regular })

                    Image($r('app.media.ic_copy_image')).width(16).height(16).margin({ left: 8 })
                      .onClick(() => {
                        // 复制到粘贴板
                        CopyBoardUtil.instance.copy(this.order.orderConfig.expressNo, '运单号')
                      })
                  }
                }.width('100%').padding({ left: 4 }).alignItems(HorizontalAlign.Start)

                // 时间轴
                CommonTimeLine({
                  timeLineList: this.getTimeLineListByOrderType(),
                  totalSize: this.getMaxStepByOrderType()
                }).width('100%').margin({ top: 16 })

              }.margin({ left: 12, right: 12, top: 12 }).alignItems(HorizontalAlign.Start)

            }.width('100%').border({ radius: 8 }).backgroundColor('rgba(0, 0, 0, 0.05)')
          }

          if (this.orderType === '平台质检-取消订单-确认收货' || this.orderType === '平台质检-取消订单-确认收货2' ||
            this.orderType === '邮件寄出') {
            Column() {
              Column() {
                // 物流信息
                Column() {
                  Text('物流信息')
                    .font({ size: 16, weight: FontWeight.Medium })
                    .fontColor('rgba(0, 0, 0, 1)')
                    .height(21)

                  Row() {
                    Text(`运单号：${this.order.orderConfig.expressNoBack}`)
                      .fontColor('rgba(0, 0, 0, 0.6)')
                      .font({ size: 12, weight: FontWeight.Regular })

                    Image($r('app.media.ic_copy_image')).width(16).height(16).margin({ left: 8 })
                      .onClick(() => {
                        // 复制到粘贴板
                        CopyBoardUtil.instance.copy(this.order.orderConfig.expressNoBack, '运单号')
                      })
                  }
                }.width('100%').padding({ left: 4 }).alignItems(HorizontalAlign.Start)

                // 时间轴
                CommonTimeLine({
                  timeLineList: this.getBackTimeLineListByOrderType(),
                  totalSize: this.getBackMaxStepByOrderType()
                }).width('100%').margin({ top: 16 })

              }.margin({ left: 12, right: 12, top: 12 }).alignItems(HorizontalAlign.Start)
            }.width('100%').border({ radius: 8 }).backgroundColor('rgba(0, 0, 0, 0.05)').margin({ top: 12 })
          }

        }.width('100%').padding({ left: 12, right: 12, top: 14 })
      }

      // 横向流程线
      Row() {
        ProcessStepsView({
          array: this.orderProcessList,
          offsetRatio: this.orderProcessList.length === 2 ? OffsetRatio.Offset_Ratio7 : OffsetRatio.Offset_Ratio_Normal,
          processIndex: this.getProcessIndexByOrderType()
        })
      }.width('100%').height(48).padding({ left: 12, right: 12 }).margin({ top: 16, bottom: 16 })

    }
    .width('100%')
    .backgroundColor(Color.White)
    .border({ radius: 8 })
  }
}