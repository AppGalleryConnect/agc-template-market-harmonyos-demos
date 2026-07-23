/**
 * 通用常量
 */
export class Constants {
  static readonly SPACE_XXS: number = 4;
  static readonly SPACE_XS: number = 6;
  static readonly SPACE_S: number = 8;
  static readonly SPACE_M: number = 12;
  static readonly FULL_PERCENT: string = '100%';
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly SOURCE: string = 'FormCard';
  static readonly PICTURE_BEAUTIFICATION = 'PictureBeautification'; // 图片美化页
  static readonly COLLAGE_PAGE = 'CollagePage'; // 图片拼图页
  static readonly LUT_CAMERA_PAGE = 'LutCameraPage'; // 滤镜相机
}

export interface BtnItemInfo {
  label: ResourceStr
  icon: ResourceStr
  bgColor: ResourceColor
  clickAction: () => void
}