import { PopViewUtils } from './PopViewUtils';

export class LoadingUtil {
  /**
   * 打开loading
   * @param param
   */
  static showLoading() {
    PopViewUtils.showPopView<FullLoadingParam>(wrapBuilder(fullLoading),
      new FullLoadingParam(),
      { alignment: DialogAlignment.Center, autoCancel: false });
  };

  /**
   * 关闭loading弹窗
   */
  static hideLoading() {
    PopViewUtils.closePopView();
  }
}

export class FullLoadingParam {
  label?: string;
}

@Builder
export function fullLoading(param: FullLoadingParam) {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      LoadingProgress().width(32).height(32).color($r('sys.color.icon_on_primary'))
    }
    .justifyContent(FlexAlign.Center)
    .width(100)
    .height(100)
    .backgroundColor('#88000000')
    .borderRadius(8)
  }
  .width('100%')
  .height('100%')
  .backgroundColor(Color.Transparent)
}