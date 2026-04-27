import { Constants } from '../commons/Constants'
import { SkuReviewModel, ReviewDraftModel } from '../commons/Models'
import { OrderSkuItem, ReviewDraft, ReviewMediaItem } from '../commons/Types'
import { CommonRating } from '../components/CommonRating'
import { ReviewMediaType } from '../commons/Enums';
import { MediaFileUtil } from '../commons/MediaFileUtil';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';

@ComponentV2
export struct ProductReviewCreation {
  @Param
  skuList: OrderSkuItem[] = []
  @Local
  draft: ReviewDraftModel = new ReviewDraftModel()
  @Local
  openPreview: boolean = false
  @Local
  previewItem?: ReviewMediaItem = undefined
  @Local
  scroller: Scroller = new Scroller()
  @Event
  handleSubmit: (draft: ReviewDraft) => void

  @Computed
  get enableSubmit() {
    if (!this.draft.shipmentRating || !this.draft.serviceRating) {
      return false
    }
    for (const item of this.draft.reviewList) {
      if (!item.rating) {
        return false
      }
    }
    return true;
  }

  @Computed
  get previewSheetTitle() {
    if (this.previewItem) {
      return this.previewItem.type === ReviewMediaType.IMAGE ? '图片预览' : '视频预览'
    }
    return ''
  }

