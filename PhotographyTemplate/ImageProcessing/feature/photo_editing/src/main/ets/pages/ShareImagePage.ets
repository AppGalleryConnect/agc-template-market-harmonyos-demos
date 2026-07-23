import { ShareContentType, SharePicker } from 'aggregated_share';
import { BaseTitle, CommonConstants, RouterMap, RouterModule } from 'commonlib';

@Builder
export function ShareImagePageBuilder() {
  ShareImagePage();
}


@ComponentV2
export struct ShareImagePage {
  @Local imageUrl: string = '';
  @Local imageRatio: number = 0.61;

  aboutToAppear(): void {
    let params = RouterModule.getNavParam({ url: RouterMap.SHARE_IMAGE_PAGE }) as Record<string, string | number>;
    if (params) {
      this.imageUrl = params.url as string ?? '';
      this.imageRatio = params.imageRatio as number ?? 0.61
    }
  }

  share() {
    if (!this.imageUrl) {
      return;
    }
    const picker: SharePicker = new SharePicker({
      title: '分享图片',
      subTitle: '来自已加载的沙箱图片',
      shareType: ShareContentType.IMAGE,
      imageUrl: this.imageUrl,
    });

    picker.show(this.getUIContext(), {
      autoClose: true,
    });
  }

  build() {
    NavDestination() {
      // 头部
      this.sharePageHeader()

      // 内容
      Column() {
        Text('图片已保存至相册')
          .fontSize(16).fontWeight(700)
          .lineHeight(21)
          .margin({ top: 44 })

        Column() {
          Image(this.imageUrl)
            .objectFit(ImageFit.Contain)
            .aspectRatio(this.imageRatio)
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .margin({ top: 16 })

        Button('完成')
          .width(120)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(500)
          .fontColor($r('sys.color.font_emphasize'))
          .margin({ top: 44 })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick((event: ClickEvent) => {
            RouterModule.pop();
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 16,
      right: 16
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  sharePageHeader() {
    BaseTitle({
      title: '图片美化',
      showBackBtn: true,
      titleFontSize: $r('sys.float.Title_S'),
      rightPartBuilder: () => {
        this.headerRightBuilder()
      },
    });
  }

  @Builder
  headerRightBuilder() {
    Button() {
      SymbolGlyph($r('sys.symbol.share'))
        .fontColor([$r('sys.color.font_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.share()
    })
  }
}