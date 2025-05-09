import { Constants } from 'constant';
import { Tag } from 'type';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Component
export struct Foundations {
  vm: HomePageVM = HomePageVM.instance;
  @Prop foundations: Array<Tag>;

  build() {
    Column({ space: 16 }) {
      Text(`设施服务`).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start);

      Column({ space: 16 }) {
        if (this.foundations) {
          Row() {
            Column() {
              Text('基础').fontSize(12).opacity(0.6);
            }.alignItems(HorizontalAlign.Start).width(32);

            Column() {
              Grid() {
                ForEach(this.vm.getTags(this.foundations, '基础'),
                  (item: string) => {
                    GridItem() {
                      Row() {
                        Image($r('app.media.icon_configuration')).size({ width: 12, height: 12 });
                        Text(`${item}`)
                          .fontSize(12)
                          .width(72)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .fontColor('#333333')
                          .margin({ left: 4 });
                      }.justifyContent(FlexAlign.Start).width(Constants.FULL_SCREEN);
                    };
                  }, (item: string) => item);
              }.columnsTemplate('1fr 1fr 1fr')
              .rowsGap(16);
            }.margin({ left: 16 });
          }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Start);
        }

        Row() {
          Column() {
            Text('前台').fontSize(12).opacity(0.6);
          }.alignItems(HorizontalAlign.Start).width(32);

          Column() {
            Grid() {
              ForEach(this.vm.getTags(this.foundations, '前台'),
                (item: string) => {
                  GridItem() {
                    Row() {
                      Image($r('app.media.icon_configuration')).size({ width: 12, height: 12 });
                      Text(`${item}`)
                        .fontSize(12)
                        .width(64)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontColor('#333333')
                        .margin({ left: 4 });
                    }.justifyContent(FlexAlign.Start).width(Constants.FULL_SCREEN);
                  };
                }, (item: string) => item);
            }.columnsTemplate('1fr 1fr 1fr')
            .rowsGap(16);
          }.margin({ left: 16 });
        }.justifyContent(FlexAlign.Start);
      };
    };
  }
}