import { TCRouter } from '../comp/TCRouter';
import { Constants } from '../constant/Constants';
import { BookInfo, GroupBook } from '../model/Book';
import { BookSubcategory } from '../model/BookSortInfo';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { BookCover, BookCoverSM, BookGroupCover, BookLikeCover } from './CommonUI';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';
import { FontModel } from '../model/FontModel';
import { MinorsMode } from '../model/MinorsModel';
import { MinorsProtectionUtils } from '../utils/minorsProtectionUtils';


export interface CategoryInfo {
  category: string;
  isCategory: boolean
}

export function getFreeText(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '免费';
    case '1':
      return '会员';
    case '2':
      return '付费';
    default:
      return null;
  }
}

export function getFreeColor(isFree?: string): string | null {
  switch (isFree) {
    case '0':
      return '#64BB5C';
    case '1':
      return '#F9A01E';
    case '2':
      return '#E84026';
    default:
      return null;
  }
}

/**
 * 图书小卡，仅有图片+书名 换行：评分+类型
 */
@ComponentV2
export struct BookLittleCardHome {
  @Param info: BookInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r(this.info?.coverUrl?.toString()))
          .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
          .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
          .objectFit(ImageFit.Auto)
          .borderRadius(10)
          .draggable(false)
        Column() {
          Text(getFreeText(this.info?.isFree))
            .fontSize(this.fontModel.getFg(10))
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .height(20)
            .width(35)
            .backgroundColor(getFreeColor(this.info?.isFree))
            .borderRadius(10)
        }
        .padding(8)
      }

      Text(this.info?.name)
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        Text(this.info?.rate)
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('sys.color.mask_secondary'))
        Text(this.info?.category)
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
      .align(Alignment.Start)
      .margin({ top: 8 })
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书猜你喜欢小卡
 */
@ComponentV2
export struct BookLittleCard {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param @Require info: BookInfo;
  @Event manageEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };
  @Param isDownload: boolean = false;
  @Param downloading: boolean = false;
  @Param downloadProgress: number = 0;
  @Local readProgress: string = '';
  @Param isPin: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  aboutToAppear(): void {
    this.readProgress = this.info.readProgress!;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(typeof this.info.coverUrl === 'string' ? $r(this.info.coverUrl) : this.info.coverUrl)
            .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
            .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
            .objectFit(ImageFit.Cover)
            .borderRadius(10)
            .draggable(false)
          Column() {
            Text(getFreeText(this.info?.isFree))
              .fontSize(this.fontModel.getFg(10))
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .height(20)
              .width(35)
              .backgroundColor(getFreeColor(this.info?.isFree))
              .borderRadius(10)
          }
          .padding(8)
        }

        if (this.isPin) {
          Row() {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line'))
              .fontSize(fp2pxUtil(16))
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .size({ width: 24, height: 24 })
          .borderRadius({ topLeft: 8, bottomRight: 8 })
        }
      }


      Text(this.info?.name)
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        Column() {
          Row() {
            if (this.isDownload) {
              //下载完成标志
              Image($r('app.media.download_finish'))
                .height(16)
                .width(16)
            }
            Text(this.readProgress)
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
          }

          //正在下载的进度条
          if (this.downloading) {
            Progress({ value: 0, total: 100, type: ProgressType.Linear })
              .width(84)
              .color('#64BB5C')
              .value(this.downloadProgress)
          }
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Image($r('app.media.ic_public_ellipsis'))
            .height(12)
            .width(12)
            .objectFit(ImageFit.Auto)
        }.layoutWeight(1).justifyContent(FlexAlign.End)
        .onClick(() => {
          this.manageEvent(this.info as BookInfo, true);
        })
      }
      .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
      .align(Alignment.Start)
      .margin({ top: 4 })
    }
    .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.0) {
        this.readProgress = this.info.readProgress!
      }
    })
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}


/**
 * 管理书籍-猜你喜欢
 */
@ComponentV2
export struct BookLikeCard {
  @Param @Require info: BookInfo;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Event showEvent: (isShow: boolean) => void = (isShow: boolean) => {
  }

