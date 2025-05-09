import { CheckInRecord } from 'commonlib';

const pianoTask1: CheckInRecord = {
  taskId: 101, // 热身练习
  activityId: 1,
  textDetail: '今天的热身练习完成了10分钟的音阶，手指的灵活性有了明显提升。感觉每个音符都能更加精准地弹奏。',
  videoDetail:[],
  audioDetail:[],
  createTime: '1675246500000', // 时间戳表示
};




export class CheckInRecordDatasetMock {
  private static _recordList: CheckInRecord[] = [pianoTask1];

  public static commitUserCheckIn(data: CheckInRecord): boolean {
    CheckInRecordDatasetMock._recordList.push(data);
    return true;
  }

  public static getUserCheckInRecordList(activityId: number): CheckInRecord[] {
    const list = CheckInRecordDatasetMock._recordList.filter((item) => item.activityId === activityId);
    return list;
  }
}
