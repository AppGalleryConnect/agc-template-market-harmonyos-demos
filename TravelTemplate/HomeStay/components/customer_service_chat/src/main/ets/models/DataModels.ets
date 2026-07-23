import { common } from '@kit.AbilityKit';

export interface AvatarParam {
  avatarSize?: number;
  avatarRadius?: Length;
  avatarMargin?: number;
}

export interface FeatureSwitch {
  showCamera?: boolean
  showPicture?: boolean
  showLocation?: boolean
}


export interface FeatureItemConfig {
  icon: Resource,
  label: ResourceStr,
  isSymbolGraph: boolean,
  onClick: (context?: common.UIAbilityContext) => void, // 点击事件
}


@ObservedV2
export class AvatarInfo {
  @Trace avatar: ResourceStr = $r('app.media.avatar_grey');
  @Trace name: ResourceStr = '';
}
