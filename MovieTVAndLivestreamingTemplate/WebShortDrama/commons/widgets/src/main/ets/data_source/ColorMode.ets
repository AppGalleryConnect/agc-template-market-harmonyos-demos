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

  static getColorModeByName(modeName: string): ConfigurationConstant.ColorMode {
    const modeMap: Record<string, ConfigurationConstant.ColorMode> = {
      '跟随系统': ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET,
      '深色模式': ConfigurationConstant.ColorMode.COLOR_MODE_DARK,
      '浅色模式': ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    }
    return modeMap[modeName] ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  }
}