import { CheckInActivity, CheckInTaskItem } from 'commonlib';
import { TaskIntroTabMap } from '../constants/Enums';

export interface TaskIntroTabItem {
  label: string;
  type: TaskIntroTabMap;
}

export interface CheckInLogRouteParam {
  activity: CheckInActivity;
  task: CheckInTaskItem;
}

export interface TaskCheckInPopParam{
  needUpdate: boolean;
}
