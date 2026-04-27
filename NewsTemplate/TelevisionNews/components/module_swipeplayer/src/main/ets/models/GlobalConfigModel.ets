@ObservedV2
export class GlobalConfigModel {
  @Trace themeColor: string | Resource = $r('sys.color.brand');
}