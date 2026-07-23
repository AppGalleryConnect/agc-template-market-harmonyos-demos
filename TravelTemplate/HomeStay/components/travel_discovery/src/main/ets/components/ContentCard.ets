/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { CircleShape } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { PostCardModel } from '../model/Index';
import { handleCount, handleImgSrc } from '../utils/Index';
import { CommonConstant, EventEmitName, PageRouteName, StatusFLAG } from '../constant/Index';
import { cancelLikeTravelogue, likeTravelogue } from '../utils/ApiManage';

@ComponentV2
export struct ContentCard {
  @Param @Require data: PostCardModel;

  aboutToAppear(): void {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.on(EventEmitName.CHANGE_LIKED,
      (v: PostCardModel) => {
        if (this.data.id === v.id) {
          this.data.currentUserLikeStatus = v.currentUserLikeStatus;
          this.data.likeNum = v.likeNum;
        }
      });
  }

  getImage() {
    const imgList: string[] = this.data.images as string[];
    if (imgList.length) {
      return handleImgSrc(this.getUIContext().getHostContext()!, imgList[0]);
    }
    return '';
  }

  build() {
    Column({ space: 8 }) {
      if (this.getImage()) {
        Image(this.getImage())
          .width(CommonConstant.FULL_PERCENT)
          .objectFit(ImageFit.Contain)
          .interpolation(ImageInterpolation.High)
          .borderRadius(8)
          .autoResize(true)
          .syncLoad(true)
          .padding({ left: 12, right: 12 });
      }

      Column({ space: 8 }) {
        if (this.data.title) {
          Text(this.data.title)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(20)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }

        Row({ space: 4 }) {
          Image(handleImgSrc(this.getUIContext().getHostContext()!, this.data.publisherAvatar))
            .width(24)
            .height(24)
            .clipShape(new CircleShape({ width: 24, height: 24 }))
            .autoResize(true)
            .syncLoad(true);
          Text(this.data.publisher)
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .lineHeight(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1);
          Row({ space: 4 }) {
            Image(this.data.currentUserLikeStatus === StatusFLAG.YES ? $r('app.media.ic_public_like_filled') :
              $r('app.media.ic_public_like'))
              .width(16)
              .height(16)
              .objectFit(ImageFit.Contain)
              .autoResize(true)
              .syncLoad(true);
            Text(handleCount(this.data.likeNum))
              .fontSize(10)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(400)
              .lineHeight(14);
          }.onClick(() => {
            if (this.data.currentUserLikeStatus === StatusFLAG.YES) {
              cancelLikeTravelogue(this.data.id).then(() => {
                this.data.currentUserLikeStatus = StatusFLAG.NO;
                this.data.likeNum -= 1;
              });
            } else {
              likeTravelogue(this.data.id).then(() => {
                this.data.currentUserLikeStatus = StatusFLAG.YES;
                this.data.likeNum += 1;
              });
            }
          });
        }.width(CommonConstant.FULL_PERCENT);
      }
      .width(CommonConstant.FULL_PERCENT)
      .padding({ left: 8, right: 8 });
    }
    .width(CommonConstant.FULL_PERCENT)
    .backgroundColor($r('app.color.white'))
    .borderRadius(16)
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      this.getUIContext().getRouter().pushNamedRoute({ name: PageRouteName.PAGE_DETAIL, params: { id: this.data.id } })
        .catch((err: BusinessError) => {
          UtilLog.error(`pushNameRoute error ${err}`);
        });
    });
  }
}