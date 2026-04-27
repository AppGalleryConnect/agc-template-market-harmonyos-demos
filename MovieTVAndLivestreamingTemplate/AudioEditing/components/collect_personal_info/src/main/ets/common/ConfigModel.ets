// 配置模型
@ObservedV2
export class ConfigInfo {
  @Trace themeColor: string | Resource = $r('sys.color.brand');
  @Trace sheetType: SheetType = SheetType.BOTTOM;
}