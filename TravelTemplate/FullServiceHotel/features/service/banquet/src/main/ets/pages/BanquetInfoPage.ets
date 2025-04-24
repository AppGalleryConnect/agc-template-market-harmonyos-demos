import { GetBanquetRoomDetailResp, https, LayoutMethodItem, SiteInformationItem } from 'network';
import { CommonBanner, CommonScroll } from 'componentlib';
import { FormatUtil, RouterModule, TelUtil } from 'commonlib';

@ComponentV2
struct BanquetInfoPage {
  @Local
  private banquetDetail?: GetBanquetRoomDetailResp;

  getBanquetDetail(banquetId: number) {
    https.getBanquetRoomDetail(banquetId).then((res) => {
      if (res.code === 0) {
        this.banquetDetail = res.data;
        const layoutMethod = res.data.layoutMethod;
        this.banquetDetail.bannerList =
          this.banquetDetail.bannerList.map((item) => FormatUtil.getImgResource(item as string));
        this.banquetDetail.layoutMethod = layoutMethod.map((item) => {
          return {
            icon: FormatUtil.getImgResource(item.icon),
            id: item.id,
            layoutName: item.layoutName,
            personNum: item.personNum,
          } as LayoutMethodItem;
        });
      }
    });
  }

  build() {
    NavDestination() {
      if (this.banquetDetail) {
        CommonScroll({ title: this.banquetDetail.banquetName }) {
          Column() {
            CommonBanner({
              covers: this.banquetDetail.bannerList,
              x: 4,
              y: 3,
            });
            this.titleBuilder(this.banquetDetail.banquetName, this.banquetDetail.profile);
            this.commonDividerBuilder();
            this.spaceInfoBuilder();
            this.commonDividerBuilder();
            this.layoutInfoBuilder();
            this.commonDividerBuilder();
            this.phoneInfoBuilder();
          }
          .justifyContent(FlexAlign.Start);
        };
      }
      Row() {
        Button('即刻预约')
          .height(40)
          .width(120)
          .fontSize(16)
          .fontColor('#FFFFFFFF')
          .fontWeight(700)
          .backgroundColor('#FF007DFF')
          .onClick(() => {
            TelUtil.makeCall(this.banquetDetail?.banquetTel);
          });
      }
      .position({
        bottom: 0,
      })
      .padding($r('app.string.padding_m'))
      .width('100%')
      .justifyContent(FlexAlign.End);
    }
    .width('100%')
    .hideTitleBar(true)
    .onReady(() => {
      const banquetId = RouterModule.getNavParam<number>({
        url: 'BanquetInfoPage',
      });
      if (banquetId) {
        this.getBanquetDetail(banquetId);
      }
    });

  }

  @Builder
  titleBuilder(title: string, label: string) {
    Column() {
      Text(title)
        .fontSize($r('app.string.font_size_36'))
        .fontColor('#FF191919')
        .fontWeight(500)
        .margin({ bottom: $r('app.string.margin_s') });
      Text(label)
        .fontSize($r('app.string.font_size_24'))
        .fontColor('#FF666666');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.string.padding_m'), right: $r('app.string.padding_m') })
    .margin({ top: $r('app.string.margin_m'), bottom: $r('app.string.margin_m') });
  }

  @Builder
  spaceInfoBuilder() {
    Column() {
      Text('场地信息')
        .commonTitleTextStyle();
      if (this.banquetDetail?.siteInformation) {
        Flex() {
          ForEach(this.banquetDetail.siteInformation, (item: SiteInformationItem) => {
            Row() {
              Text(item.siteName)
                .labelTextStyle()
                .margin({ right: $r('app.string.margin_xs') });
              Text(item.content)
                .labelTextStyle()
                .fontColor($r('app.color.font_color_level1'));
            }
            .justifyContent(FlexAlign.Center)
            .margin({ right: $r('app.string.margin_m') });
          }, (item: SiteInformationItem) => JSON.stringify(item));
        };
      }
    }
    .commonContainerStyle();
  }

  @Builder
  layoutInfoBuilder() {
    Column() {
      Text('布局方式')
        .commonTitleTextStyle();
      if (this.banquetDetail?.layoutMethod) {
        Grid() {
          ForEach(this.banquetDetail.layoutMethod, (item: LayoutMethodItem) => {
            GridItem() {
              Row() {
                Image(item.icon)
                  .draggable(false)
                  .height(30)
                  .width(30)
                  .objectFit(ImageFit.Fill)
                  .borderWidth(1)
                  .borderColor('#FFE5E5E5')
                  .padding(4)
                  .margin({ right: 6 });
                Column() {
                  Text(item.layoutName)
                    .labelTextStyle();
                  Text(item.personNum)
                    .labelTextStyle();
                }
                .height(30)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start);
              }
              .justifyContent(FlexAlign.Start);
            };
          }, (item: LayoutMethodItem) => JSON.stringify(item));
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap($r('app.string.margin_m'))
        .rowsGap($r('app.string.margin_s'));
      }
    }
    .commonContainerStyle();
  }

  @Builder
  phoneInfoBuilder() {
    Column() {
      Text('电话预订')
        .commonTitleTextStyle();
      Row() {
        Image($r('app.media.icon_phone'))
          .height(13)
          .fillColor('#FF007DFF')
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .margin({ right: 3 });
        Text(this.banquetDetail?.banquetTel)
          .height(13)
          .fontSize(13)
          .fontColor('#FF007DFF');
      }
      .alignItems(VerticalAlign.Center);
    }
    .commonContainerStyle();
  }

  @Builder
  commonDividerBuilder() {
    Divider()
      .strokeWidth('10px')
      .color('#f2f2f2ff');
  }
}


@Builder
export function banquetInfoPageBuilder() {
  BanquetInfoPage();
}

@Extend(Column)
function commonContainerStyle() {
  .width('100%')
  .alignItems(HorizontalAlign.Start)
  .padding($r('app.string.padding_m'));
}

@Extend(Text)
function commonTitleTextStyle() {
  .fontSize($r('app.string.font_size_32'))
  .fontColor('#FF191919')
  .margin({ bottom: $r('app.string.margin_s') });
}

@Extend(Text)
function labelTextStyle() {
  .fontSize($r('app.string.font_size_24'))
  .fontColor('#FF666666');
}