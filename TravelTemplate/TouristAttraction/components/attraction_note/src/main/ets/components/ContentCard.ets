/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { CommonConstant, EventEmitName } from '../constant/Index';
import { PostCardModel } from '../model/Index';
import { handleCount, handleImgSrc } from '../utils/Index';

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

  getHotNoteTypeName(tag: number): string {
    if (tag === 1) {
      return '最新';
    } else if (tag === 2) {
      return '最热';
    } else {
      return '';
    }
  }

  getHotNoteTypeBgColor(tag: number): ResourceStr {
    if (tag === 1) {
      return $r('sys.color.mask_tertiary');
    } else if (tag === 2) {
      return $r('sys.color.alert');
    } else {
      return '';
    }
  }

  build() {
    Stack() {
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

        Column() {
          if (this.data.title) {
            Text(this.data.title)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .width(CommonConstant.FULL_PERCENT)
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }

          Row({ space: 8 }) {
            Text(this.data.location)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1);
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.hand_thumbsup'))
                .width(16)
                .height(16)
                .fontSize(16)
                .fontColor([$r('sys.color.icon_secondary')]);
              Text(handleCount(this.data.likeNum))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_tertiary'));
            };
          }.width(CommonConstant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
        }.width(CommonConstant.FULL_PERCENT).padding(8);
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

      Row() {
        Text(this.getHotNoteTypeName(this.data.tag))
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Caption_M'));
      }
      .width(36)
      .height(16)
      .padding({
        left: 8,
        top: 1,
        right: 8,
        bottom: 1,
      })
      .borderRadius({
        topLeft: 8,
        topRight: 0,
        bottomRight: 8,
        bottomLeft: 0,
      })
      .backgroundColor(this.getHotNoteTypeBgColor(this.data.tag))
      .margin({ left: 2, top: 2 })
      .visibility(this.data.tag ? Visibility.Visible : Visibility.Hidden);
    }.align(Alignment.TopStart);

  }
}