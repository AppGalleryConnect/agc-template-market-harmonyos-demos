@ObservedV2
export class ProgressDialogInfo {
  @Trace progressTitle: string = ''; //弹框标题
  @Trace fileTime?: number = 0; //多个文件或单个文件总时长（毫秒） 不传默认1分钟时长
  @Trace completeValue: number = 0; //进度
  @Trace logoFilePath: string = ''; //导出日志全路径
  cancel: () => void = () => { //取消按钮回调
  }
}