import { buildTitleBar, CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function NoticeDetailPageBuilder() {
  NoticeDetailPage();
}

@ComponentV2
struct NoticeDetailPage {
  @Local title: string = ''
  @Local subTitle: string = ''

  aboutToAppear(): void {
    let params = RouterModule.getNavParam<Record<string, string>>(RouterMap.NOTICE_DETAIL_PAGE)
    this.title = params?.title || ''
    this.subTitle = params?.subTitle || ''
  }

  build() {
    NavDestination() {
      Row() {
        Text(this.subTitle)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .margin({ top: 20 })
      .padding({ left: 16, right: 16 })
    }.title(buildTitleBar(this.title), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: CommonConstants.STATUS_BAR_HEIGHT })
  }
}

