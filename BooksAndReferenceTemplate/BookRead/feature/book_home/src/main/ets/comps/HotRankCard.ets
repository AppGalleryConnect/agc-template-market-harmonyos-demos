import { BookInfo, Constants, FontModel, getFreeColor, getFreeText, rankListInfo, TCRouter } from 'common';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';

/**
 * 搜索页面热搜榜card
 */
@ComponentV2
export struct HotRankCard {
  @Param info: rankListInfo | undefined = undefined;

  build() {
    Column() {
      Row() {
        Text(this.info?.rankName)
          .fontSize($r('sys.float.Body_L'))
          .fontColor('#e6000000')
          .fontWeight(FontWeight.Medium)
          .height(22)
          .padding({ left: '12vp' })
        Row() {
          Text($r('app.string.more'))
            .fontSize($r('sys.float.Caption_L'))
            .fontColor('#99000000')

          Image($r('app.media.arrow_right'))
            .height(16)
            .width(16).padding({ left: '6vp' })
        }.justifyContent(FlexAlign.SpaceBetween).padding({ right: '12vp' })
        .onClick(() => {
          TCRouter.push(Constants.BOOK_LIST_ROUTE, { category: this.info?.rankName, books: this.info?.detailBooks })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .height(46)
      .linearGradient({
        direction: GradientDirection.Left, // 渐变方向
        repeating: true, // 渐变颜色是否重复
        colors: [['#DDF3FF', 0.0], ['#E7E1FF', 0.45], ['#E1FFF0', 1]]
      })

      List({ space: 6, initialIndex: 0 }) {
        ForEach(this.info?.detailBooks, (book: BookInfo, index: number) => {
          ListItem() {

            Row() {
              Image($r(book?.rankUrl?.toString()))
                .height(24)
                .width(36)
                .padding({ left: 12 })
              Image($r(book?.coverUrl?.toString()))
                .width(48)
                .height(64)
                .borderRadius(8).padding({ left: 8, top: 8, bottom: 4 })

              Flex({ alignItems: ItemAlign.Start }) {
                Column() {
                  Text(book?.name)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 8, top: 12.5, right: 8 })


                  Text(book?.count)
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .padding({ left: 8, top: 4, right: 8 })
                }.alignItems(HorizontalAlign.Start)
              }

            }.alignItems(VerticalAlign.Center)
            .onClick(() => {
              TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, book);
            })

          }
        }, (item: string) => item)
      }
      .listDirection(Axis.Vertical) // 排列方向
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .cachedCount(3)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.ohos_id_normalbtn_unfocus_bg'))
    }
    .width(300)
    .layoutWeight(1)
    .borderRadius(10)
    .clip(true)

  }
}


/**
 * 搜索结果
 */
@ComponentV2
export struct SearchResultCard {
  @Param info: BookInfo | undefined = undefined;
  @Local readProgress: string = '';

  aboutToAppear(): void {
    this.readProgress = this.info?.readProgress!;
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      BookCover(this.info?.coverUrl, this.info?.isFree);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            Row() {
              Text(`${this.info?.rate}` + '分')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .alignSelf(ItemAlign.Start)
            .padding({ top: 10, bottom: 20 })
        }

        Column() {
          Row() {
            if (this.info?.isDownload) {
              //下载完成标志
              Image($r('app.media.download_finish'))
                .height(16)
                .width(16)
            }
            Text(this.readProgress)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
          }.width('100%').justifyContent(FlexAlign.Start)

        }
        .margin({ top: 20 })
      }
      .layoutWeight(1)
    }
    .height(122)
    .width(Constants.FULL_SIZE)
    .borderRadius(16)
    .padding({left: 12, right: 12, top: 16, bottom: 16})
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
    .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.0) {
        this.readProgress = this.info?.readProgress!
      }
    })
  }
}

/**
 * 阅读记录
 */
@ComponentV2
export struct ReadRecordCard {
  @Param info: BookInfo | undefined = undefined;
  @Param isSelectAll: boolean = false;
  @Consumer('isDeleteRecord') isDeleteRecord: boolean = false;
  @Event onDelete: (value: boolean) => void = () => {
  }
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      if (this.isDeleteRecord) {
        Column() {
          Checkbox({ name: 'delete', group: 'deleteGroup' })
            .select(this.isSelectAll || this.info?.isSelect)
            .selectedColor($r('app.color.slider_selected_color'))
            .unselectedColor($r('sys.color.icon_tertiary'))
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              this.onDelete(value);
            })
        }
        .height(90)
        .justifyContent(FlexAlign.Center)
      }

      Image(typeof this.info?.coverUrl === 'string' ? $r(this.info.coverUrl) : this.info?.coverUrl)
        .height(90)
        .width(68)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .draggable(false)

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Row() {
          Text(this.info?.name)
            .width(`calc(100% - ${40}vp)`)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium);
          Row() {
            Text(`${this.info?.rate}` + '分')
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
          }
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)

        Column({ space: 4 }) {
          Text(this.info?.description)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .alignSelf(ItemAlign.Start)

          Row() {
            Text(this.info?.category)
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular).textAlign(TextAlign.Start)

            Text(`${this.info?.count}万字`)
              .fontSize(this.fontModel.getFg(12))
              .textAlign(TextAlign.Start)
              .padding({ left: 2 })
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }.width('100%').justifyContent(FlexAlign.Start)
        }


        Row() {
          Text('读至')
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular).textAlign(TextAlign.Start)

          Text(this.info?.count)
            .fontSize(this.fontModel.getFg(12))
            .textAlign(TextAlign.Start)
            .padding({ left: 2 })
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
        }.width('100%').justifyContent(FlexAlign.Start)
      }
      .height(90)
      .layoutWeight(1)

      Column() {
        SymbolGlyph($r('sys.symbol.bookshelf_badge_plus'))
          .fontSize(fp2pxUtil(24))
          .fontColor(true ? [$r('sys.color.icon_primary')] : [$r('sys.color.icon_secondary')])
          .onClick(() => {

          })
      }
      .height(90)
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

@Builder
export function BookCover(image?: PixelMap | ResourceStr | DrawableDescriptor, isFree?: string) {
  Stack({ alignContent: Alignment.TopEnd }) {
    Image(typeof image === 'string' ? $r(image) : image)
      .height(90)
      .width(68)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
      .draggable(false)
    Column() {
      Text(getFreeText(isFree))
        .fontSize(10)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(16)
        .width(36)
        .backgroundColor(getFreeColor(isFree))
        .borderRadius(14)
    }
    .padding(4)
  }
}