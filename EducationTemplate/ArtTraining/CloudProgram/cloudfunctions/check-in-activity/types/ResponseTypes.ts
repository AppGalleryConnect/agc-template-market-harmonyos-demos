export interface CheckInActivityResp {
  activityId: number;
  name: string;
  summary: string;
  detail: string;
  mainDiagram: string;
  price: number;
  orderTime: string;
  status: number; // 0未订阅， 1打卡中， 2已完成
  requirement: TaskRequirement;
  participationCount: number;
  historyCount: number;
  taskDirectory: CheckInTaskItem[];
}

export interface TaskRequirement {
  textSwitch: number;
  textMinLimit: number;
  audioSwitch: number;
  audioMinLimit: number;
  videoSwitch: number;
  videoMinLimit: number;
  pictureSwitch: number;
  pictureMinLimit: number;
}

export interface CheckInTaskItem {
  taskName: string;
  taskId: number;
  taskDetail: string;
  taskStatus: number; // 1未打卡 2已打卡
}

export interface RecordResp {
  taskId: number;
  activityId: number;
  textDetail: string;
  pictureDetail: string[];
  audioDetail: string[];
  videoDetail: string[];
  createTime: string;
}
