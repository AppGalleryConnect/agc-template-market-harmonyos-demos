import { Type } from '@kit.ArkUI';

@ObservedV2
export class ThemeState {
  @Trace current: string = '#c4272b';
  @Trace color: string = '#ffffff';
  @Trace name: string = '赤色';
  @Trace id: string = 'red';
  @Trace barColor: string = '#c4272b';
  @Trace titleColor: string = '#ffffff';
  @Trace buttonColor: string = '#c4272b';
  @Trace tabColor: string = '#ffffff';
  @Trace tabColorInActive: string = '#ffffff';
}

@ObservedV2
export class ThemeModel {
  @Type(ThemeState)
  @Trace themeState: ThemeState = new ThemeState()
}

