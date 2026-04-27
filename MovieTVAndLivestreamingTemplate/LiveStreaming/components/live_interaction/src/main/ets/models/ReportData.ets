@ObservedV2
export class ReportItem {
  reason: string
  @Trace isSelected: boolean

  constructor(reason: string, isSelected: boolean) {
    this.reason = reason
    this.isSelected = isSelected
  }
}


@ObservedV2
export class ReportData {
  @Trace topReasonList: Array<ReportItem> = [
    new ReportItem('色情低俗', false), new ReportItem('违法违规', false), new ReportItem('血腥暴力', false),
    new ReportItem('危险行为', false), new ReportItem('垃圾广告', false), new ReportItem('未成年人相关', false)
  ]
  @Trace bottomReasonList: Array<ReportItem> = [
    new ReportItem('引导私下交易', false), new ReportItem('误导消费', false), new ReportItem('不良行为', false),
    new ReportItem('虚假宣传', false), new ReportItem('侮辱谩骂', false), new ReportItem('外挂', false),
    new ReportItem('淫秽色情', false), new ReportItem('盗播', false), new ReportItem('引导赌博', false),
    new ReportItem('诱导刷礼物', false), new ReportItem('违禁物品', false), new ReportItem('欺诈', false)
  ]
}