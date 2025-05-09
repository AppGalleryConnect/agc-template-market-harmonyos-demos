import { CheckInRecord } from 'commonlib';

@ObservedV2
export class CheckInRecordModel implements CheckInRecord {
  @Trace taskId: number = -1;
  @Trace activityId: number = -1;
  @Trace textDetail: string = '';
  @Trace pictureDetail: ResourceStr[] = [];
  @Trace audioDetail: ResourceStr[] = [];
  @Trace videoDetail: ResourceStr[] = [];
  @Trace createTime: string = '';
}