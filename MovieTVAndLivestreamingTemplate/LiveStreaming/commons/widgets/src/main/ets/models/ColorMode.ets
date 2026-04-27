/*
 * 记录深、浅色模式数据
 */
import { ConfigurationConstant } from '@kit.AbilityKit'

@ObservedV2
export class ColorMode {
  @Trace modeName: string
  @Trace colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET

  constructor(mode: string) {
    this.modeName = mode
  }
}