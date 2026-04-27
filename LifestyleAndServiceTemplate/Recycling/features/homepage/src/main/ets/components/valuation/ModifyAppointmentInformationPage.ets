import { connectValuationStore, RouterMap, ValuationStore, ValuationStoreAPI } from 'common'
import { TimeSelect } from 'module_time_select';
import { NavPageInfo, phoneRouterControl, RouterPopInfo } from 'oh_router';
import { AddressManagerPageBuilder } from 'person';
import { JSON } from '@kit.ArkTS';

interface ModifyAppointmentPayload {
  selectedPickupDate?: number
  selectedPickupRegion?: string
  selectedPickupDetail?: string
  selectedPickupName?: string
  selectedPickupPhone?: string
}

interface AddressLike {
  name: string
  phone: string
  province?: string
  city?: string
  district?: string
  street?: string
  detail?: string
}

@Builder
export function ModifyAppointmentInformationPageBuilder() {
  ModifyAppointmentInformationPage()
}

phoneRouterControl.registerPageBuilder('ModifyAppointmentInformationPage',
  wrapBuilder(ModifyAppointmentInformationPageBuilder))

@ComponentV2
export struct ModifyAppointmentInformationPage {
  @Local name: string = ''
  @Local cardNo: string = ''
  @Local store: ValuationStore = connectValuationStore()
  @Local date: Date | null = null;
  @Local selectedRegion: string = ''
  @Local selectedDetail: string = ''

  aboutToAppear(): void {
    if (this.store.selectedPickupDate) {
      this.date = new Date(this.store.selectedPickupDate)
    }
    this.selectedRegion = this.store.selectedPickupRegion
    this.selectedDetail = this.store.selectedPickupDetail
  }

  @Computed
  get getTimeText() {
    if (this.store.selectedPickupDate) {
      return this.formatDate(new Date(this.store.selectedPickupDate));
    }
    return '请选择上门时间';
  }

  @Computed
  get getTimeTextOpacity() {
    if (this.store.selectedPickupDate) {
      return 1;
    }
    return 0.4;
  }

  private formatDate(d: Date): string {
    const pad = (n: number) => `${n < 10 ? '0' : ''}${n}`
    const m = pad(d.getMonth() + 1)
    const day = pad(d.getDate())
    const hh = pad(d.getHours())
    const mm = pad(d.getMinutes())
    const end = new Date(d.getTime() + 30 * 60 * 1000)
    const eh = pad(end.getHours())
    const em = pad(end.getMinutes())
    const weeks = ['日', '一', '二', '三', '四', '五', '六']
    const w = weeks[d.getDay()]
    return `上门时间  ${m}月${day}日(星期${w})${hh}:${mm}-${eh}:${em}`
  }

