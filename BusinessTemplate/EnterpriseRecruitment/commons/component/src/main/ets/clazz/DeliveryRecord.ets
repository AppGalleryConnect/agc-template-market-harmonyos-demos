@ObservedV2
export class DeliveryRecord {
  @Trace jobId: string = ''
  @Trace submitTime: string = ''
  @Trace status: number = 0
}