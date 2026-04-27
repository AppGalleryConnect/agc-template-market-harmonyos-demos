@ObservedV2
export class BackupSetUpVM {
  logTag: string = 'BackupSetUp';
  @Trace isAutoBackup: boolean = false
  @Trace traffic: boolean = true
  @Trace toggleFocus: boolean = false
  // 弹框id，用于关闭
  dialogId: number = 0;
}