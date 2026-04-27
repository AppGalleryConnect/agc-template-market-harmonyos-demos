import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, CommonTitle, RouterMap, RouterModule, WindowInfo } from 'lib_foundation';
import { privacy } from '../constants';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
struct PrivacyPage {
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local title: string = '';
  @Local text: string = privacy;

  aboutToAppear(): void {
    this.init();
  }

  init() {
    const param = RouterModule.getNavParam<string>({
      url: RouterMap.PRIVACY_PAGE,
    });
    if (param) {
      this.title = param
    }
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '协议',
      })
      Column() {
        Text(this.text)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .padding({
        top: 8,
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
        bottom: this.windowModel.windowBottomPadding,
      })
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}