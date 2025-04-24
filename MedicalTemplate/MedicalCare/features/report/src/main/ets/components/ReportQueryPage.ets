import { ReportDetailModel, ReportModel } from '../model/ReportModel'
import { ReportViewModel } from '../viewmodel/ReportViewModel'
import { CommonEmptyView, CommonNavDestination, SkeletonTheme, UISkeleton } from 'common'

@Builder
export function ReportQueryPageBuilder() {
  CommonNavDestination({ title: '报告查询' }) {
    ReportQueryPage()
  }
}

@ComponentV2
export struct ReportQueryPage {
  @Local viewModel: ReportViewModel = new ReportViewModel()
  @Local periodIndex: number = 0

  aboutToAppear(): void {
    this.viewModel.initData()
  }

  build() {
    Column({ space: 8 }) {
      Column({ space: 16 }) {
        Row() {
          Text(`当前就诊人：${this.viewModel.patient.patientName || '正在加载'}`)
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .layoutWeight(1)
          Row({ space: 6 }) {
            Text('切换就诊人')
              .fontSize(14)
            Image($r('sys.media.ohos_ic_public_arrow_down'))
              .width(12)
              .height(12)
          }
          .borderRadius(20)
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .padding({
            top: 5,
            bottom: 5,
            left: 8,
            right: 8
          })
          .bindMenu(this.viewModel.patientList.map((value) => {
            return {
              value: value.patientName,
              action: () => {
                this.viewModel.changePatient(value)
              }
            } as MenuElement
          }))
        }

        Stack() {
          UISkeleton({ loading: this.viewModel.isLoading, options: [1, 1] }) {
            List({ space: 8 }) {
              ForEach(this.viewModel.reportList, (item: ReportModel, index) => {
                ListItem() {
                  Button(item.period)
                    .width(96)
                    .height(36)
                    .fontSize(14)
                    .borderRadius(21)
                    .padding({
                      top: 10,
                      bottom: 10,
                      left: 20,
                      right: 20
                    })
                    .backgroundColor(this.periodIndex === index ? $r('sys.color.ohos_id_color_emphasize') :
                    $r('sys.color.ohos_id_color_button_normal'))
                    .fontColor(this.periodIndex === index ? $r('sys.color.ohos_id_color_text_primary_contrary') :
                    $r('sys.color.ohos_id_color_text_primary'))
                    .onClick(() => {
                      this.periodIndex = index
                    })
                }
              }, (item: ReportModel) => JSON.stringify(item))
            }
            .width('auto')
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
          }
        }
        .width('100%')
        .height(40)
      }
      .padding(16)
      .backgroundColor($r('sys.color.ohos_id_color_background'))

      if (this.viewModel.isLoading) {
        Stack() {
          UISkeleton({
            loading: this.viewModel.isLoading,
            theme: SkeletonTheme.PARAGRAPH,
            options: [
              1,
              { margin: { bottom: 8 } },
              1,
              { margin: { bottom: 8 } }
            ]
          })
        }
        .width('100%')
        .height('auto')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .padding(16)
      } else {
        List({ space: 25 }) {
          if (this.viewModel.reportList[this.periodIndex]?.detail.length === 0) {
            CommonEmptyView()
          }
          ForEach(this.viewModel.reportList[this.periodIndex]?.detail, (item: ReportDetailModel, index) => {
            ListItem() {
              Column({ space: 15 }) {
                Row() {
                  Text(item.type)
                    .fontSize(14)
                    .fontWeight(500)
                    .textAlign(TextAlign.Start)
                    .layoutWeight(1)

                  Text(item.time)
                    .fontSize(12)
                    .textAlign(TextAlign.End)
                }

                Row() {
                  Text(item.departmentName)
                    .fontSize(12)
                    .textAlign(TextAlign.Start)
                    .layoutWeight(1)

                  Text('详情')
                    .fontSize(12)
                    .textAlign(TextAlign.End)
                    .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                    .onClick(() => {
                      this.viewModel.onDetailClick(this.periodIndex, index)
                    })
                }
              }
            }
          }, (item: ReportDetailModel) => JSON.stringify(item))
        }
        .divider({
          strokeWidth: 0.5,
          color: $r('sys.color.ohos_id_color_list_separator')
        })
        .layoutWeight(1)
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .padding(16)
      }
    }

  }
}