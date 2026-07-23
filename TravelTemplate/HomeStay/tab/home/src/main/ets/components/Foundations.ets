import { Constants } from 'constant';
import { Tag } from 'type';
import { HomePageVM } from '../viewmodel/HomePageVM';

@ComponentV2
export struct Foundations {
  vm: HomePageVM = HomePageVM.instance;
  @Param @Require foundations: Tag[];

  build() {
    Column({ space: 8 }) {
      Text(`设施服务`)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start);

      Column({ space: 12 }) {
        if (this.foundations) {
          Column() {
            Grid() {
              ForEach(this.vm.getTags(this.foundations, '支持'),
                (item: string) => {
                  GridItem() {
                    Row() {
                      Image($r('app.media.icon_configuration')).size({ width: 16, height: 16 });
                      Text(`${item}`)
                        .fontSize(12)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontColor($r('sys.color.font_primary'))
                        .margin({ left: 4 });
                    }.justifyContent(FlexAlign.Start).width(Constants.FULL_SCREEN);
                  };
                }, (item: string) => item);
            }.columnsTemplate('0.9fr 1.2fr 1.1fr 1fr')
            .rowsGap(12);
          };

          Column() {
            Grid() {
              ForEach(this.vm.getTags(this.foundations, '不支持'),
                (item: string) => {
                  GridItem() {
                    Row() {
                      Image($r('app.media.icon_no_configuration')).size({ width: 16, height: 16 });
                      Text(`${item}`)
                        .fontSize(12)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontColor($r('sys.color.font_tertiary'))
                        .margin({ left: 4 });
                    }.justifyContent(FlexAlign.Start).width(Constants.FULL_SCREEN);
                  };
                }, (item: string) => item);
            }.columnsTemplate('0.9fr 1.2fr 1.1fr 1fr')
            .rowsGap(12);
          };
        }
      }.backgroundColor($r('sys.color.comp_background_primary')).padding(12).borderRadius(16);
    };
  }
}