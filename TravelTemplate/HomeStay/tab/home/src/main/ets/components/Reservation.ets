import { Constants } from 'constant';
import { Tag } from 'type';
import { HomePageVM } from '../viewmodel/HomePageVM';

@ComponentV2
export struct Reservation {
  vm: HomePageVM = HomePageVM.instance;
  @Param @Require reservation: Tag[];

  build() {
    Column({ space: 8 }) {
      Text(`订房必读`)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start);

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('app.media.reception_audience')).size({ width: 16, height: 16 });
          Text(this.vm.getTags(this.reservation, '接待人群')[0])
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'));
        }

        Row({ space: 8 }) {
          Image($r('app.media.reception_time')).size({ width: 16, height: 16 });
          Row() {
            Text(this.vm.getTags(this.reservation, '入离')[0])
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'));
            Text(this.vm.getTags(this.reservation, '入离')[1])
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'));
          }.layoutWeight(1).justifyContent(FlexAlign.SpaceBetween);
        }

        Row({ space: 8 }) {
          Image($r('app.media.reception_pet')).size({ width: 16, height: 16 });
          Text(this.vm.getTags(this.reservation, '宠物')[0])
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .lineHeight(16);
        }.alignItems(VerticalAlign.Top);

        Row({ space: 8 }) {
          Image($r('app.media.reception_age')).size({ width: 16, height: 16 });
          Text(this.vm.getTags(this.reservation, '年龄限制')[0])
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'));
        }

        Row({ space: 8 }) {
          Image($r('app.media.reception_deposit')).size({ width: 16, height: 16 });
          Text(this.vm.getTags(this.reservation, '押金')[0])
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'));
        }
      }
      .width(Constants.FULL_SCREEN)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding(12)
      .borderRadius(16);
    };
  }
}