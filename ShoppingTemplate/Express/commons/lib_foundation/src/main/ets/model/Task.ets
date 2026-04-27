import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class Task {
  // 任务id
  id: number = 0;
  // 任务标题
  title: string = '';
  // 任务描述
  description: string = '';
  // 任务按钮文案
  actionText: string = '';
  // 任务类型 0: 每日, 1: 一次性
  taskType: number = 0;
  // 任务目标完成次数
  targetCount: number = 1;
  // 任务完成获取的积分
  rewardValue: number = 0;
  // 关联字段 (来自 user_task 表)
  currentCount?: number = 0; // 当前已完成次数
  isFinished?: boolean = false; // 是否达成目标
  isReceived?: boolean = false; // 是否领取

  // 静态解析方法
  static fromResultSet(resultSet: relationalStore.ResultSet): Task {
    const task = new Task();

    try {
      task.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      task.title = resultSet.getString(resultSet.getColumnIndex('title'));
      task.description = resultSet.getString(resultSet.getColumnIndex('description'));
      task.actionText = resultSet.getString(resultSet.getColumnIndex('action_text'));
      task.taskType = resultSet.getLong(resultSet.getColumnIndex('task_type'));
      task.targetCount = resultSet.getLong(resultSet.getColumnIndex('target_count'));
      task.rewardValue = resultSet.getLong(resultSet.getColumnIndex('reward_value'));
      // 如果是通过 JOIN 查询出来的进度字段
      task.currentCount = resultSet.getLong(resultSet.getColumnIndex('current_count'));
      task.isFinished = resultSet.getLong(resultSet.getColumnIndex('is_finished')) === 1;
      task.isReceived = resultSet.getLong(resultSet.getColumnIndex('is_received')) === 1;
    } catch (error) {
      Logger.error('Task', `task fromResultSet failed: error: ${JSON.stringify(error)}`)
    }
    return task;
  }
}