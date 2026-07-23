import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';
import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { Constant, CustomShareParams, RouteModel } from 'module_base';
import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';
import { CommonConstant, EventEmitName, StatusFLAG } from '../constant/Index';
import { CommentModel, PostDetailModel, RouteParam } from '../model/Index';
import {
  cancelFavorTravelogue,
  cancelLikeTravelogue,
  commentTravelogue,
  favorTravelogue,
  likeTravelogue,
  queryRouteLineDetail,
  queryTravelogueDetail,
  recordBrowse,
} from '../utils/ApiManage';
import { handleCount, handleImgSrc, handleTimeFormat } from '../utils/Index';

const COMMENT_AREA_ID = 'CommentArea';
const ASPECT_RADIO_DEFAULT = 3 / 4;

@Builder
export function PageDetailBuilder() {
  PageDetail();
}

@ComponentV2
export struct PageDetail {
  // 游记ID
  @Local travelId: number = 0;
  @Local data: PostDetailModel = new PostDetailModel();
  @Local route: RouteModel = new RouteModel();
  @Local isEditComment: boolean = false;
  @Local isCommentInputFocused: boolean = false;
  @Local commentEditValue: string = '';
  @Local aspectRatioSwiper: number = ASPECT_RADIO_DEFAULT;
  @Local imgAspectRadioList: number[] = [];
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local instance: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Local breakpoint: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();
  private scrollerRight: Scroller = new Scroller();
  private contentH: number = 0;
  options: ImagePreviewOptions = new ImagePreviewOptions();

  @Computed
  get imageMargin() {
    if (this.breakpoint === BreakpointNameEnum.LG || this.breakpoint === BreakpointNameEnum.XL) {
      return GridRowColSetting.getPageMargin(this.breakpoint);
    }
    return 0;
  }

