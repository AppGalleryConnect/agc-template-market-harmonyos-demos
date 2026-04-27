import { Type } from '@kit.ArkUI';

@ObservedV2
export class Bullet {
  id: string = '';
  @Trace fontSize: number = 160;
  @Trace content: string = '';
  @Trace textColor: string = '#FFFFFF';
  @Trace bgColor: string = '#EE3F4D';
  @Trace isSupportRoll: boolean = true;
  @Trace speed: number = 5;
}

@ObservedV2
export class BulletHistory {
  @Trace text: string = '';
  @Trace createTime: string = '';
}

@ObservedV2
export class GlowStick {
  @Trace speed: number = 5;
  @Trace glowColors: string[] = [];
}

@ObservedV2
export class SliderOption {
  @Trace min: number = 0;
  @Trace max: number = 0;
  @Trace step: number = 1;
  @Trace current: number = 6;
  @Trace confirmCallBack: () => void = () => {
  };
  @Trace closeCallBack: () => void = () => {
  };
}

@ObservedV2
export class ColorOption {
  @Trace color: string = '';
  @Trace confirmCallBack: () => void = () => {
  };
  @Trace closeCallBack: () => void = () => {
  };
}

@ObservedV2
export class Hint {
  @Trace message: string = '';
  @Trace confirmCallBack: () => void = () => {
  };
}

@ObservedV2
export class BulletHistoryList {
  @Type(BulletHistory)
  @Trace list: BulletHistory[] = [];
}