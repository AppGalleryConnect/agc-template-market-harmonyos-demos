import { MsgRes } from './MsgModel';

export abstract class TaskAbstract {
  nextAction: 'onComplete' | 'onCancel' = 'onComplete'  //任务结束后执行的回调函数
  //任务启动回调
  abstract onStart(): void ;

  /*
   * 任务取消回调，
   * 任务结束后会自动执行，前提是先workersController的setNextAtion(),并告诉worker线程任务结束了，
   * */
  abstract onCancel(): void

  /*
   * 任务完成回调，
   * 前提是告诉worker线程任务结束了
   * */
  abstract onComplete(): void ;

  //消息回调
  abstract onMessage(msgRes: MsgRes): void ;

  //获取任务结束后执行函数
  getNextAction(){
    return this.nextAction
  }

  //取消任务
  cancekTask(){
    this.nextAction = 'onCancel';
  }

  resetTask(){
    this.nextAction = 'onComplete'
  }
}