  changeLiked: () => void = () => {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.CHANGE_LIKED,
      this.data);
  };

  @Monitor('imgAspectRadioList')
  aspectRadioListChange(monitor: IMonitor) {
    this.imgAspectRadioList = monitor.value()?.now as number[];
    if (this.imgAspectRadioList.length === 0) {
      return;
    }

    const powList: number[] = this.imgAspectRadioList.map(v => Math.pow(v - 1, 2));
    let minV: number = powList[0];
    let minVIndex: number = 0;
    for (let index = 1; index < powList.length; index++) {
      const element = powList[index];
      if (element < minV) {
        minV = element;
        minVIndex = index;
      }
    }

    let finalRadio = this.imgAspectRadioList[minVIndex];
    if (finalRadio <= 2 && finalRadio >= ASPECT_RADIO_DEFAULT) {
      this.aspectRatioSwiper = finalRadio;
    } else {
      this.aspectRatioSwiper = ASPECT_RADIO_DEFAULT;
    }
  }

  queryDetail() {
    return queryTravelogueDetail(this.travelId).then((resp: ESObject) => {
      this.data = new PostDetailModel(resp.data);
      if (this.data.routeId) {
        queryRouteLineDetail(this.data.routeId).then((resp: ESObject) => {
          this.route = new RouteModel(resp.data);
        });
      }
    }).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
    });
  }

  postComment() {
    commentTravelogue(this.travelId, this.commentEditValue).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.comment_success_msg') });
      this.commentEditValue = '';
      this.isEditComment = false;
      this.queryDetail();
    }).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
    });
  }

  @Builder
  buildContent() {
    Column({ space: 16 }) { // 帖子图片
      Image(handleImgSrc(this.getUIContext().getHostContext()!, this.data.images[0]))
        .height(202)
        .width(CommonConstant.FULL_PERCENT)
        .objectFit(ImageFit.Fill)
        .constraintSize({ maxWidth: '100%' })
        .margin({ left: this.imageMargin, right: this.imageMargin })
        .id(this.options.snapshotId(handleImgSrc(this.getUIContext().getHostContext()!, this.data.images[0]), 0))
        .onClick(() => {
          this.options
            .setImageList([new SourceImageModel(
              { imageUrl: handleImgSrc(this.getUIContext().getHostContext()!, this.data.images[0]) })])
            .setInitIndex(0);
          ImagePreview.open(this.getUIContext(), this.options);
        });
      Column({ space: 16 }) { // 帖子标题
        Text(this.data.title)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary')); // 帖子内容
        Text(this.data.content).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));

        // 发表时间
        Text(handleTimeFormat(this.data.publishTime))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));

      }.padding({
        left: GridRowColSetting.getPageMargin(this.breakpoint), right: GridRowColSetting.getPageMargin(this.breakpoint),
      }).alignItems(HorizontalAlign.Start);
    }.alignItems(HorizontalAlign.Start).onAreaChange((o, n) => {
      this.contentH = n.height as number;
    });
  }

  @Builder
  buildComment() {
    Column() {
      Text($r('app.string.total_comment_desc', (this.data.commentNum || 0).toString()))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 16 });
      if (this.data.travelogueEvaluateList.length) {
        List({ space: 16 }) {
          ForEach(this.data.travelogueEvaluateList, (v: CommentModel) => {
            ListItem() {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Image(handleImgSrc(this.getUIContext().getHostContext()!, v.userHeadImg) || $r('app.media.user'))
                    .width(16)
                    .height(16)
                    .clipShape(new CircleShape({ width: 16, height: 16 }));

                  Text(v.createBy || $r('app.string.comment_user_name_default'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                };

                Text(v.evaluateContent)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: 24 });
                Text(handleTimeFormat(v.createTime))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_tertiary'))
                  .margin({ left: 24 });
              }.alignItems(HorizontalAlign.Start).width(CommonConstant.FULL_PERCENT);
            };
          }, (v: CommentModel) => v.createTime.toString());
        }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST,
        });
      } else {
        Column() {
          Image($r('app.media.ic_empty')).width(120).aspectRatio(1);
        }
        .width(Constant.FULL_PERCENT)
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center);
      }
    }.id(COMMENT_AREA_ID).padding({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
      right: GridRowColSetting.getPageMargin(this.breakpoint),
      bottom: 3,
    }).width(CommonConstant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
  }

  @Builder
  buildBottomBar() {
    Row({ space: 8 }) {
      TextInput({ text: $$this.commentEditValue, placeholder: '发表评论' })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#F2F2F2')
        .onFocus(() => {
          this.isCommentInputFocused = true;
        })
        .onBlur(() => {
          this.isCommentInputFocused = false;
        })
        .onSubmit(() => {
          this.postComment();
        });
      if (!this.isCommentInputFocused) {
        Row({ space: 8 }) {
          Column({ space: 2 }) {
            if (this.data.currentUserLikeStatus === StatusFLAG.YES) {
              SymbolGlyph($r('sys.symbol.hand_thumbsup_fill'))
                .width(24)
                .height(24)
                .fontSize(24)
                .fontColor([$r('sys.color.multi_color_08')]);
            } else {
              SymbolGlyph($r('sys.symbol.hand_thumbsup'))
                .width(24)
                .height(24)
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')]);
            }

            Text(handleCount(this.data.likeNum))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_primary'));
          }.width(40).height(40).onClick(() => {
            if (this.data.currentUserLikeStatus === StatusFLAG.YES) {
              cancelLikeTravelogue(this.travelId).then(() => {
                this.data.currentUserLikeStatus = StatusFLAG.NO;
                this.data.likeNum -= 1;
                this.data.commentNum = this.data.travelogueEvaluateList.length;
                this.changeLiked();
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
              });
            } else {
              likeTravelogue(this.travelId).then(() => {
                this.data.currentUserLikeStatus = StatusFLAG.YES;
                this.data.likeNum += 1;
                this.data.commentNum = this.data.travelogueEvaluateList.length;
                this.changeLiked();
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
              });
            }
          });

          Column({ space: 2 }) {
            Image(this.data.currentUserCollectStatus === StatusFLAG.YES ? $r('app.media.ic_public_mark_filled') :
              $r('app.media.ic_public_favourites')).width(24).height(24).objectFit(ImageFit.Contain);
            Text(handleCount(this.data.collectNum))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_primary'));
          }.width(40).height(40).onClick(() => {
            if (this.data.currentUserCollectStatus === StatusFLAG.YES) {
              cancelFavorTravelogue(this.travelId).then(() => {
                this.data.currentUserCollectStatus = StatusFLAG.NO;
                this.data.collectNum -= 1;
                this.data.commentNum = this.data.travelogueEvaluateList.length;
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
              });
            } else {
              favorTravelogue(this.travelId).then(() => {
                this.data.currentUserCollectStatus = StatusFLAG.YES;
                this.data.collectNum += 1;
                this.data.commentNum = this.data.travelogueEvaluateList.length;
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
              });
            }
          });

          Column({ space: 2 }) {
            Image($r('app.media.ic_public_message'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
              .fillColor($r('app.color.grey_level_9'));
            Text(handleCount(this.data.commentNum || 0))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_primary'));
          }.width(40).height(40).onClick(() => {
            UtilLog.debug('this.contentH=' + this.contentH);
            if (this.scroller.currentOffset().yOffset >= this.contentH) {
              this.isEditComment = true;
              return;
            }
            this.scroller.scrollTo({ xOffset: 0, yOffset: this.contentH });
          });
        };
      } else {
        Image($r('app.media.ic_send')).width(40).margin({ left: 4 }).onClick(() => {
          if (!this.commentEditValue) {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.comment_null_msg') });
            return;
          }
          this.postComment();
        });
      }
    }.width(CommonConstant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).padding({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
      right: GridRowColSetting.getPageMargin(this.breakpoint),
      top: 8,
      bottom: 8 + this.windowBottomHeight,
    });
  }

  @Builder
  buildRoute() {
    if (this.data.routeId) {
      Row({ space: 12 }) {
        Image(this.route.routeBanner).size({ width: 56, height: 56 }).borderRadius(8).clip(true);

        Column({ space: 4 }) {
          Text(this.route.routeName)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium);
          Text(
            `${this.route.attractionIds.length}个景点，全程${this.route.routeDistance}公里，大约需${this.route.duration}小时`)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'));
        }.alignItems(HorizontalAlign.Start).height(56);
      }
      .padding(12)
      .width('100%')
      .margin({
        top: 21,
        left: GridRowColSetting.getPageMargin(this.breakpoint),
        right: GridRowColSetting.getPageMargin(this.breakpoint),
      })
      .constraintSize({ maxWidth: '100%' })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .onClick(() => {
        this.mainPathStack.pushPathByName('RoutePageDetail',
          { route: this.route, attractionIds: this.route.attractionIds } as RouteParam);
      });
    }
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .width(40)
                .height(40)
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')])
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius(1000)
                .padding(8)
                .onClick(() => {
                  this.mainPathStack.pop();
                });
            }.margin({ top: this.windowTopHeight }).width('100%').padding({
              top: 8,
              bottom: 8,
              left: GridRowColSetting.getPageMargin(this.breakpoint),
              right: GridRowColSetting.getPageMargin(this.breakpoint),
            });

            if (this.breakpoint === BreakpointNameEnum.LG || this.breakpoint === BreakpointNameEnum.XL) {
              Row({ space: 32 }) {
                Scroll(this.scroller) {
                  Column() {
                    this.buildContent();
                    this.buildRoute();
                  };
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .layoutWeight(1)
                .height('100%');

                Divider().vertical(true).height('100%').color($r('sys.color.comp_divider'));
                Scroll(this.scrollerRight) {
                  Column() {
                    this.buildComment();
                  };
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .layoutWeight(1)
                .height('100%');
              }.layoutWeight(1);
            } else {
              Scroll(this.scroller) {
                Column() {
                  this.buildContent();
                  this.buildRoute();
                  Row()
                    .width(CommonConstant.FULL_PERCENT)
                    .height(8)
                    .backgroundColor($r('sys.color.background_secondary'))
                    .margin({ top: 16 });
                  this.buildComment();
                };
              }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);
            }
            this.buildBottomBar();
          }.height(CommonConstant.FULL_PERCENT).width(CommonConstant.FULL_PERCENT);
        };
      }.onBreakpointChange((bp) => {
        this.breakpoint = bp;
      });
    }.hideTitleBar(true).onReady(async (context: NavDestinationContext) => {
      this.travelId = context.pathInfo.param as number;
      recordBrowse(this.travelId);
      await this.queryDetail(); // 华为分享
      this.instance.pageName = 'PageDetail';
      this.instance.goodId = this.travelId;
      this.instance.goodName = this.data.title;
    });
  }
}
