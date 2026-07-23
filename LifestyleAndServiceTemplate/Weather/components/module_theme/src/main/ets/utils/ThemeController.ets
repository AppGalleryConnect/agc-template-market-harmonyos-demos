import { PersistenceV2 } from '@kit.ArkUI';
import { THEME_LIST } from '../constants/Constants';
import { CommonUtil } from './CommonUtil';

@ObservedV2
export class ThemeModel {
  @Trace id: number = 1;
}

@ObservedV2
export class ThemeController {
  private static _theme: ThemeModel = PersistenceV2.connect(ThemeModel, 'theme', () => new ThemeModel())!;

  @Computed
  public static get themePic() {
    const theme = THEME_LIST.find(theme => theme.id === ThemeController._theme.id);
    return $r(`app.media.${theme?.pics[CommonUtil.getTimeIntervalIndex() % theme.pics.length]}`);
  }

  @Computed
  public static get themeColor() {
    const theme = THEME_LIST.find(theme => theme.id === ThemeController._theme.id);
    return theme?.colors[CommonUtil.getTimeIntervalIndex() % theme.pics.length];
  }

  @Computed
  public static get themePics() {
    const theme = THEME_LIST.find(theme => theme.id === ThemeController._theme.id) ?? THEME_LIST[0];
    return theme.pics.map(s => $r(`app.media.${s.concat('_home')}`));
  }

  @Computed
  public static get themeLabel() {
    const theme = THEME_LIST.find(theme => theme.id === ThemeController._theme.id) ?? THEME_LIST[0];
    return theme.label;
  }

  public static getThemeId() {
    return ThemeController._theme.id;
  }

  public static getThemeById(id: number) {
    const theme = THEME_LIST.find(theme => theme.id === id) ?? THEME_LIST[0];
    return theme;
  }

  public static getThemePicsById(id: number) {
    const theme = THEME_LIST.find(theme => theme.id === id) ?? THEME_LIST[0];
    return theme.pics.map(s => $r(`app.media.${s.concat('_home')}`));
  }

  public static change(id: number) {
    ThemeController._theme.id = id;
  }
}

