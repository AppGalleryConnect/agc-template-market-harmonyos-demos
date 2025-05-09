import { MainEntryVM, newsInformation, newsInformationInterface } from 'commonlib'
import { BaseTitle } from 'componentlib';
import { newsComponent } from '../components/newsComponent'
import { BACKGROUND_COLOR_GRAY } from '../constants/HomeViewConstants';

@Builder
export function moreNewsPageBuilder(name: string, param: Object) {
  moreNewsPage()
}

@Component
export struct moreNewsPage {
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  MoreNewsBuilder() {
    Text('新闻公告')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.MoreNewsBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Scroll() {
        Column({ space: 12}) {
          Text('全部')
            .fontSize(14)
            .fontWeight('medium')
          List({ space: 25 }) {
            ForEach(newsInformation, (item: newsInformationInterface, index: number) => {
              newsComponent(item, this.vm)
            }, (item: string, index: number) => item + index)
          }
          .divider({
            strokeWidth: 1,
            startMargin: 104,
            endMargin: 0,
            color: $r('app.color.divider')
          })
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .borderRadius(16)
        .backgroundColor($r('app.color.background_color_white'))
        .padding({
          top: 12,
          left: 12,
          right: 16,
          bottom: 12
        })
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .padding({ right: 16, left: 16, top: 8 })
    }
    .hideTitleBar(true)
    .backgroundColor(BACKGROUND_COLOR_GRAY)
  }
}