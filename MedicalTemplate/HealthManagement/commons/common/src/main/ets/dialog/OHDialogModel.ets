// 定义弹窗入参基本参数接口
@ObservedV2
export class OHDialogModel {
  @Trace title?: ResourceStr; // 标题
  @Trace changeValue: string | string[] = '';
  @Trace changeIndex: number | number[] = 0;
  @Trace selected: Date = new Date();
  // todo xxxx是您的应用名称
  @Trace subtitle: ResourceStr = '此操作会永久删除您在“xxxx”云端的所有个人信息、运动数据和健康数据。\n' +
    '是否清理缓存，共';
  @Trace cacheSize: string = '';
  childBuilder?: (model: OHDialogModel) => void; // 弹框内容：自定义view
  onValueConfirmClick?: (dialogModel: OHDialogModel) => void; // 确认回调
}