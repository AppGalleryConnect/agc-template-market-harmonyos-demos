import { FileUtil, ProgressDialogInfo, ProgressDialogVM } from 'audio_common';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';
import { MusicViewModel } from 'common_view';
import process from '@ohos.process'

const TAG = 'MusicLibraryViewModel'

export class MusicLibraryViewModel extends TaskAbstract {
  workerId: number = -1
  taskStatus: boolean = false //任务状态，true执行中，false未开始
  musicVM: MusicViewModel | undefined = undefined
  excuteFunc: ((item: MusicViewModel) => void) | undefined = undefined //待执行任务函数

  dialogState: ProgressDialogInfo = new ProgressDialogInfo()
  progressDialogVM: ProgressDialogVM | undefined = undefined
  isCancel: boolean = false //取消状态 取消不跳转页面

  onStart(): void {
    if (this.excuteFunc && this.musicVM) {
      this.excuteFunc(this.musicVM)
    } else {
      this.release()
    }

  }

  onComplete(): void {
    this.progressDialogVM?.completeDialog()
    this.release()
  }

  onCancel(): void {
    this.release()
  }

  onMessage(msgRes: MsgRes): void {
  }

  //释放资源
  release() {
    this.taskStatus = false;
    const tempWorkerId = this.workerId;
    if (tempWorkerId === -1) {
      this.workerId = -1;
      return
    }
    WorkersController.teminateWorker(tempWorkerId)
  }

  /*
   * 打开弹窗
   */
  openProgressDialog() {
    this.dialogState.progressTitle = '正在加载中...'
    this.dialogState.fileTime = 60000
    this.dialogState.cancel = () => {
      // 取消任务
      this.cancekTask()
      this.isCancel = true
      this.progressDialogVM?.closeDialog()
    };
    this.progressDialogVM?.openDialog(this.dialogState)
  }
}