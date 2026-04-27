import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, FormatCount, UserInfoModel } from 'lib_common';
import { Share, ShareContentType, ShareUtils } from 'lib_widget';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'module_imagepreview';
import { ArticleTextEllipsis } from './ArticleTextEllipsis';
import { FeedSingleImageSize } from './FeedSingleImageSize';
import { PostImgList, FeedCardInfoModel } from '../model/RecommendModel';
import { calculateDimensions, getColumnsTemplate, getDateDiff } from '../utils/Index';
import { ImagePreviewVM } from '../viewmodel/ImagePreviewVM';

/**
 * 动态中心内容
 */

const TAG = '[FeedDetail]';

@ComponentV2
export struct FeedDetail {
  @Require @Param componentId: string = ''
  @Require @Param curFeedCardInfo: FeedCardInfoModel
  @Require @Param isDynamicsSingleDetail: boolean
  @Param isAll: boolean = false
  @Param fontSizeRatio: number = 1
  @Param searchKey: string = ''
  @Param showUserBar: boolean = true;
  @Param showTimeBottom: boolean = false;
  @Param showImagePreviewLayer: boolean = true;
  @Param isWatch: boolean = false
  @Param isFeedSelf: boolean = false
  @BuilderParam followBuilderParam: () => void = this.followBuilder;
  @BuilderParam publishCustomTimeBuilder: () => void = this.publishTimeBuilder;
  @Event onGoUserInfo: (authorId: string) => void = () => {
  }
  @Event onAddWatch: () => void = () => {
  }
  @Event onAddLike: () => void = () => {
  }
  @Event onAddComment: () => void = () => {
  }
  @Event onVideo: () => void = () => {
  }
  @Local currentTextCount: number | undefined = undefined
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local clickedIndex: number = -1;
  @Local isFirstPageShow: boolean = true;
  @Local truncatedCount: number = 0
  @Local options: ImagePreviewOptions = new ImagePreviewOptions()
  @Local imagePreviewVM: ImagePreviewVM = new ImagePreviewVM()

  aboutToAppear(): void {
    this.imagePreviewVM.setCurFeedCardInfo(this.curFeedCardInfo)
    this.options
      .setSnapshotId((_item, index) => {
        return `${this.componentId}${this.curFeedCardInfo.id}${_item}${index}`
      })
      .setImageActionListener({
        onPageChanged: (_item, index) => {
          this.clickedIndex = index
        },
        onScale: () => {
          this.imagePreviewVM.isExpand = true
        },
        onLongPress: (index: number) => {
          new ShareUtils().openSheet(this.getUIContext(),
            {
              shareType: ShareContentType.IMAGE,
              imageUrl: this.curFeedCardInfo.postImgList?.[index].picVideoUrl,
              title: '',
            },
          );
        },
      })
      .setPreviewListener({
        onBack: () => {
          this.clickedIndex = -1
        },
      })
      .setCustomBuilder({
        topBuilder: () => {
          this.authorBuilder(this.imagePreviewVM)
        },
        bottomBuilder: () => {
          this.operationBuilder(this.imagePreviewVM)
        },
      })

  }

  @Computed
  get getAuthorIcon() {
    return this.isFeedSelf ? this.userInfoModel.authorIcon : this.curFeedCardInfo.author.authorIcon
  }

  @Computed
  get getAuthorName() {
    return this.isFeedSelf ? this.userInfoModel.authorNickName : this.curFeedCardInfo.author.authorNickName
  }

  @Computed
  get oneImageSize() {
    /*
     * 一张图的时候需要固定父容器高度
     * */
    return this.computeImageCount().length === 1 ?
      calculateDimensions(this.curFeedCardInfo.postImgList?.[0].surfaceUrl ?
        this.curFeedCardInfo.postImgList?.[0].surfaceUrl :
        this.curFeedCardInfo.postImgList?.[0].picVideoUrl).height : 'auto'
  }

  @Builder
  followBuilder() {
  };

