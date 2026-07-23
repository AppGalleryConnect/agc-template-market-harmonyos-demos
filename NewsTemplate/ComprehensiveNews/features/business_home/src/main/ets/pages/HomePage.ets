import {
  CircleButtonModifier,
  CommonConstants,
  LinearColumnModifier,
  RouterMap,
  RouterUtils,
} from 'lib_common'
import { FlexLayout } from 'lib_flex_layout';
import { NewsSearchEntry } from 'lib_search';
import { NavHeaderBar } from 'lib_widget';
import { FloatingPublishBtn } from '../components/FloatingPublishBtn';
import { NewsScan } from '../utils/NewsScan';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  aboutToAppear(): void {
    this.homeViewModel.sendPushNotice(this.homeViewModel.contextModel.globalUIAbilityContext);
    this.homeViewModel.preloadENewsImages();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '首页',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          },
        })
        Column() {
          FlexLayout()
        }
        .layoutWeight(1)

        this.publishNewsBtn()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'))
      .attributeModifier(this.modifier)
    }
    .hideTitleBar(true)
  }

  @Builder
  publishNewsBtn() {
    FloatingPublishBtn()
  }

  @Builder
  rightHeadPartBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      NewsSearchEntry({ name: 'home' })

      Button() {
        SymbolGlyph($r('sys.symbol.line_viewfinder'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('扫码')
      .onClick(() => {
        new NewsScan().scan()
      })

      Button() {
        SymbolGlyph($r('sys.symbol.doc_text'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('数字报纸')
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.DIGITAL_NEWSPAPER, this.homeViewModel.eNewsMap);
      })

    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}