  build() {
    Column() {
      BookLikeCover(this.info?.coverUrl, this.info?.isFree);
      Text(this.info?.name)
        .fontSize(this.fontModel.getFg(12))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ left: 5, right: 5, top: 5 })
    }
    .width(104)
    .align(Alignment.Start)
    .margin({ top: 4 })
    .justifyContent(FlexAlign.SpaceBetween)

    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
        this.showEvent(false)

      }
    })
  }
}


/**
 *  宫格模式图书组合打卡
 */
@ComponentV2
export struct BookGroupCard {
  @Param info: GroupBook | undefined = undefined;
  @Local numbers1: number[] = [1, 2, 3, 4];
  @Local numbers2: BookInfo[] = [];
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param isPin: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Grid() {
            ForEach(this.info?.groupBooks, (item: BookInfo) => {
              GridItem() {
                BookGroupCover(item.coverUrl);
              }
              .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 40 : 64)
              .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 56 : 89)

            }, (item: string) => JSON.stringify(item))

          }
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr')
        }
        .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 104 : 164)
        .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 144 : 214)
        .borderRadius(10)
        .backgroundColor($r('sys.color.comp_background_primary'))

        if (this.isPin) {
          Row() {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line'))
              .fontSize(fp2pxUtil(16))
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .size({ width: 24, height: 24 })
          .borderRadius({ topLeft: 8, bottomRight: 8 })
        }
      }

      Text(this.info?.groupName)
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      Row() {
        if (this.info?.groupBooks?.length) {
          Text('共' + this.info?.groupBooks?.length.toString() + '本')
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.mask_secondary'))
        } else {
          Text('共' + 0 + '本')
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .width(104)
      .align(Alignment.Start)
      .margin({ top: 4 })
    }
  }
}

/**
 * 图书大卡，书名、介绍、评分
 */
@ComponentV2
export struct BookBigCard {
  @Param info: BookInfo | undefined = undefined;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      BookCover(this.info?.coverUrl, 144, 104, this.info?.isFree);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
            Row() {
              Image($r('app.media.ic_public_star'))
                .height(15)
                .width(20)
                .padding({ right: 4 })
              Text(`${this.info?.rate}`)
                .fontSize(this.fontModel.getFg(14))
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .padding({ top: 10, bottom: 20 })
            .alignSelf(ItemAlign.Start)
        }

        Column() {
          Text('作者：' + this.info?.author)
            .fontSize(this.fontModel.getFg(12))
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .margin({ top: 20 })

      }
      .layoutWeight(1)
    }
    .padding({ left: 12, right: 12 })
    .height(150)
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书类别，图片、类别名
 */
@ComponentV2
export struct BookCategoryItem {
  @Param categoryInfo: BookSubcategory | undefined = undefined;
  @Local pushParam?: CategoryInfo
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      if (this.categoryInfo?.imgUrl) {
        Column() {
          Image($r(this.categoryInfo?.imgUrl?.toString()))
            .height(70)
            .width(70)
            .borderRadius(8)
          Text(this.categoryInfo?.subcategoryName)
            .fontSize(this.fontModel.getFg(14))
            .width(70)
            .textAlign(TextAlign.Center)
        }
        .onClick(() => {
          this.pushParam = { category: this.categoryInfo?.subcategoryName!, isCategory: true }
          TCRouter.push(Constants.SEARCH_ROUTE, this.pushParam)
        })
      } else {
        Row() {
          Text(this.categoryInfo?.subcategoryName)
            .fontSize(fp2pxUtil(14))
        }
        .height(28)
        .width(70)
        .borderRadius(14)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pushParam = { category: this.categoryInfo?.subcategoryName!, isCategory: true }
          TCRouter.push(Constants.SEARCH_ROUTE, this.pushParam)
        })
      }
    }
  }
}

/**
 * 列表模式分组
 */
