import { Logger } from './Logger';
import { PopViewUtil } from './PopViewUtil';

class LoadingParam {
  message: string;

  constructor(message: string) {
    this.message = message;
  }
}

@Builder
function loadingBuilder(param: LoadingParam) {
  Column() {
    Column() {
      LoadingProgress()
        .width($r('app.integer.icon_size_32'))
        .color($r('sys.color.icon_on_primary'))
        .margin({ bottom: $r('app.string.margin_xs') });
      Text(param.message)
        .fontColor($r('app.color.font_color_level1_invert'))
        .fontSize($r('app.string.font_size_12'));
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(100)
    .height(100)
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor($r('app.color.font_color_level2'));
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor(Color.Transparent)
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
}

const TAG: string = '[FullLoading]';

export class FullLoading {
  public static show(message: string = '') {
    const builder = wrapBuilder(loadingBuilder);
    PopViewUtil.openDialog<LoadingParam>(
      builder,
      {
        autoCancel: false,
        onWillDismiss: () => {
          return false;
        },
      },
      new LoadingParam(message));
  }

  public static hide() {
    try {
      PopViewUtil.closeDialog();
    } catch (err) {
      Logger.info(TAG, 'loading dialog has been closed');
    }

  }
}



