import { Task } from '../model/Task';

export class MockTaskData {

  public static readonly DEFAULT_TASKS: Task[] = [
    {
      id: 1,
      title: '天天领积分',
      description: '每日进入积分页面，立领10积分',
      actionText: '领取',
      taskType: 0,
      targetCount: 1,
      rewardValue: 10,
    },
    {
      id: 2,
      title: '看视频领积分',
      description: '看视频领积分，每次得10积分',
      actionText: '去观看',
      taskType: 0,
      targetCount: 5,
      rewardValue: 10,
    },
    {
      id: 3,
      title: '下载xxAPP',
      description: '下载xx应用可得100积分',
      actionText: '去下载',
      taskType: 1,
      targetCount: 1,
      rewardValue: 100,
    },
  ]
}