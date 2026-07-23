import { getColor, getMedia, getString } from '@agctemplate/resources';
import {
  AppStorageKeys,
  BreakPoint,
  BreakPointType,
  BreakPointValue,
  FontModel,
  fp2pxUtil
} from '@agctemplate/widgets';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct VideoSeries {
  @Param @Require title: string;
  @Param @Require currentEpisode: number;
  @Param @Require totalCount: number;
  @Param @Require likeCount: number;
  @Param @Require isLike: boolean
  @Param @Require cover: string; // 封面
  @Param @Require isVip: boolean
  @Param isDeleting: boolean = false
  @Local isSelect: boolean = false
  @Event onContinueWatch: () => void
  @Event isSelectBack: (isSelect: boolean) => void
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Monitor('isDeleting')
  onChange() {
    this.isSelect = false
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.isSelect ? getMedia('app.media.icon_Checked') : getMedia('app.media.icon_ans_common'))
          .width(20)
          .aspectRatio(1)
          .offset({ x: -6, y: 6 })
          .onClick(() => {
            this.isSelect = !this.isSelect
            this.isSelectBack(this.isSelect)
          })
          .visibility(this.isDeleting ? Visibility.Visible : Visibility.Hidden)
          .zIndex(2)

        if (this.isVip === true) {
          Image(getMedia('app.media.vip'))
            .width(28)
            .height(16)
            .position({ left: 76 })
            .zIndex(1)
        }

        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.cover)
            .width(new BreakPointType<string | number>({
              sm: 99,
              md: 159,
              lg: 189
            }).getValue(this.currentBreakpoint.value))
            .height(new BreakPointType<string | number>({
              sm: 131,
              md: 210,
              lg: 249
            }).getValue(this.currentBreakpoint.value))

          if (this.isDeleting) {
            Row()
              .width(new BreakPointType<string | number>({
                sm: 99,
                md: 159,
                lg: 189
              }).getValue(this.currentBreakpoint.value))
              .height(new BreakPointType<string | number>({
                sm: 131,
                md: 210,
                lg: 249
              }).getValue(this.currentBreakpoint.value))
              .backgroundColor('#000000')
              .opacity(0.4)
              .borderRadius(14)
              .onClick(() => {
                this.isSelect = !this.isSelect
                this.isSelectBack(this.isSelect)
              })
          }

          if (!this.isLike) {
            Row() {
              Text(`${this.totalCount}集全`)
                .fontSize(fp2pxUtil(10))
                .fontColor($r('sys.color.font_on_primary'))
            }
            .height(15)
            .padding({
              right: 8,
              left: 8,
            })
            .backgroundColor('rgba(0, 0, 0, 0.4)')
            .borderRadius(14)
          } else {
            Row({ space: 2.5 }) {
              Image(getMedia('app.media.thumb_up_white'))
                .width(9)
              Text(`${this.likeCount}`)
                .fontSize(fp2pxUtil(10))
                .fontColor($r('sys.color.font_on_primary'))
            }
            .height(15)
            .padding({
              right: 8,
              left: 8
            })
            .backgroundColor('rgba(0, 0, 0, 0.4)')
            .borderRadius(14)
          }
        }
      }
      .onClick(() => {
        if (this.onContinueWatch) {
          this.onContinueWatch()
        }
      })

      Column() {
        Text(this.title)
          .fontSize(this.fontModel.getFg(14))
          .lineHeight(this.fontModel.getDesFg(19))
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .margin({ top: 8 })

        Text(getString('app.string.have_watch', `${this.currentEpisode}`))
          .fontSize(fp2pxUtil(12))
          .lineHeight(16)
          .fontColor($r('sys.color.font_tertiary'))
          .maxLines(1)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .margin({ top: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

    }
    .accessibilityGroup(true)
    .width(new BreakPointType<string | number>({
      sm: 97,
      md: 159,
      lg: 189
    }).getValue(this.currentBreakpoint.value))
    .height(new BreakPointType<string | number>({
      sm: 176,
      md: 255,
      lg: 294
    }).getValue(this.currentBreakpoint.value))
    .margin({ top: 8, bottom: 8 })
  }
}