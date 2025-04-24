export class ReportModel {
  // 时间范围
  period: string = ''
  detail: ReportDetailModel[] = []
}

export class ReportDetailModel {
  // 报告类型
  type: string = ''
  // 科室名
  departmentName: string = ''
  // 日期
  time: string = ''
  // 查看报告URL
  url: string = 'https://developer.huawei.com'
}
