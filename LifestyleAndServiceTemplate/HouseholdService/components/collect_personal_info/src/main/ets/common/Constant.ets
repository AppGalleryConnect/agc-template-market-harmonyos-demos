import { GenderOption, GenderType } from './DataModel';

// 通用常量
export class Constants {
  // Space
  static readonly SPACE_XS: number = 4;
  static readonly SPACE_S: number = 8;
  static readonly SPACE_M: number = 12;
  static readonly SPACE_L: number = 16;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  // Padding
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_XL: number = 20;
  static readonly PADDING_2XL: number = 24;
  static readonly PADDING_3XL: number = 28;
  static readonly PADDING_4XL: number = 32;
  static readonly PADDING_5XL: number = 36;
  static readonly PADDING_6XL: number = 40;
  static readonly PADDING_7XL: number = 44;
}

// 性别
export const GENDER_OPTIONS: GenderOption[] = [
  {
    id: 0,
    value: GenderType.MALE,
    label: '男',
  },
  {
    id: 1,
    value: GenderType.FEMALE,
    label: '女',
  },
  {
    id: 2,
    value: GenderType.CONFIDENTIALITY,
    label: '保密',
  },
];
