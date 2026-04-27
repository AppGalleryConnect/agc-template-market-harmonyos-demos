import { RemarksModel } from '../common/model/RemarksModel'

@ObservedV2
export class ReimbursementVoucherPageVM {
  @Trace check: boolean = true
  @Trace title: string = ''
  @Trace email: string = ''
  @Trace remarks: RemarksModel[] =
    [
      new RemarksModel('订单号', false), new RemarksModel('行程信息', false), new RemarksModel('航班号', false),
      new RemarksModel('乘机人', false), new RemarksModel('舱位', false),
    ]

  isValidEmailDetailed(email: string): boolean {
    const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return regex.test(email);
  }
}