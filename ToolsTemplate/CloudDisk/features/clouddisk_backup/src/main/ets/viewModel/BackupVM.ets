import { TimeUtil } from 'common';

@ObservedV2
export class BackupVM {
  logTag: string = 'Backup';
  //  一键开启备份
  @Trace turnActivation: boolean = false
  // 备份进度
  @Trace backupProgress: number = 0
  @Trace timer: number = 0;
  // 备份状态
  @Trace backupStatus: BackupStatus = BackupStatus.Pause
  // 最近备份日期
  @Trace backupDate: string = this.getCurrentDate()
  // 最近备份时间
  @Trace backupDateTime: string = this.getCurrentDateTime()
  // 弹框id，用于关闭
  dialogId: number = 0;

  beginProgress() {
    this.timer = setInterval(() => {
      this.backupProgress++
      if (this.backupProgress === 100) {
        this.backupStatus = BackupStatus.Complete
        clearInterval(this.timer)
        return
      }
    }, 100)
  }

  pauseProgress() {
    clearInterval(this.timer)
  }

  getCurrentDateTime(): string {
    return TimeUtil.getCurDate('yyyy-MM-dd HH:mm')
  }

  getCurrentDate(): string {
    return TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)
  }
}

export enum BackupStatus {
  Pause = 0,
  Start = 1,
  Complete = 2
}