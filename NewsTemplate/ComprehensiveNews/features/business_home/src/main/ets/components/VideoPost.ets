import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { CommonConstants, MediaUtils, RouterMap, RouterUtils } from 'lib_common'
import { NewsPostViewModel } from '../viewmodels/NewsPostViewModel'

@ComponentV2
export struct VideoPost {
  @Param fontSizeRatio: number = 1
  @Local newsPostViewModel: NewsPostViewModel = new NewsPostViewModel()
  @Local videoUri: string = ''
  @Local surfaceUrl: string = ''
  @Local body: string = ''
  @Event onValidate: (isCanBack: boolean) => void = () => {
  }

  @Computed
  get isCanBack() {
    return !!this.surfaceUrl || !!this.body
  }

  @Builder
  videoBox(surfaceUrl: string) {
    Stack() {
      Stack() {
        Image(surfaceUrl)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .draggable(false)
          .objectFit(ImageFit.Cover)
        Row()
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .backgroundColor($r('sys.color.mask_fourth'))
        Image($r('app.media.ic_public_close_circle'))
          .width(32)
          .aspectRatio(1)
          .draggable(false)
          .borderRadius(16)
          .margin({
            top: 8,
            right: 8,
          })
          .onClick(() => {
            this.videoUri = ''
            this.surfaceUrl = ''
            this.onValidate(this.isCanBack)
          })
      }

      .width(this.newsPostViewModel.getPostVideoWidth())
      .height(this.newsPostViewModel.getPostVideoHeight())
      .alignContent(Alignment.TopEnd)

      Image($r('app.media.ic_video_flag'))
        .width(32)
        .draggable(false)
    }
    .onClick(() => {
      RouterUtils.pushPathByName(RouterMap.Video_PREVIEW, this.videoUri)
    })
    .width(this.newsPostViewModel.getPostVideoWidth())
    .height(this.newsPostViewModel.getPostVideoHeight())
    .borderRadius(16)

  }

  async plusBtnClick() {
    const uriList = await MediaUtils.selectMedia({
      type: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
      maxLimit: 1,
      maxSize: 500,
    });
    this.videoUri = uriList[0]
    const thumbnail = await MediaUtils.getVideoThumbnail(uriList[0]);
    this.surfaceUrl = await MediaUtils.writePixelMap(thumbnail);
    this.onValidate(this.isCanBack)
  }

  @Builder
  videoUpload() {
    Column({ space: 32 }) {
      Column() {
        if (this.surfaceUrl) {
          this.videoBox(this.surfaceUrl)
        } else {
          Column() {
            Image($r('app.media.cover_plus'))
              .width(20)
              .height(20)
              .fillColor($r('sys.color.font_primary'))

          }
          .onClick(async () => {
            this.plusBtnClick()
          })
          .justifyContent(FlexAlign.Center)
          .width(this.newsPostViewModel.getPostVideoWidth())
          .height(this.newsPostViewModel.getPostVideoHeight())
          .borderRadius(8)
        }
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(8)
      .clip(true)
      .width(this.newsPostViewModel.getPostVideoWidth())
      .height(this.newsPostViewModel.getPostVideoHeight())

      Column({ space: 16 }) {
        TextArea({
          placeholder: '请添加描述（选填）',
          text: $$this.body,
        })
          .fontSize(16 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_tertiary'))
          .placeholderFont({ size: 16 * this.fontSizeRatio })
          .backgroundColor(Color.Transparent)
          .onChange((_value: string) => {
            this.onValidate(this.isCanBack)
          })
          .padding(0)
          .borderRadius(0)
          .constraintSize({
            maxHeight: 200,
          })
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    Column() {
      Column({ space: 16 }) {
        this.videoUpload()
      }

      Column() {
        Button('发布')
          .fontSize(16 * this.fontSizeRatio)
          .width(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            this.newsPostViewModel.publishVideo(this.surfaceUrl, this.videoUri, this.body)
          })
      }
      .position({ bottom: 32, left: 0 })
      .width(CommonConstants.FULL_PERCENT)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.newsPostViewModel.breakPointModel.pagePadding,
      right: this.newsPostViewModel.breakPointModel.pagePadding,
    })
  }
}