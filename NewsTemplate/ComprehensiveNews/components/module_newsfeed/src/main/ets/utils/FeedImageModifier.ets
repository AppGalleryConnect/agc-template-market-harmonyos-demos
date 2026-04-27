import { collections } from '@kit.ArkTS'
import { FeedCardInfoModel } from '../model/RecommendModel'
import { calculateDimensions } from './Index'

@Sendable
export class FeedImageModifier implements AttributeModifier<ImageAttribute | ColumnAttribute> {
  private imageWidth: number = 0;
  private imageHeight: number = 0;
  private imageCount: number = 0;

  constructor(imageCalcData: SendableImageCalcData) {
    this.imageWidth = imageCalcData.imageWidth;
    this.imageHeight = imageCalcData.imageHeight;
    this.imageCount = imageCalcData.getImageCount();
  }

  applyNormalAttribute(instance: ImageAttribute | ColumnAttribute): void {
    if (this.imageCount === 1) {
      instance.width(this.imageWidth);
      instance.height(this.imageHeight);
    } else {
      instance.aspectRatio(1);
    }
  }
}


@Sendable
export class SendableImageItem {
  surfaceUrl: string = '';
  picVideoUrl: string = '';

  constructor(surfaceUrl: string = '', picVideoUrl: string = '') {
    this.surfaceUrl = surfaceUrl;
    this.picVideoUrl = picVideoUrl;
  }
}


@Sendable
export class SendableImageCalcData {
  postImgList: collections.Array<SendableImageItem> = new collections.Array<SendableImageItem>();
  imageWidth: number = 0;
  imageHeight: number = 0;

  static fromFeedCardInfo(feedCardInfo: FeedCardInfoModel): SendableImageCalcData {
    const data = new SendableImageCalcData();
    if (feedCardInfo.postImgList) {
      for (const img of feedCardInfo.postImgList) {
        data.postImgList.push(new SendableImageItem(
          img.surfaceUrl ?? '',
          img.picVideoUrl ?? ''
        ));
      }
    }
    return data;
  }

  // 获取图片数量
  getImageCount(): number {
    return this.postImgList.length;
  }

  // 获取第一张图片的 URL
  getFirstImageUrl(): string {
    if (this.postImgList.length > 0) {
      const first = this.postImgList[0];
      return first.surfaceUrl || first.picVideoUrl;
    }
    return '';
  }
}

@Concurrent
export function calculateImageSize(data: SendableImageCalcData): SendableImageCalcData {
  if (data.getImageCount() === 1) {
    const imageUrl = data.getFirstImageUrl();
    if (imageUrl) {
      const dimensions = calculateDimensions(imageUrl);
      data.imageWidth = dimensions.width;
      data.imageHeight = dimensions.height;
    }
  }
  return data;
}