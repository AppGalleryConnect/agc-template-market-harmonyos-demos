import { ProcessStepsView } from 'recyclingservice_process_step';
import { OrderItem } from '../../viewmodel/MyOrderPageVM';
import { connectValuationStore, ValuationStore, RouterMap } from 'common';
import { phoneRouterControl, NavPageInfo, RouterPopInfo } from 'oh_router'
import { CustomerServiceDialogBuilder } from 'valuation_information';

interface ModifyAppointmentPayload {
  selectedPickupDate?: number
  selectedPickupRegion?: string
  selectedPickupDetail?: string
  selectedPickupName?: string
  selectedPickupPhone?: string
}

@ComponentV2
export struct MyOrderProcessOneView {
  @Param @Require order: OrderItem;
  // 步骤流程图数组
  @Local orderProcessList: Array<string> = []
  @Local store: ValuationStore = connectValuationStore()
  // 师傅热线控制变量
  @Local isPhone: boolean = false;

  aboutToAppear(): void {
    this.order.orderConfig.orderProcess.processList = ['提交订单', '邮寄寄出', '平台质检', '确认收款', '隐私清除']
    this.orderProcessList = this.order.orderConfig.orderProcess.processList
  }

  private formatVisitTime(ts: number): string {
    const d = new Date(ts)
    const pad = (n: number) => `${n < 10 ? '0' : ''}${n}`
    const m = d.getMonth() + 1
    const day = d.getDate()
    const hh = pad(d.getHours())
    const mm = pad(d.getMinutes())
    const end = new Date(d.getTime() + 30 * 60 * 1000)
    const eh = pad(end.getHours())
    const em = pad(end.getMinutes())
    const weeks = ['日', '一', '二', '三', '四', '五', '六']
    const w = weeks[d.getDay()]
    return `${m}月${day}日(周${w})${hh}:${mm}-${eh}:${em}`
  }

  private parseVisitTime(text: string): number | null {
    const m = /([0-9]{1,2})月([0-9]{1,2})日.*?([0-9]{2}):([0-9]{2})/.exec(text)
    if (!m) {
      return null
    }
    const month = parseInt(m[1], 10)
    const day = parseInt(m[2], 10)
    const hh = parseInt(m[3], 10)
    const mm = parseInt(m[4], 10)
    const now = new Date()
    const year = now.getFullYear()
    const dt = new Date(year, month - 1, day, hh, mm, 0)
    return dt.getTime()
  }

  @Builder
  dealWithHotlineDialog() {
    CustomerServiceDialogBuilder('客服', '000-****-0000', () => {
      this.isPhone = false
    }, $r('app.media.ic_public_close_sheet'), 170)
  }

