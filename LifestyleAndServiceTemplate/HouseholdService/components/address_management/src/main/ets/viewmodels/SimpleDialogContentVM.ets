@ObservedV2
export class SimpleDialogContentVM {
  @Trace
  public message: string = '';
  @Trace
  public confirmButtonText: string = '确定';
  @Trace
  public confirmButtonTextColor: ResourceStr = $r('sys.color.font_emphasize');
  @Trace
  public cancelButtonText: string = '取消';
  @Trace
  public cancelButtonTextColor: ResourceStr = $r('sys.color.font_emphasize');
  @Trace
  public onConfirm: () => void = () => {
  };
  @Trace
  public onWillDismiss: (reason: DismissReason) => void = () => {
  };
}
