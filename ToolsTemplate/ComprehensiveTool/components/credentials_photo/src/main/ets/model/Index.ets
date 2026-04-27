import { image } from '@kit.ImageKit';

export interface PhotoSize {
  width: number,
  height: number
}


export interface PhotoTypeItem {
  label: string,
  size: PhotoSize
}


export interface PickerItem {
  icon: ResourceStr,
  text: string
}


//  照片容器控制器
export class PhotoContainerController {
  snip = () => {

  };
}


//  颜色选择项
export interface ColorItem {
  label: string,
  color: ResourceColor,
  icon: ResourceStr
}


//  服装选择项
export interface DressItem {
  id: string
  icon: ResourceStr,
  dress: ResourceStr
}


export interface SettingItem {
  icon: ResourceStr,
  text: string,
  checked: ResourceStr
}


// 编辑参数
export interface EditParms extends PhotoTypeItem {
  img: image.PixelMap;
}