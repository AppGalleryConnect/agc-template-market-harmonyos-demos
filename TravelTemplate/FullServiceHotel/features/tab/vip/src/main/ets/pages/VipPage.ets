import { CommonConstants, TelUtil } from 'commonlib';
import { https, VipGradeItem } from 'network';
import { EquityItem, VipGradeItemModel } from '../models/VipGrade';
import { CommonButton } from 'componentlib';

@ComponentV2
export struct VipPage {
  @Local
  private index: number = 0;
  @Local
  private vipGradeList: VipGradeItemModel[] = [];
  @Local
  private currentItem: VipGradeItemModel = new VipGradeItemModel();

  async aboutToAppear() {
    const res = await https.getGradeList();
    if (res.code === 0) {
      let initList: VipGradeItem[] = res.data;
      initList.forEach((item) => {
        const grandItem = new VipGradeItemModel(item);
        this.vipGradeList.push(grandItem);
      });
      if (this.vipGradeList.length) {
        this.currentItem = new VipGradeItemModel(initList[0]);
      }
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.vipGradeList.length) {
            Swiper() {
              ForEach(this.vipGradeList, (item: VipGradeItemModel, index: number) => {
                Image(item.gradeCover)
                  .margin(index === 0 ? { left: 10, right: 5 } : { left: 5, right: 10 });
              }, (item: VipGradeItemModel) => JSON.stringify(item));
            }
            .width('100%')
            .autoPlay(false)
            .indicator(false)
            .loop(false)
            .vertical(false)
            .index(this.index)
            .disableSwipe(false)
            .onChange((index: number) => {
              this.currentItem.update(this.vipGradeList[index]);
            })
            .displayCount(1)
            .nextMargin(25, true)
            .prevMargin(25, true)
            .margin({ top: 50 });

            this.vipInfoBuilder();
            this.vipLabelBuilder();
          }
        };
      };

      Blank();

      CommonButton({
        title: '立即致电',
        handleClick: () => {
          TelUtil.makeCall(CommonConstants.TEL_NUMBER);;
        },
      });
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  vipInfoBuilder() {
    Column() {
      Text(this.currentItem.gradeName)
        .fontSize($r('app.string.font_size_36'))
        .fontWeight(500)
        .margin({ top: $r('app.string.margin_m'), bottom: $r('app.string.margin_m') });
      Grid() {
        ForEach(this.currentItem.equityList, (item: EquityItem) => {
          GridItem() {
            Column() {
              Image(item.equityIcon)
                .height(40)
                .width(40);
              Text(item.equityName)
                .fontSize($r('app.string.font_size_28'))
                .maxLines(1)
                .fontColor('#FF191919')
                .margin({ top: $r('app.string.margin_s') });
            };
          };
        }, (item: EquityItem) => JSON.stringify(item));
      }
      .editMode(false)
      .supportAnimation(false)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap($r('app.string.margin_m'))
      .alignItems(GridItemAlignment.STRETCH)
      .width('100%')
      .height('25%');
    }
    .width('100%');
  }

  @Builder
  vipLabelBuilder() {
    Column() {
      Divider()
        .vertical(false)
        .color('#FFF2F2F2')
        .strokeWidth(5)
        .lineCap(LineCapStyle.Butt);
      Column() {
        Text(this.currentItem.introTitle)
          .fontSize($r('app.string.font_size_32'))
          .fontColor('#191919')
          .fontWeight(500)
          .margin({ bottom: $r('app.string.margin_s') });

        Text(this.currentItem.introText)
          .fontSize($r('app.string.font_size_24'))
          .lineHeight('36lpx')
          .fontColor('#191919')
          .margin({ bottom: $r('app.string.margin_s') });
      }
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.string.padding_m'));
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start);
  }
}

@Builder
export function vipPageBuilder() {
  VipPage();
}