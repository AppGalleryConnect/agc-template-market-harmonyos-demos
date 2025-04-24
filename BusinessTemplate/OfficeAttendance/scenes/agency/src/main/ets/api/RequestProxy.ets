import { TaskItem } from '../types/Types';
import { BaseResponse, https } from '@ohos_agcit/office_attendance_network';
import { DataManager } from '../mock/DataManager';

export class RequestProxy {
  static queryTasks(name: string, isFinished: boolean): Promise<TaskItem[]> {
    return Promise.resolve(DataManager.queryTasks(name, isFinished));
  }

  static queryTaskByID(id: string): Promise<TaskItem | undefined> {
    return Promise.resolve(DataManager.queryById(id));
  }

  static querySubTasks(id: string): Promise<TaskItem[]> {
    return Promise.resolve(DataManager.querySubTasks(id));
  }

  static addTask(item: TaskItem): Promise<BaseResponse<undefined>> {
    DataManager.saveTodo(item);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static editTask(item: TaskItem): Promise<BaseResponse<undefined>> {
    DataManager.saveTodo(item);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static deleteTask(taskID: string): Promise<BaseResponse<undefined>> {
    DataManager.deleteById(taskID);
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }
}