import { common, ConfigurationConstant } from '@kit.AbilityKit';

/**
 * 主题控制器
 */
@ObservedV2
export class ThemeController {
  private static _instance: ThemeController;

  public static get instance() {
    if (!ThemeController._instance) {
      ThemeController._instance = new ThemeController();
    }
    return ThemeController._instance;
  }

  /**
   * 当前模式
   */
  @Trace currentColorMode: ConfigurationConstant.ColorMode | undefined = undefined;
  /**
   * 是否跟随系统
   */
  @Trace isFollowSystemSetting: boolean = true;
  /**
   * 是否开启夜间模式
   */
  @Trace enableDarkMode: boolean = false;

  @Trace dialogBgWhite: Resource = $r('sys.color.comp_background_list_card');

  @Monitor('currentColorMode')
  onModeChange() {
    if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      this.dialogBgWhite = $r('sys.color.ohos_id_blur_style_component_ultra_thick_color_dark');
    } else {
      this.dialogBgWhite = $r('sys.color.comp_background_list_card')
    }
  }
}

const setColorMode = (context: common.UIAbilityContext, colorMode: ConfigurationConstant.ColorMode) => {
  context.getApplicationContext().setColorMode(colorMode);
}

export const setAutoColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
}

export const setDarkColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
}

export const setLightColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
}