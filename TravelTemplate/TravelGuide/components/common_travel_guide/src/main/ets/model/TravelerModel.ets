import { MockTravelerService } from '../service/MockService'

@ObservedV2
export class TravelerModel {
  @Trace id: number | string  = 0
  // 名字
  @Trace name: string =''
  // 身份证
  @Trace idNumber: string =''
  // 手机号
  @Trace phone: string =''
  // 是否选中
  @Trace select: boolean = false
  //0编辑1删除
  @Trace show: number = 0
}

@ObservedV2
export class TravelerListPageVM {
  @Trace travelerList: TravelerModel[] = MockTravelerService.travelerResult
}
@ObservedV2
export class SelectTravelerListPageVM {
  @Trace travelerList: TravelerModel[] = MockTravelerService.travelerResult
}