@ComponentV2
export struct GroupListCard {
  @Param info: GroupBook | undefined = undefined;
  @Param isPin: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Grid() {
          ForEach(this.info?.groupBooks, (item: BookInfo) => {
            GridItem() {
              BookGroupCover(item.coverUrl);
            }
            .width(40)
            .height(56)

          }, (item: string) => JSON.stringify(item))

        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .height(144)
        .width(104)
        .borderRadius(10)
        .backgroundColor(Color.White)

        if (this.isPin) {
          Row() {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line'))
              .fontSize(fp2pxUtil(16))
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .size({ width: 24, height: 24 })
          .borderRadius({ topLeft: 8, bottomRight: 8 })
        }
      }


      Blank()
        .width(16)
      Column() {

        Text(this.info?.groupName)
          .fontSize(this.fontModel.getFg(16))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(104)
          .textAlign(TextAlign.Start)
          .padding({ top: 5 })

        Text('共' + this.info?.groupBooks?.length.toString() + '本')
          .fontSize(this.fontModel.getFg(12))
          .fontColor($r('sys.color.mask_secondary'))

      }
      .height(150)
      .padding({
        bottom: 5
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .height(150)
    .width(Constants.FULL_SIZE)
  }
}


/**
 * 组合card
 */
@ComponentV2
export struct GroupBookCheckCard {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param info: BookInfo | undefined = undefined;
  @Param isSelect: boolean = false;
  @Event manageGroupEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };
  @Event changeSelect: (val: boolean) => void;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local readProgress: string = '';
  @Param isDownload: boolean = false;

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
      Row() {
        Checkbox()
          .height(24)
          .width(24)
          .selectedColor('#E84026')
          .select(this.isSelect)
          .onChange((val: boolean) => {
            // 触发事件通知父组件
            this.changeSelect(val);
            this.manageGroupEvent(this.info as BookInfo, val);
          })
      }.width(30).height(30).margin({ right: 5 })

      BookCoverSM(this.info?.coverUrl, this.info?.isFree);

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            Row() {
              Text(`${this.info?.rate}` + '分')
                .fontSize(this.fontModel.getFg(16))
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
        .onClick(() => {
        }) //防穿

        Column() {
          Row() {
            if (this.isDownload) {
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
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height(122)
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
    .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.0) {
        this.readProgress = this.info?.readProgress!
      }
    })
  }
}

/*
 * 列表组合card
 * */
@ComponentV2
export struct bookShelfCard {
  @Param @Require info: BookInfo;
  @Param isPin: boolean = false;
  @Event manageEvent: (book: BookInfo, isShowM: boolean) => void = (book: BookInfo, isShowM: boolean) => {
  };
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(12) }
    }) {
      Stack({ alignContent: Alignment.TopStart }) {
        BookCover(this.info?.coverUrl, 90, 68, this.info.isFree);
        if (this.isPin) {
          Row() {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line'))
              .fontSize(fp2pxUtil(16))
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .size({ width: 24, height: 24 })
          .borderRadius({ topLeft: 8, bottomRight: 8 })
        }
      }

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
            Row() {
              if (this.info?.rate) {
                Text(`${this.info?.rate}` + '分')
                  .fontSize(this.fontModel.getFg(16))
                  .fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
              }
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .padding({ top: 10 })
            .alignSelf(ItemAlign.Start)
        }

        Column({ space: 8 }) {
          Row() {
            Text(this.info?.category)
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular).textAlign(TextAlign.Start)

            Text(this.info?.count)
              .fontSize(this.fontModel.getFg(12))
              .textAlign(TextAlign.Start)
              .padding({ left: 10 })
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }

          Text(this.info.readProgress!)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .layoutWeight(1)
    }
    .padding(12)
    .width(Constants.FULL_SIZE)
  }
}

/**
 * 图书小卡，仅有图片+书名 换行：评分+类型
 */
@ComponentV2
export struct BookHomeCard {
  @Param info: BookInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  build() {
    Column() {
      BookCover(this.info?.coverUrl, 144, 104, this.info?.isFree);
      Text(this.info?.name)
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(104)
        .textAlign(TextAlign.Start)
        .padding({ top: 5 })
      if (!this.minorsMode.isMinorsMode) {
        Row() {
          Text(this.info?.rate)
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.mask_secondary'))
          Text(this.info?.category)
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.mask_secondary'))
        }
        .width(104)
        .align(Alignment.Start)
        .margin({ top: 4 })
      }
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.pushByLogin(Constants.READ_KIT_ROUTER, this.info);
      }
    })
  }
}

