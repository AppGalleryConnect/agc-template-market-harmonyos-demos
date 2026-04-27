/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { CircleShape } from '@kit.ArkUI';
import { PostCardModel } from '../model/Index';
import { handleCount, handleImgSrc } from '../utils/Index';
import { CommonConstant, EventEmitName, StatusFLAG } from '../constant/Index';
import { cancelLikeTravelogue, likeTravelogue } from '../utils/ApiManage';

@ComponentV2
export struct ContentCard {
  @Param @Require data: PostCardModel;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private JUDGE_NET_TAG: string = 'this.currNet.isUseful';

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
    Column({ space: 10 }) {
      if (this.getImage()) {
        Image(AppStorage.get(this.JUDGE_NET_TAG) === true ? this.getImage() : $r('app.media.noImage'))
          .width(CommonConstant.FULL_PERCENT)
          .objectFit(ImageFit.Contain)
          .interpolation(ImageInterpolation.High)
          .borderRadius({ topLeft: 8, topRight: 8 })
          .autoResize(true)
          .syncLoad(true);
      }

      Column({ space: 8 }) {
        if (this.data.title) {
          Text(this.data.title)
            .fontSize(14)
            .fontColor($r('app.color.grey_level_9'))
            .fontWeight(500)
            .lineHeight(20)
            .maxLines(2)
            .width(CommonConstant.FULL_PERCENT)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }

        Row({ space: 4 }) {
          Image(handleImgSrc(this.getUIContext().getHostContext()!, this.data.publisherAvatar))
            .width(18)
            .height(18)
            .clipShape(new CircleShape({ width: 18, height: 18 }))
            .autoResize(true)
            .syncLoad(true);
          Text(this.data.publisher)
            .fontSize(10)
            .fontColor($r('app.color.grey_level_4'))
            .fontWeight(400)
            .lineHeight(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 2, right: 10 })
            .layoutWeight(1);
          Blank();
          Row({ space: 3 }) {
            Image(this.data.currentUserLikeStatus === StatusFLAG.YES ? $r('app.media.ic_public_like_filled') :
              $r('app.media.ic_public_like'))
              .width(12)
              .height(12)
              .objectFit(ImageFit.Contain)
              .autoResize(true)
              .syncLoad(true);
            Text(handleCount(this.data.likeNum))
              .fontSize(10)
              .fontColor($r('app.color.grey_level_6'))
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
      .padding({
        left: 10,
        right: 20,
        top: 6,
        bottom: 6,
      });
    }
    .width(CommonConstant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius($r('app.float.card_radius'))
    .onClick(() => {
      let list = this.mainPathStack.getIndexByName('PageDetail');
      if (!list.length) {
        this.mainPathStack.pushPathByName('PageDetail', this.data.id);
      }
    });
  }
}