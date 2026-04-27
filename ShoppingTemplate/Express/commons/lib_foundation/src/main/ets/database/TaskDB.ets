import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { MockTaskData } from '../http/MockTaskData';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { relationalStore, ValueType } from '@kit.ArkData';
import { Task } from '../model/Task';
import { CommonUtil } from '../utils/CommonUtil';

const TAG = '[TaskDB]';
const TABLE_NAME = 'task';

// 日常任务表
class TaskDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      action_text TTEXT NOT NULL,
      task_type INTEGER,
      target_count INTEGER,
      reward_value INTEGER
    )`,
  };

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema).then(() => {
        // 数据库创建成功之后插入默认数据
        this.initDefaultTasks();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 插入默认数据
  async initDefaultTasks() {
    const valueRows = MockTaskData.DEFAULT_TASKS.map((item) => {
      const escape = (str: ValueType) => String(str).replace(/'/g, `''`);
      const values = [
        item.id,
        `'${escape(item.title)}'`,
        `'${escape(item.description)}'`,
        `'${escape(item.actionText)}'`,
        item.taskType,
        item.targetCount,
        item.rewardValue
      ];
      return `(${values.join(', ')})`;
    }).join(', ');

    const sql = `INSERT OR IGNORE INTO ${TABLE_NAME} (
      id, title, description, action_text, task_type, target_count, reward_value
    ) VALUES ${valueRows}`;

    try {
      await rdbHelper.executeSql(sql);
    } catch (err) {
      Logger.error('TaskDB', `init task failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 查询任务列表（包含当前进度和奖励状态）
  async queryTaskList(userId: number): Promise<Task[]> {
    try {
      // 首先同步跨天状态
      await this.syncTaskProgress(userId);
      const sql = `SELECT t.*,
          IFNULL(ut.current_count, 0) as current_count,
          IFNULL(ut.is_finished, 0) as is_finished,
          IFNULL(ut.is_received, 0) as is_received
        FROM ${TABLE_NAME} t
        LEFT JOIN user_task ut ON t.id = ut.task_id AND ut.user_id = ?
        ORDER BY t.task_type ASC, t.id ASC
      `;

      const resultSet = await rdbHelper.querySql(sql, userId);
      if (!resultSet) {
        return []
      }

      const tasks: Task[] = [];
      while (resultSet.goToNextRow()) {
        const task = Task.fromResultSet(resultSet);
        tasks.push(task);
      }
      resultSet.close();
      return tasks;
    } catch (err) {
      Logger.error('TaskDB', `查询任务列表失败: ${JSON.stringify(err)}`);
      return [];
    }
  }

  // 同步并重置每日任务进度
  async syncTaskProgress(userId: number) {
    const now = Date.now();
    // 1. 查找该用户最近一次更新的任务记录
    const checkSql = `SELECT last_update_time FROM user_task
      WHERE user_id = ?
      ORDER BY last_update_time DESC LIMIT 1
    `;
    const resultSet = await rdbHelper.querySql(checkSql, userId);

    try {
      if (resultSet && resultSet.goToNextRow()) {
        const lastTime = resultSet.getLong(resultSet.getColumnIndex('last_update_time'));
        // 2. 如果最后更新时间不是今天，则查询找到该用户所有的每日任务的ID进行重置
        if (!CommonUtil.isSameDay(lastTime, now)) {
          const resetSql = `UPDATE user_task
            SET current_count = 0, is_finished = 0, is_received = 0, last_update_time = ?
            WHERE user_id = ? AND task_id IN (SELECT id FROM task)
          `;
          await rdbHelper.executeSql(resetSql, [now, userId]);
        }
        resultSet.close();
      }
    } catch (error) {
      Logger.info('TaskDB', `用户 ${userId} 的每日任务更新失败`);
    }
  }

  // 领取任务奖励
  async claimTaskReward(userId: number, task: Task): Promise<number> {
    return rdbHelper.runTransaction(async () => {
      const updateTaskSql = `
        UPDATE user_task
        SET is_received = ?,
            current_count = ?,
            is_finished = ?,
            last_update_time = ?
        WHERE user_id = ? AND task_id = ?
      `;

      const saveTaskSql = `
        INSERT OR REPLACE INTO user_task (
          user_id, task_id, is_received, current_count, is_finished, last_update_time
        ) VALUES (?, ?, ?, ?, ?, ?)
      `;

      let isReceived = 0;
      let isFinished = 0;
      if (task.currentCount === task.targetCount) {
        isReceived = 1;
        isFinished = 1;
      }
      const currentCount = Math.min(task.targetCount, (task.currentCount ?? 0));
      const today = Date.now();

      await rdbHelper.executeSql(saveTaskSql, [
        userId, task.id, isReceived, currentCount, isFinished, today
      ]);
      // 更新用户表的积分字段
      const updatePointsSql = 'UPDATE user SET points = points + ? WHERE user_id = ?';
      await rdbHelper.executeSql(updatePointsSql, [task.rewardValue, userId]);
      Logger.info('TaskDB', `用户 ${userId} 获得积分奖励: ${task.rewardValue}`);
      // 插入积分明细记录
      const bucket: relationalStore.ValuesBucket = {
        'user_id': userId,
        'amount': task.rewardValue,
        'description': task.title,
        'create_time': today
      };
      return await rdbHelper.insert('point_detail', bucket);
    });
  }
}

const taskDB = new TaskDB();

export { taskDB as TaskDB };