import { Article } from './clazz/Article';
import { webview } from '@kit.ArkWeb';

@ComponentV2
export struct AboutUs {
  @Local isListReachEnd: boolean = false;
  @Local simpleList: Array<Resource> =
    [$r('app.string.information_title1_string'), $r('app.string.information_title2_string'),
      $r('app.string.information_title3_string')];
  @Local articleList: Array<Article> = [
    new Article('001', $r('app.string.information_title1_string'), $r('app.string.information_content1_string'),
      $r('app.media.swiperImage')),
    new Article('002', $r('app.string.information_title2_string'), $r('app.string.information_content2_string'),
      $r('app.media.swiperImage')),
    new Article('003', $r('app.string.information_title3_string'), $r('app.string.information_content3_string'),
      $r('app.media.swiperImage'))
  ]

  build() {
    Column() {
      ForEach(this.articleList, (item: Article) => {
        ArticleCard({ article: item })
          .margin({ bottom: 16 })
      }, (item: Article) => item.id)
    }
    .width('100%')
  }
}

@Component
struct ArticleCard {
  @Prop article: Article;
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Text(this.article.title)
        .fontSize($r('app.float.font_size_16'))
        .fontColor(Color.Black)
        .margin({ bottom: 8 })
      Text(this.article.content)
        .fontSize($r('app.float.font_size_14'))
        .fontColor(Color.Gray)
    }
    .alignItems(HorizontalAlign.Start)
    .padding('5%')
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)

  }
}

