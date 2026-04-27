import { taskpool } from '@kit.ArkTS';
import { Logger } from 'lib_common';
import { PostImgList, FeedCardInfoModel } from '../model/RecommendModel';
import { calculateImageSize, FeedImageModifier, SendableImageCalcData } from '../utils/FeedImageModifier';


/*
 * 单张图片的展示
 * */

const TAG = '[FeedSingleImageSize]';

@ComponentV2
export struct FeedSingleImageSize {
  @Require @Param componentId: string = ''
  @Require @Param curFeedCardInfo: FeedCardInfoModel
  @Require @Param postImgListItem: PostImgList
  @Param clickedIndex: number = -1;
  @Param index: number = 0
  @Param isLast: boolean = false
  @Param truncatedCount: number = 0
  @Event onVideo: () => void = () => {
  }
  @Event onImageClick: () => void = () => {
  }
  @Local imageModifier: FeedImageModifier | undefined = undefined;

  async aboutToAppear() {
    /**
     * 子线程计算图片大小等相关信息
     * */
    try {
      const calcData = SendableImageCalcData.fromFeedCardInfo(this.curFeedCardInfo);
      const task = new taskpool.Task(calculateImageSize, calcData);
      const result = await taskpool.execute(task) as SendableImageCalcData;
      this.imageModifier = new FeedImageModifier(result);
    } catch (e) {
      Logger.error(TAG, 'an error occurred on the taskpool.' + JSON.stringify(e))
    }
  }

  @Computed
  get getImageRestPosition() {
    return this.truncatedCount > 0 && this.isLast
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.postImgListItem.picVideoUrl)
            .attributeModifier(this.imageModifier)
            .objectFit(ImageFit.Cover)
            .autoResize(true)
            .visibility(this.postImgListItem.surfaceUrl ? Visibility.None : Visibility.Visible)
            .borderRadius(12)
            .id(`${this.componentId}${this.curFeedCardInfo.id}${this.postImgListItem.picVideoUrl}${this.index}`)
            .clip(true)
            .onClick(() => {
              this.onImageClick()
            })
          Column() {
            Text(`+ ${this.truncatedCount}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .margin({ right: 8, bottom: 8 })
          .visibility(this.getImageRestPosition ? Visibility.Visible : Visibility.None)
        }

        Stack() {
          Image(this.postImgListItem.surfaceUrl).objectFit(ImageFit.Cover)
            .borderRadius(12)
            .clip(true)
            .attributeModifier(this.imageModifier)
          Image($r('app.media.playBtn')).width(36)
            .height(36)
        }
        .visibility(this.postImgListItem.surfaceUrl ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.onVideo()
        })
      }
    }
    .clipShape(new Rect({ width: '100%', height: '100%', radius: 12 }))
    .margin({ top: 8 })
  }
}