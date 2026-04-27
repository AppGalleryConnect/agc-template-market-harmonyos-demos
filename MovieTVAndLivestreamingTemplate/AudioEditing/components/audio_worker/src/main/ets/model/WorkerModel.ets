import { MessageEvents, worker } from '@kit.ArkTS';
import { ACTION, MsgBody, MsgRes } from './MsgModel';
import { TaskAbstract } from './TaskAbstract';

const TAG = 'WorkerModel'

export class WorkerModel {
  workerInstance: worker.ThreadWorker
  id: number = 0
  private taskModel?: TaskAbstract
  messageHandle = (res: string) => {
  }

  constructor() {
    this.workerInstance = new worker.ThreadWorker('../workers/Worker');
    this.initMessage()
  }

  bindMessageHandle(messageHandle: (res: string) => void) {
    this.messageHandle = messageHandle
  }

  setId(id: number) {
    this.id = id
  }

  initMessage() {
    this.workerInstance.onmessage = (e: MessageEvents) => {
      let data = e.data as MsgRes
      this.taskModel?.onMessage(data)
      this.messageHandle(data?.data || '')
    }


    // 注册onmessageerror回调，当Worker对象接收到无法序列化的消息时被调用，在宿主线程执行
    this.workerInstance.onmessageerror = () => {
    }


    // 注册onexit回调，当Worker销毁时被调用，在宿主线程执行
    this.workerInstance.onexit = (e: number) => {
      // Worker正常退出时，code为0；异常退出时，code为1
      if (e !== 0) {
      }

    }

  }

  postMessage(action: ACTION) {
    // 发送消息给Worker线程
    const msgBody: MsgBody = {
      action: action,
      workerId: this.id
    }
    this.workerInstance?.postMessage(msgBody);
  }

  registerObject(taskModel: TaskAbstract) {
    this.taskModel = taskModel
    this.workerInstance.registerGlobalCallObject(this.id.toString(), taskModel);
  }

  terminateWorker() {
    this.taskModel = undefined
    this.id = -1
    this.workerInstance.unregisterGlobalCallObject()
    this.workerInstance.terminate()
  }
}