import { Article } from './clazz/Article';
import {
  CommonConstants
} from '@ohos_agcit/common_component';

@ComponentV2
export struct Introductions {
  @Local isListReachEnd: boolean = false;
  @Local articleList: Array<Article> = [
    new Article('001', $r('app.string.information_title1_hobbies'), $r('app.string.information_content1_hobbies'),
      $r('app.media.dragonBoatFestival')),
    new Article('002', $r('app.string.information_title2_hobbies'), $r('app.string.information_content2_hobbies'),
      $r('app.media.dragonBoatFestival')),
    new Article('003', $r('app.string.information_title3_hobbies'), $r('app.string.information_content3_hobbies'),
      $r('app.media.dragonBoatFestival')),
  ]

  build() {
    Column() {
      ForEach(this.articleList, (item: Article) => {
        ArticleCard({ article: item })
          .margin({ bottom: 12 })
      }, (item: Article) => item.id)
    }
    .width('100%')
  }
}

@Component
struct ArticleCard {
  @Prop article: Article;

  build() {
    Column() {
      Text(this.article.title)
        .fontSize($r('app.float.font_size_18'))
        .fontColor(Color.Black)
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })
      Text(this.article.content)
        .fontSize($r('app.float.font_size_14'))
        .fontColor(Color.Gray)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })
      Row() {
        List({ space: 10 }) {
          ListItem() {
            Image(this.article.photo)
              .height(200)
              .width('80%')
              .align(Alignment.Center)
              .borderRadius(16)
          }
          ListItem() {
            Image(this.article.photo)
              .height(200)
              .width('80%')
              .align(Alignment.Center)
              .borderRadius(16)
          }
        }  .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)


      }
    }
    .borderRadius(16)
    .backgroundColor(Color.White)
    .width('100%')
    .padding('5%')
    .alignItems(HorizontalAlign.Center)
  }
}

