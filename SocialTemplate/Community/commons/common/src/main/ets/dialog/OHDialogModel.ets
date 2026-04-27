// 定义弹窗入参基本参数接口
@ObservedV2
export class OHDialogModel {
  @Trace title?: ResourceStr; // 标题
  @Trace childPadding: Resource = $r('app.float.vp_16'); // 自定义view组件左右边距
  @Trace cancelTitle: ResourceStr = '取消';
  @Trace confirmTitle: ResourceStr = '确认';
  @Trace cancelFontColor: ResourceColor = $r('sys.color.font_tertiary');
  @Trace confirmFontColor: ResourceColor = $r('sys.color.font_emphasize');
  childBuilder?: (model: Object) => void; // 弹框内容：自定义view
  onValueCancelClick?: (dialogModel: Object) => void; // 取消回调
  onValueConfirmClick?: (dialogModel: Object) => void; // 确认回调
}