import { Task } from 'lib_foundation';

export interface IDateRange {
  startTime: number,
  endTime: number,
}

/**
 * 日常任务
 */
@ObservedV2
export class TaskModel {
  // 任务id
  @Trace id: number = 0;
  // 任务标题
  @Trace title: string = '';
  // 任务描述
  @Trace description: string = '';
  // 任务按钮文案
  @Trace actionText: string = '';
  // 任务类型 0: 每日, 1: 一次性
  @Trace taskType: number = 0;
  // 任务目标完成次数
  @Trace targetCount: number = 1;
  // 任务完成获取的积分
  @Trace rewardValue: number = 0;
  // 当前已完成次数
  @Trace currentCount: number = 0;
  // 是否达成目标
  @Trace isFinished: boolean = false;
  // 是否领取
  @Trace isReceived: boolean = false;

  constructor(task?: Task) {
    if (task) {
      this.id = task.id;
      this.title = task.title;
      this.description = task.description;
      this.actionText = task.actionText;
      this.taskType = task.taskType;
      this.targetCount = task.targetCount;
      this.rewardValue = task.rewardValue;
      this.currentCount = task.currentCount || 0;
      this.isFinished = task.isFinished || false;
      this.isReceived = task.isReceived || false;
    }
  }
}