  private extractField(json: string, key: string): string | null {
    const resultStart: number = json.indexOf('"result":')
    if (resultStart < 0) {
      return null
    }
    const resultJson: string = json.substring(resultStart, json.length - 1)
    const pattern = `"${key}":"`
    const start = resultJson.indexOf(pattern)
    if (start < 0) {
      return null
    }
    const from = start + pattern.length
    const end = resultJson.indexOf('"', from)
    if (end < 0) {
      return null
    }
    return resultJson.substring(from, end)
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          Row() {
            Image($r('app.media.img_ring_red'))
              .width(15)
              .height(15)
            Text(`${(this.store.selectedPickupRegion || this.store.selectedPickupDetail) ?
              `${this.store.selectedPickupRegion}${this.store.selectedPickupDetail}` : '请选择地址'}`)
              .fontSize(14)
              .width('80%')
              .textAlign(TextAlign.Start)
              .fontColor('rgba(0,0,0,0.95)')
              .margin({ left: 8, right: 8 })
              .width('80%')

            Blank()

            Text() {
              Span('更多')
                .fontSize(12)
                .fontColor('rgba(255,75,75,1)')
              ImageSpan($r('app.media.img_right_red'))
                .width(15)
                .height(15)
            }

          }
          .padding({
            left: 12,
            right: 12,
            top: 12,
            bottom: 12
          })
          .borderRadius(8)
          .borderWidth(1)
          .borderColor('rgba(247,248,250,1)')
          .margin({ bottom: 8 })
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .onClick(() => {
            const modifyAppointmentInformationPageParams: NavPageInfo = {
              pageName: RouterMap.ADDRESS_MANAGER_PAGE,
              builder: wrapBuilder(AddressManagerPageBuilder),
              param: '修改预约信息',
              onPop: (_pop: PopInfo) => {
                try {
                  const s = JSON.stringify(_pop)
                  const street = this.extractField(s, 'street')
                  const detail = this.extractField(s, 'detail')
                  const name = this.extractField(s, 'name')
                  const phone = this.extractField(s, 'phone')
                  this.selectedRegion = street ?? ''
                  this.selectedDetail = detail ?? ''
                  this.store.selectedPickupRegion = this.selectedRegion
                  this.store.selectedPickupDetail = this.selectedDetail
                  this.store.selectedName = name ?? ''
                  this.store.selectedPhone = phone ?? ''
                } catch (e) {
                }
              }
            }
            phoneRouterControl.jumpPage(modifyAppointmentInformationPageParams)
          })

          Row() {
            Image($r('app.media.img_ring_blue'))
              .width(15)
              .height(15)
              .margin({ right: 8 })
            TimeSelect({
              label: this.getTimeText,
              selectedTimestamp: this.store.selectedPickupDate ?? null,
              timeOptions: {
                days: 7,
                startTime: '06:59:00',
                endTime: '19:30:00',
              },
              styleOptions: {
                dayFg: '#606060',
                dayFgSelected: '#FFFFFF',
                timeBg: '#FFFFFF',
                timeBgSelected: '#FFECEC',
                timeBorder: '#FFFFFF',
                timeBorderSelected: '#FFECEC',
              },
              onTimeSelect: (dateTime: Date) => {
                this.date = dateTime
                this.store.selectedPickupDate = dateTime.getTime()
              },
            })
              .opacity(this.getTimeTextOpacity)
          }
          .padding({
            left: 12,
            right: 12,
            top: 12,
            bottom: 12
          })
          .borderRadius(8)
          .borderWidth(1)
          .borderColor('rgba(247,248,250,1)')
          .margin({ bottom: 8 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('92%')
        .alignItems(HorizontalAlign.Start)
        .borderRadius(8)
        .backgroundColor(Color.White)
        .padding({
          left: 12,
          right: 12,
          top: 12,
          bottom: 12
        })
        .margin({ left: '4%', right: '4%', top: 12 })

        Blank()

        Row() {
          Button('确认修改')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,75,75,1)')
            .borderRadius(24)
            .height(48)
            .width('90%')
            .onClick(() => {
              if (this.date) {
                this.store.selectedPickupDate = this.date.getTime()
              }
              if (this.selectedRegion || this.selectedDetail) {
                this.store.selectedPickupRegion = this.selectedRegion
                this.store.selectedPickupDetail = this.selectedDetail
              }
              const payload: ModifyAppointmentPayload = {
                selectedPickupDate: this.store.selectedPickupDate ?? undefined,
                selectedPickupRegion: this.store.selectedPickupRegion || undefined,
                selectedPickupDetail: this.store.selectedPickupDetail || undefined,
                selectedPickupName: this.store.selectedName || undefined,
                selectedPickupPhone: this.store.selectedPhone || undefined
              }
              const popInfo: RouterPopInfo = { popData: payload }
              phoneRouterControl.popPage(popInfo)
            })
        }
        .width('100%')
        .height(72)
        .margin({ bottom: 28 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(242,243,245,1)')
    }
    .title('修改预约信息')
    .hideToolBar(true)
    .padding({ top: 44 })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