  build() {
    Column() {
      // 订单师傅信息
      Row() {
        Image(this.order.orderConfig.masterAvatar).width(60).height(60)

        Column() {
          Row() {
            Text(this.order.orderConfig.masterName)
              .font({ size: 18, weight: FontWeight.Medium })
              .fontColor('rgba(0, 0, 0, 0.9)')
              .lineHeight(16)

            Image($r('app.media.ic_comment_star'))
              .width(16)
              .height(16)
              .margin({ left: 16 })
              .margin({ left: 16, bottom: 3 })

            Text(`${this.order.orderConfig.masterLevel}分`)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .font({ size: 14, weight: FontWeight.Medium })
              .lineHeight(16)
          }.height(24).alignItems(VerticalAlign.Center)

          Text(this.order.orderConfig.masterComment)
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .lineHeight(16)
            .margin({ top: 2 })
        }.margin({ left: 16 }).layoutWeight(1).alignItems(HorizontalAlign.Start)

        Column() {
          Column() {
            Image($r('app.media.ic_phone_image')).width(24).height(24)

            Text('电话')
              .font({ size: 10, weight: FontWeight.Medium })
              .fontColor('rgba(0, 0, 0, 0.6)')
              .width(20)
              .height(14)
          }.width('100%').height(38)
        }
        .width(24)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.isPhone = true
        })
      }
      .width('100%')
      .height(60)
      .margin({ top: 16, bottom: 16 })
      .padding({ left: 12, right: 14 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 分割线
      Row() {
        Divider().layoutWeight(1).margin({ left: 12, right: 12 }).backgroundColor('rgba(0, 0, 0, 0.05)')
      }.width('100%').height(1).backgroundColor(Color.White).margin({ bottom: 16 })

      // 上门取件
      Row() {
        Text() {
          Span('快递员将在').fontSize(16).fontColor('rgba(0, 0, 0, 1)')

          Span(this.order.orderConfig.visitTime)
            .fontSize(16)
            .fontColor('rgba(255, 75, 75, 1)')
            .margin({ left: 6, right: 6 })

          Span('上门取件').fontSize(16).fontColor('rgba(0, 0, 0, 1)')
        }
      }.width('100%').padding({ left: 12, right: 12 }).margin({ bottom: 12 })

      // 订单地址信息
      Column() {
        Column() {
          Column() {
            Text(`${this.order.orderConfig.visitAddress.user} ${this.order.orderConfig.visitAddress.phone.slice(0,
              3)}∗∗∗∗${this.order.orderConfig.visitAddress.phone.slice(-4)}`)
              .fontSize(14).fontColor('rgba(0, 0, 0, 0.8)').margin({ bottom: 8 })

            Text(this.order.orderConfig.visitAddress.address)
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.8)')
              .margin({ bottom: 16 })

            Row() {
              Text('修改上门地址/时间')
                .height(28)
                .padding({ left: 16, right: 16 })
                .fontColor('rgba(0, 0, 0, 0.6)')
                .font({ size: 14 , weight: FontWeight.Medium })
                .border({ radius: 14, width: 1, color: 'rgba(0, 0, 0, 0.2)' })
            }
            .onClick(() => {
              this.store.selectedPickupRegion = this.order.orderConfig.visitAddress.address
              this.store.selectedPickupDetail = ''
              const ts = this.parseVisitTime(this.order.orderConfig.visitTime)
              this.store.selectedPickupDate = ts ?? Date.now()

              const page: NavPageInfo = {
                pageName: RouterMap.MODIFY_APPOINTMENT_INFORMATION_PAGE,
                onPop: (_pop) => {
                  const candidate = _pop as RouterPopInfo
                  const payload = (candidate.popData as ModifyAppointmentPayload) ?? (_pop as ModifyAppointmentPayload)
                  if (payload?.selectedPickupDate !== undefined) {
                    this.store.selectedPickupDate = payload.selectedPickupDate
                    this.order.orderConfig.visitTime = this.formatVisitTime(payload.selectedPickupDate)
                  } else if (this.store.selectedPickupDate) {
                    this.order.orderConfig.visitTime = this.formatVisitTime(this.store.selectedPickupDate)
                  }
                  const region = payload?.selectedPickupRegion ?? this.store.selectedPickupRegion
                  const detail = payload?.selectedPickupDetail ?? this.store.selectedPickupDetail
                  const addr = `${region || ''}${detail || ''}`
                  if (addr && addr.length > 0) {
                    this.store.selectedPickupRegion = region || ''
                    this.store.selectedPickupDetail = detail || ''
                    this.order.orderConfig.visitAddress.address = addr
                  }
                  const phone = payload?.selectedPickupPhone ?? this.store.selectedPhone
                  const name = payload?.selectedPickupName ?? this.store.selectedName
                  if (phone || name) {
                    this.store.selectedName = name || ''
                    this.store.selectedPhone = phone || ''
                    // 修改订单的用户和电话
                    this.order.orderConfig.visitAddress.phone = phone || ''
                    this.order.orderConfig.visitAddress.user = name || ''
                  }
                }
              }
              phoneRouterControl.jumpPage(page)
            })
            .width('100%')
            .height(28)
            .justifyContent(FlexAlign.End)
            .margin({ bottom: 16 })
          }.margin({ left: 12, right: 12, top: 12 }).alignItems(HorizontalAlign.Start)
        }.width('100%').border({ radius: 8 }).backgroundColor('rgba(0, 0, 0, 0.05)')
      }.width('100%').padding({ left: 12, right: 12 })

      // 横向流程线
      Row() {
        ProcessStepsView({ array: this.orderProcessList, processIndex: 0 })
      }.width('100%').height(48).padding({ left: 12, right: 12 }).margin({ top: 16, bottom: 16 })

    }
    .width('100%')
    .backgroundColor(Color.White)
    .border({ radius: 8 })
    .bindSheet($$this.isPhone, this.dealWithHotlineDialog(),
      {
        showClose: false,
        detents: [170],
        preferType: SheetType.BOTTOM,
      })
  }
}
