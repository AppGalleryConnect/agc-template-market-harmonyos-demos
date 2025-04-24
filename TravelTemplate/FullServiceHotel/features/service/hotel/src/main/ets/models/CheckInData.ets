@ObservedV2
export class CheckInData {
  @Trace checkInDateLabel: string = '';
  @Trace checkOutDateLabel: string = '';
  @Trace checkInDateDescription: string = '';
  @Trace checkOutDateDescription: string = '';
  @Trace roomTag: string[] = [];
  @Trace roomCount: number = 1;
  @Trace totalDays: number = 1;
  @Trace guestName: string = '';
  @Trace guestPhone: string = '';
  @Trace remark: string = '';
  @Trace actualPaidPrice: string = '';
}
