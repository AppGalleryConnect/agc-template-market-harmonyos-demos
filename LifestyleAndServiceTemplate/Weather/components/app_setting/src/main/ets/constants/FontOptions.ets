import { ISelectOption } from '../types/SettingItem';

/**
 * 字体大小调节档位
 */
export enum FontSizeEnum {
  SMALL = 0.85,
  NORMAL = 1,
  LARGE = 1.15,
  XL = 2,
}

export const FONT_SIZE_LIST: ISelectOption[] = [
  {
    id: 0,
    value: FontSizeEnum.NORMAL,
    label: '标准',
  },
  {
    id: 1,
    value: FontSizeEnum.LARGE,
    label: '大',
  },
];