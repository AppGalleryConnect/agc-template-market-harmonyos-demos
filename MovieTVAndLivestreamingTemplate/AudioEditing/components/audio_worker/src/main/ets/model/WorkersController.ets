import { ACTION } from './MsgModel';
import { TaskAbstract } from './TaskAbstract';
import { WorkerModel } from './WorkerModel';


const MAX_WORKER_NUM = 1
const TAG = 'WorkersController'

export class WorkersController {
  static workerMap: Map<number, WorkerModel> = new Map()

  static createWorker(taskModel: TaskAbstract) {
    let workerId = -1
    if (WorkersController.workerMap.size > MAX_WORKER_NUM - 1) {
      workerId = -1
    } else {
      workerId = WorkersController.getRestId()
    }
    if (workerId < 0) {
      return workerId
    }
    const workerModel = new WorkerModel()
    workerModel.setId(workerId)
    workerModel.registerObject(taskModel)
    WorkersController.workerMap.set(workerModel.id, workerModel)
    return workerModel.id
  }

  //获取map没使用的key
  static getRestId() {
    let restId = -1;
    for (let id = 0; id < MAX_WORKER_NUM; id++) {
      if (!WorkersController.workerMap.get(id)) {
        restId = id;
        break
      }
    }
    return restId;
  }

  //判断worker线程是否存在
  static hasWorker(workerId: number){
    return WorkersController.workerMap.has(workerId)
  }

  //获取worker实例
  private static getWorker(workerId: number) {
    return WorkersController.workerMap.get(workerId)
  }

  //启动任务
  static startTask(workerId: number) {
    WorkersController.getWorker(workerId)?.postMessage(ACTION.START)
  }

  /*
   * 通知worker线程任务结束-线程会自动执行下一步任务（调用onComplete/onCancel方法）
   * wokerId: 线程Id
   */
  static noticeWorkerTaskEnd(workerId: number){
    WorkersController.getWorker(workerId)?.postMessage(ACTION.END);
  }


  //销毁线程
  static teminateWorker(workerId: number) {
    WorkersController.workerMap.get(workerId)?.terminateWorker()
    WorkersController.workerMap.delete(workerId)
  }

}