  aboutToAppear(): void {
    if (this.skuList.length) {
      this.skuList.forEach((sku) => {
        const item = new SkuReviewModel()
        item.productId = sku.productId
        item.skuCode = sku.skuCode
        item.skuDesc = sku.skuDesc
        this.draft.reviewList.push(item)
      })
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.skuList.length === 1) {
            this.buildSingleReview()
          } else if (this.skuList.length > 1) {
            this.buildMultiReview()
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .margin({ bottom: $r('app.float.space_l') })

      Button('提交')
        .backgroundColor($r('app.color.theme_color'))
        .width($r('app.string.size_percent_full'))
        .enabled(this.enableSubmit)
        .onClick(() => {
          this.handleSubmit?.(this.draft)
        })
        .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .height($r('app.string.size_percent_full'))
    .width($r('app.string.size_percent_full'))
    .padding($r('app.float.space_l'))
  }

  @Builder
  buildSingleReview() {
    Column({ space: 16 }) {
      this.buildRating()
      this.buildInput(false, this.draft.reviewList[0].content, this.draft.reviewList[0])
      this.buildMediaPicker(this.draft.reviewList[0])
    }
  }

  @Builder
  buildMultiReview() {
    Column({ space: 16 }) {
      this.buildRating(false)
      this.buildInput(true, this.draft.feedback)
      List({ scroller: this.scroller, space: 48 }) {
        ForEach(this.draft.reviewList, (item: SkuReviewModel, index: number) => {
          ListItem() {
            Column() {
              this.buildProductCard(this.skuList[index], item)
              this.buildMediaPicker(item)
            }
          }
        }, (item: SkuReviewModel, index: number) => index + item.skuCode)
      }
      .divider({ color: $r('sys.color.comp_divider'), strokeWidth: 1 })

    }
  }

  @Builder
  buildRating(isSingle: boolean = true) {
    Column({ space: 16 }) {
      if (isSingle) {
        CommonRating({
          label: '商品评价',
          rating: this.draft.reviewList[0].rating,
          handleChange: (rating) => {
            this.draft.reviewList[0].rating = rating;
          },
        })
      }
      CommonRating({
        label: '物流服务',
        rating: this.draft.shipmentRating,
        handleChange: (rating) => {
          this.draft.shipmentRating = rating;
        },
      })
      CommonRating({
        label: '客服服务',
        rating: this.draft.serviceRating,
        handleChange: (rating) => {
          this.draft.serviceRating = rating;
        },
      })
    }
  }

  @Builder
  buildInput(isSummary: boolean = true, text: string, model?: SkuReviewModel) {
    TextArea({
      placeholder: '请在此留下您的宝贵意见',
      text,
    })
      .width($r('app.string.size_percent_full'))
      .height(120)
      .align(Alignment.TopStart)
      .selectedBackgroundColor($r('app.color.theme_color'))
      .backgroundColor($r('app.color.background_color_primary'))
      .caretColor($r('app.color.theme_color'))
      .placeholderFont({ size: 14 })
      .placeholderColor($r('sys.color.font_tertiary'))
      .maxLength(100)
      .showCounter(true)
      .onChange((value) => {
        if (isSummary) {
          this.draft.feedback = value
        } else if (model) {
          model.content = value
        }
      })
  }

  @Builder
  buildProductCard(skuItem: OrderSkuItem, model: SkuReviewModel) {
    Column({ space: 16 }) {
      Row() {
        Image(skuItem.banner)
          .width(60)
          .height(60)
          .borderRadius($r('app.float.border_radius_s'))
          .margin({ right: $r('app.float.space_s') })
        Column({ space: 8 }) {
          Text(skuItem.title)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
          Text(skuItem.skuDesc)
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level3'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)

      CommonRating({
        label: '商品评价',
        handleChange: (rating) => {
          model.rating = rating;
        },
      })

      this.buildInput(false, model.content, model)
    }

  }

  @Builder
  buildMediaPicker(model: SkuReviewModel) {
    GridRow({
      columns: {
        xs: 3,
        md: 5,
      },
      gutter: { x: 8, y: 8 },
    }) {
      if (model.mediaList.length < Constants.MAX_MEDIA_LENGTH) {
        GridCol() {
          Row() {
            Image($r('app.media.ic_add'))
              .width(24)
              .height(24)
              .fillColor($r('sys.color.icon_secondary'))
          }
          .width($r('app.string.size_percent_full'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .aspectRatio(1)
          .justifyContent(FlexAlign.Center)
          .borderRadius($r('app.float.border_radius_l'))
          .onClick(() => {
            MediaFileUtil.getMediaFromAlbum(model, this.getUIContext())
          })
        }
      }
      ForEach(model.mediaList, (item: ReviewMediaItem, index: number) => {
        GridCol({
          offset: 0,
          order: 0,
        }) {
          Stack() {
            Image(item.uri)
              .width($r('app.string.size_percent_full'))
              .aspectRatio(1)
              .borderRadius($r('app.float.border_radius_l'))
              .onClick(() => {
                const options = new ImagePreviewOptions()
                const mediaList: SourceImageModel[] = model.mediaList.map((item) => {
                  if (item.type === ReviewMediaType.MOVING_PHOTO && item.movingPhotoUri) {
                    return new SourceImageModel({
                      imageUrl: item.movingPhotoUri.imageUri,
                      videoUrl: item.movingPhotoUri.videoUri,
                    })
                  } else {
                    return new SourceImageModel({ imageUrl: item.uri })
                  }
                })
                options.setImageList(mediaList).setInitIndex(index)
                ImagePreview.open(this.getUIContext(), options)
              })
            Image($r('app.media.ic_delete_circle'))
              .width(24)
              .height(24)
              .zIndex(9)
              .position({ right: 8, top: 8 })
              .onClick(() => {
                model.mediaList.splice(index, 1)
              });
            if (item.type === ReviewMediaType.MOVING_PHOTO) {
              SymbolGlyph($r('sys.symbol.livephoto'))
                .position({ left: 8, bottom: 8 })
            }
          }
        }
      }, (item: ReviewMediaItem, index: number) => index + '__' + item.uri)
    }
    .width($r('app.string.size_percent_full'))
    .margin({
      top: $r('app.float.space_m'),
    })
  }

  @Builder
  buildPreviewSheet() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .draggable(false)
          .margin({ right: $r('app.float.space_s') })
          .borderRadius($r('app.float.border_radius_capsule'))
          .stateStyles({
            normal: {
              .backgroundColor($r('app.color.background_color_transparent'))
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            },
          })
          .onClick(() => {
            this.openPreview = false
            this.previewItem = undefined
          })
        Text(this.previewSheetTitle)
          .fontSize($r('app.float.font_size_20'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium);
      }
      .width($r('app.string.size_percent_full'))
      .margin({ top: 36, bottom: $r('app.float.space_l') })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.background_color_primary'))
      .padding({ left: $r('app.float.space_l') });

      if (this.previewItem?.uri) {
        if (this.previewItem.type === ReviewMediaType.IMAGE) {
          Scroll() {
            Image(this.previewItem.uri)
              .width($r('app.string.size_percent_full'))
              .height($r('app.string.size_percent_full'))
              .objectFit(ImageFit.Contain)
          }
          .padding($r('app.float.space_l'))
          .layoutWeight(1);
        } else if (this.previewItem.type === ReviewMediaType.VIDEO) {
          Row() {
            Video({
              src: this.previewItem.uri,
            })
              .width($r('app.string.size_percent_full'));
          }
          .padding($r('app.float.space_l'))
        }
      }
    }
    .height($r('app.string.size_percent_full'))
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}