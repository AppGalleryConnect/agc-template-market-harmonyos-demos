import { ConfigurationConstant } from '@kit.AbilityKit';
import { ISelectOption } from '../types/SettingItem';

export const lightDarkOptions: ISelectOption[] = [
  {
    id: 0,
    label: '跟随系统',
    value: ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET,
  },
  {
    id: 1,
    label: '浅色模式',
    value: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT,
  },
  {
    id: 2,
    label: '深色模式',
    value: ConfigurationConstant.ColorMode.COLOR_MODE_DARK,
  },
];
