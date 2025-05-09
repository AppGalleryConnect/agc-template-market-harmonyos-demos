import { NavPathName } from 'constant';
import { TravelNote } from 'type';

@Builder
export function ContentCardBuilder() {
  ContentCard();
}

@Component
export struct ContentCard {
  @Prop data: TravelNote;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    Column({ space: 10 }) {
      Image(this.data.banner)
        .width('100%')
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.High)
        .borderRadius({ topLeft: 8, topRight: 8 })
        .autoResize(true)
        .syncLoad(true);

      Column({ space: 8 }) {
        Row() {
          Text(this.data.title)
            .fontSize(12)
            .fontColor('#111111')
            .fontWeight(500)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%');
          Blank();
        };

        Row({ space: 4 }) {
          Image($r('app.media.avatar_login')).width(18).height(18).autoResize(true).syncLoad(true);
          Text('吃葡萄不吐葡萄皮')
            .fontSize(10)
            .fontColor('#999999')
            .fontWeight(400)
            .lineHeight(16)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 2, right: 10 })
            .layoutWeight(1);
          Blank();
        }.width('100%');
      }
      .width('100%')
      .padding({
        left: 10,
        right: 20,
        top: 6,
        bottom: 6,
      });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      this.mainPathStack.pushPathByName(NavPathName.PAGE_DETAIL, this.data);
    });
  }
}