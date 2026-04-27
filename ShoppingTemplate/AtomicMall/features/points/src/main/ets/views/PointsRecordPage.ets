import { Formatter } from 'lib_foundation'
import { UserPointsRecordItem } from 'lib_network'
import { buildCommonEmptyStatus } from 'lib_widget'
import { UserPointsUsedType } from '../commons/Enums'
import { MonthPicker } from '../components/MonthPicker'
import { PointsRecordVM } from '../viewmodels/PointsRecordVM'

@Builder
export function buildPointsRecordPage() {
  PointsRecordPage()
}

@ComponentV2
struct PointsRecordPage {
  vm: PointsRecordVM = new PointsRecordVM()

  build() {
    NavDestination() {
      Column() {
        Text('积分余额').fontColor($r('app.color.font_color_level1')).fontSize($r('app.float.font_size_14'))
        Text((this.vm.totalPoints ?? 0).toString()).fontWeight(FontWeight.Bold)
        Column() {
          this.buildRecordHeader()
          this.buildRecordList()
        }
        .backgroundColor($r('app.color.background_color_primary'))
        .width($r('app.string.size_percent_full'))
        .borderRadius($r('app.float.border_radius_l'))
        .padding($r('app.float.space_m'))
        .margin({ top: $r('app.float.space_m') })
      }
      .alignItems(HorizontalAlign.Center)
      .width($r('app.string.size_percent_full'))
      .padding($r('app.float.space_l'))
    }
    .title('积分记录')
    .linearGradient({
      colors: [['#33e64566', 0], ['#f1f3f5', 0.3]],
    })
    .onReady(() => {
      this.vm.getPointRecord()
    })
  }

  @Builder
  buildRecordHeader() {
    Row() {
      Row({ space: 12 }) {
        ForEach([0, 1], (type: number) => {
          Column() {
            Text(type === UserPointsUsedType.INCOME ? '收入' : '支出')
              .fontColor(this.vm.selectedType === type ? $r('app.color.theme_color') :
                $r('app.color.font_color_level2'))
              .fontSize($r('app.float.font_size_14'))
            Divider()
              .color($r('app.color.theme_color'))
              .strokeWidth(2)
              .width(20)
              .margin({ top: $r('app.float.space_xs') })
              .visibility(this.vm.selectedType === type ? Visibility.Visible : Visibility.Hidden)
          }
          .onClick(() => {
            this.vm.getPointRecord(type)
          })
        }, (type: number) => type.toString())
      }

      Row() {
        Text(this.vm.month)
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
        SymbolGlyph($r('sys.symbol.chevron_down'))
      }
      .onClick(() => {
        this.vm.showMonthPicker = true
      })
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.space_l') })
    .bindSheet($$this.vm.showMonthPicker, this.buildMonthPicker(), {
      height: 360,
      preferType: SheetType.CENTER,
      title: { title: '选择月份' },
    })
  }

  @Builder
  buildRecordList() {
    if (this.vm.isLoading) {
      Column() {
        LoadingProgress()
          .width(32)
          .height(32)
          .color($r('app.color.theme_color'))
        Text('加载中...')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
          .margin({ top: $r('app.float.space_m') })
      }
      .width($r('app.string.size_percent_full'))
      .padding($r('app.float.space_xl'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else if (this.vm.recordList.length > 0) {
      List({ space: 32 }) {
        ForEach(this.vm.recordList, (record: UserPointsRecordItem) => {
          ListItem() {
            Column({ space: 12 }) {
              Text(record.label)
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('app.color.font_color_level1'))
              Row() {
                Text(Formatter.formatFullDate(new Date(record.time)))
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.font_color_level2'))
                Text() {
                  Span(record.points > 0 ? '+' : '')
                  Span(record.points.toString())
                }
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('app.color.theme_color'))
              }
              .width($r('app.string.size_percent_full'))
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width($r('app.string.size_percent_full'))
            .alignItems(HorizontalAlign.Start)
          }
        }, (record: UserPointsRecordItem) => `${record.type}_${record.label}_${record.time}`)
      }
      .divider({ strokeWidth: 1 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    } else {
      Column() {
        buildCommonEmptyStatus('暂无数据')
      }
      .height(200)
    }

    Divider()
      .margin({ top: $r('app.float.space_l'), bottom: $r('app.float.space_l') })
    Text('积分明细仅供参考，实际累计积分以账户积分余额为准')
      .fontSize($r('app.float.font_size_10'))
      .fontColor($r('app.color.font_color_level3'))
  }

  @Builder
  buildMonthPicker() {
    MonthPicker({
      initMonth: this.vm.month,
      handleConfirm: (dateStr: string) => {
        this.vm.handleMonthChange(dateStr)
      },
      handleCancel: () => {
        this.vm.showMonthPicker = false
      },
    })
      .constraintSize({ maxWidth: 360 })
  }
}
