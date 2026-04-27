import { PopViewUtils } from '../utils/PopViewUtil';

export interface loadingParam {
  loadingSize?: Length;
  text?: ResourceStr;
}

@Builder
function loadingBuilder(param?: loadingParam) {
  ToastLoadingView({
    loadingSize: param?.loadingSize,
    text: param?.text
  })
}

@ComponentV2
struct ToastLoadingView {
  @Param loadingSize: Length = 40;
  @Param text: ResourceStr = ''

  build() {
    Column({ space: 4 }) {
      LoadingProgress()
        .width(this.loadingSize ?? 40)
        .height(this.loadingSize ?? 40)
        .color($r('sys.color.icon_on_primary'))

      Text(this.text).fontSize(12).fontColor($r('sys.color.font_on_primary'))
    }
    .width(100)
    .height(100)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.mask_secondary'))
  }
}

export class ToastLoading {
  static open(param?: loadingParam): void {
    const data = param ?? {} as loadingParam;
    PopViewUtils.showPopView(wrapBuilder(loadingBuilder), data,
      {
        alignment: DialogAlignment.Center,
        autoCancel: false,
        maskColor: Color.Transparent,
      },
    )
  }

  static close(): void {
    PopViewUtils.closePopView();
  }
}