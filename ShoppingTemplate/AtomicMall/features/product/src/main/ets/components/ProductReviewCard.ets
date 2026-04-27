import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview'
import { ProductReviewItem, ReviewMediaItem, ReviewMediaType } from 'lib_network'

@ComponentV2
export struct ProductReviewCard {
  @Param
  reviewItem: ProductReviewItem | undefined = undefined
  @Local
  options: ImagePreviewOptions = new ImagePreviewOptions()

  aboutToAppear(): void {
    if (this.reviewItem?.mediaList?.length) {
      const mediaList: SourceImageModel[] = this.reviewItem.mediaList.map((item) => {
        if (item.type === ReviewMediaType.MOVING_PHOTO && item.movingPhotoUri) {
          return new SourceImageModel({
            imageUrl: item.movingPhotoUri.imageUri,
            videoUrl: item.movingPhotoUri.videoUri,
          })
        } else {
          return new SourceImageModel({ imageUrl: item.uri })
        }
      })
      this.options.setImageList(mediaList)
    }
  }

  build() {
    Column() {
      if (this.reviewItem) {
        Row() {
          Image(this.reviewItem.userAvatar ? this.reviewItem.userAvatar : $r('app.media.default_avatar'))
            .width(24)
            .height(24)
            .borderRadius($r('app.float.border_radius_capsule'))
            .backgroundColor(Color.White)
            .margin({ right: $r('app.float.space_s') })
          Text() {
            Span(this.reviewItem.userName)
              .fontColor($r('app.color.font_color_level2'))
            Span(' ').letterSpacing(8)
            ForEach(this.reviewItem.skuDesc, (desc: string, index: number) => {
              Span(desc)
              if (index < this.reviewItem!.skuDesc.length - 1) {
                Span('; ')
              }
            }, (item: string, index: number) => index + item)
          }
          .fontSize($r('app.float.font_size_12'))
          .fontColor($r('app.color.font_color_level3'))
          .layoutWeight(1)
          .margin({ right: $r('app.float.space_l') })

          Row({ space: 4 }) {
            ForEach([1, 2, 3, 4, 5], (item: number) => {
              Image($r('app.media.ic_star_filled'))
                .width(12)
                .height(12)
                .fillColor(this.reviewItem!.rating >= item ? $r('sys.color.multi_color_08') :
                  $r('app.color.font_color_level3'))
            }, (item: number) => item.toString())
          }
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.float.space_xs') })

        Column() {
          Text(this.reviewItem.content)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
          if (this.reviewItem.mediaList.length) {
            GridRow({
              columns: {
                xs: 3,
                md: 5,
              },
              gutter: { x: 8, y: 8 },
            }) {
              ForEach(this.reviewItem.mediaList, (item: ReviewMediaItem, index: number) => {
                GridCol({
                  offset: 0,
                  order: 0,
                }) {
                  Stack() {
                    Image(item.uri)
                      .width($r('app.string.size_percent_full'))
                      .aspectRatio(1)
                      .borderRadius($r('app.float.border_radius_s'))
                      .onClick(() => {
                        this.options.setInitIndex(index)
                        ImagePreview.open(this.getUIContext(), this.options)
                      })
                    if (item.type === ReviewMediaType.MOVING_PHOTO) {
                      SymbolGlyph($r('sys.symbol.livephoto'))
                        .position({ left: 8, bottom: 8 })
                    }
                  }
                }
              }, (item: ReviewMediaItem, index: number) => index + JSON.stringify(item))
            }
            .width($r('app.string.size_percent_full'))
            .margin({
              top: $r('app.float.space_m'),
            })
          }
          Text(this.formatFullDate(new Date(this.reviewItem.date)))
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level3'))
            .width($r('app.string.size_percent_full'))
            .textAlign(TextAlign.End)
            .margin({ top: $r('app.float.space_m') })
        }
        .margin({ left: 32 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  formatFullDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());

    return `${year}年${month}月${day}日 ${hours}:${minutes}`;
  }
}