  @Builder
  publishTimeBuilder() {
    if (this.isDynamicsSingleDetail) {
      Column() {
        Text(this.curFeedCardInfo.relativeTime)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
      }.width(CommonConstants.FULL_PERCENT).alignItems(HorizontalAlign.Start)
    }

  };

  @Builder
  authorBuilder(vm: ImagePreviewVM) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center }) {
        Row({ space: 4 }) {
          Image(this.curFeedCardInfo.author.authorIcon)
            .width(24 * vm.settingInfo.fontSizeRatio)
            .height(24 * vm.settingInfo.fontSizeRatio)
            .borderRadius(12 * vm.settingInfo.fontSizeRatio)
            .clip(true)
          Text(this.curFeedCardInfo.author.authorNickName)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(16 * vm.settingInfo.fontSizeRatio)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 'calc(100% - 44vp)' })
        }

        Row() {
          Text() {
            Span(vm.getWatch ? '已关注' : '关注')
          }
          .fontSize(14 * vm.settingInfo.fontSizeRatio)
          .fontColor(vm.getWatch ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
          .onClick(() => {
            this.onAddWatch()
          })
        }
        .width(72)
        .height(28)
        .margin({ left: 16 })
        .backgroundColor(vm.getWatch ? $r('sys.color.background_primary') : $r('app.color.app_theme'))
        .borderRadius(14)
        .justifyContent(FlexAlign.Center)
        .visibility(vm.isFeedSelf ? Visibility.None : Visibility.Visible)
      }

      Blank()

      Column() {
        Text(`${this.clickedIndex + 1} / ${this.curFeedCardInfo.postImgList?.length}`)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(12)
          .constraintSize({ minWidth: 50 })
          .textAlign(TextAlign.Center)
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(16)
      .padding(4)
    }
    .padding({
      left: this.imagePreviewVM.breakPointModel.pagePadding,
      right: this.imagePreviewVM.breakPointModel.pagePadding,
    })
    .visibility(vm.isExpand ? Visibility.None : Visibility.Visible)
    .margin({ top: 36 })

  }

  @Builder
  operationBuilder(vm: ImagePreviewVM) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Row() {
          Image(vm.isExpand ? $r('app.media.down') : $r('app.media.up')).width(17).height(9)
        }
        .width(24)
        .height(24)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Text(vm.isExpand ? '收起' : '展开').fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * vm.settingInfo.fontSizeRatio)
      }
      .onClick(() => {
        vm.toggleExpand()
      })

      Row({ space: 25 }) {
        Column({ space: 5 }) {
          Image($r('app.media.image_comment')).width(20).height(20)
          Text(this.curFeedCardInfo.commentCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * vm.settingInfo.fontSizeRatio)
        }
        .onClick(() => {
          ImagePreview.close()
          setTimeout(() => {
            this.onAddComment()
          }, 300)
        })

        Column({ space: 5 }) {
          Image(this.curFeedCardInfo.isLiked ? $r('app.media.like_active') :
            $r('app.media.preview_like'))
            .width(23)
            .height(20)
          Text(this.curFeedCardInfo.likeCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * vm.settingInfo.fontSizeRatio)
        }
        .onClick(() => {
          this.onAddLike()
        })

        this.shareBuilder(vm)
      }
      .visibility(!vm.isExpand ? Visibility.Visible : Visibility.None)
    }
    .padding({
      left: this.imagePreviewVM.breakPointModel.pagePadding,
      right: this.imagePreviewVM.breakPointModel.pagePadding,
      bottom: 28,
    })
  }

  @Builder
  shareBuilder(vm: ImagePreviewVM) {
    Share({
      shareData: {
        recordId: this.curFeedCardInfo.id,
        title: this.curFeedCardInfo.title,
        createTime: this.curFeedCardInfo.createTime,
        coverUrl: vm.handlerCoverImage,
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder(vm)
      },
    })
  }

  @Builder
  shareCommentBuilder(vm: ImagePreviewVM) {
    Column({ space: 5 }) {
      Image($r('app.media.image_forward'))
        .width(21)
        .height(21)
      Text(FormatCount.formatToK(this.curFeedCardInfo.shareCount))
        .fontSize(10 * vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  getImageList(value: PostImgList[]): SourceImageModel[] {
    if (!Array.isArray(value)) {
      return [];
    }

    return value.map((item: PostImgList) => {
      if (!item.surfaceUrl) {
        return new SourceImageModel({ imageUrl: item.picVideoUrl, videoUrl: item.movingVideoUrl });
      }
      return new SourceImageModel({ imageUrl: item.picVideoUrl, videoUrl: item.movingVideoUrl })
    });
  }

  onIndexChange(index: number): void {
    this.clickedIndex = index;
  }

  onBack(): void {
    this.isFirstPageShow = true;
  }

  computeImageCount() {
    if (!this.curFeedCardInfo.postImgList) {
      return []
    }
    const rules = new Map([
      [5, 4], // 5张时保留4张
      [6, 6], // 6张时保留6张
      [7, 6], // 7张时保留6张
      [8, 6], // 8张时保留6张
      [9, 9],// 9张时保留9张
    ]);
    const originalCount = this.curFeedCardInfo.postImgList.length;
    const count = Math.min(originalCount, 9);
    const keepCount = rules.get(count) ?? count;
    this.truncatedCount = originalCount - keepCount;
    return this.curFeedCardInfo.postImgList.slice(0, keepCount);
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.getAuthorIcon || $r('app.media.icon_default'))
              .alt($r('app.media.icon_default'))
              .width(40)
              .height(40)
              .borderRadius('50%')
              .clip(true)
              .accessibilityText(this.getAuthorName + '头像')
              .onClick(() => {
                this.onGoUserInfo(this.curFeedCardInfo.author.authorId)
              })
          }

          Column({ space: 8 }) {
            Text(this.getAuthorName)
              .fontColor($r('sys.color.font_primary'))
              .fontSize(14 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .constraintSize({
                maxWidth: 'calc(100% - 48vp)',
              })
            this.publishCustomTimeBuilder()
          }.alignItems(HorizontalAlign.Start)
        }
        .flexGrow(1)

        this.followBuilderParam()
      }
      .margin({
        bottom: 12,
      })
      .visibility(this.showUserBar ? Visibility.Visible : Visibility.None)

      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          ArticleTextEllipsis({
            text: this.curFeedCardInfo.title,
            fontSizeRatio: this.fontSizeRatio,
            isAll: this.isAll,
            searchKey: this.searchKey,
          })
        }.width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .accessibilityLevel('yes')
      .accessibilityText(this.curFeedCardInfo.title)

      Column() {
        Grid() {
          ForEach(this.computeImageCount(),
            (item: PostImgList, index: number) => {
              GridItem() {
                Column() {
                  FeedSingleImageSize({
                    index: index,
                    clickedIndex: this.clickedIndex,
                    curFeedCardInfo: this.curFeedCardInfo,
                    componentId: this.componentId,
                    isLast: this.computeImageCount().length - 1 === index,
                    truncatedCount: this.truncatedCount,
                    postImgListItem: item,
                    onImageClick: () => {
                      this.options
                        .setImageList(this.getImageList(this.curFeedCardInfo.postImgList!))
                        .setInitIndex(index)
                        .setShowIndicator(false)
                      ImagePreview.open(this.getUIContext(), this.options)
                    },
                    onVideo: () => {
                      this.onVideo()
                    },
                  })
                }
                .visibility(index === this.clickedIndex ? Visibility.Hidden : Visibility.Visible)
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .height(this.oneImageSize)
              }
            }, (item: PostImgList) => JSON.stringify(item))
        }
        .columnsTemplate('1fr '.repeat(getColumnsTemplate(this.computeImageCount().length ?? 0)))
        .columnsGap(8)
      }

      if (this.showTimeBottom) {
        Column() {
          Text(getDateDiff(this.curFeedCardInfo?.createTime))
            .fontSize(12 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8 })
      }
    }
  }
}