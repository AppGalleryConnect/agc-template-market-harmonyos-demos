import { PointsApis, UserPointsRecordItem } from 'lib_network'
import { UserPointsUsedType } from '../commons/Enums'

@ObservedV2
export class PointsRecordVM {
  @Trace
  month: string = ''
  @Trace
  totalPoints: number = 0
  @Trace
  recordList: UserPointsRecordItem[] = []
  @Trace
  selectedType: UserPointsUsedType = UserPointsUsedType.INCOME
  @Trace
  showMonthPicker: boolean = false
  @Trace
  isLoading: boolean = false

  public async getPointRecord(type: UserPointsUsedType = UserPointsUsedType.INCOME) {
    this.selectedType = type
    if (!this.month) {
      const date = new Date()
      const m = date.getMonth() + 1
      this.month = `${date.getFullYear()}-${m < 10 ? '0' + m : m}`
    }
    this.isLoading = true
    try {
      const res = await PointsApis.getUserPointsRecord(this.month)
      if (res.code === 0) {
        this.totalPoints = res.totalPoints
        this.recordList = res.list.filter((record: UserPointsRecordItem) => record.type === this.selectedType)
      }
    } finally {
      this.isLoading = false
    }
  }

  public async handleMonthChange(month: string) {
    this.month = month
    this.isLoading = true
    try {
      const res = await PointsApis.getUserPointsRecord(month)
      if (res.code === 0) {
        this.totalPoints = res.totalPoints
        this.recordList = res.list.filter((record: UserPointsRecordItem) => record.type === this.selectedType)
      }
    } finally {
      this.isLoading = false
    }
    this.showMonthPicker = false
  }
}
