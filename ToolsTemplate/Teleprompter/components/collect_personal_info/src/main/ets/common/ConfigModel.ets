// 配置模型
@ObservedV2
export class ConfigInfo {
  @Trace themeColor: string | Resource = $r('sys.color.comp_background_emphasize');
  @Trace sheetType: SheetType = SheetType.BOTTOM;
}