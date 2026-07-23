import { common } from '@kit.AbilityKit';
import { CircleShape } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { CommonHeader } from 'component';
import { SharePicker, ShareRecordData, ShareContentType } from 'aggregated_share';
import { StatusFLAG } from '../constant/Index';
import { CommonConstant, EventEmitName, PageRouteName } from '../constant/Index';
import { CommentModel, FindModule, PostDetailModel } from '../model/Index';
import { handleCount, handleImgSrc, handleTimeFormat } from '../utils/Index';
import {
  queryTravelogueDetail,
  recordBrowse,
  likeTravelogue,
  cancelLikeTravelogue,
  favorTravelogue,
  cancelFavorTravelogue,
  commentTravelogue,
  likeComment,
  cancelLikeComment,
} from '../utils/ApiManage';

const COMMENT_AREA_ID = 'CommentArea';
const ASPECT_RADIO_DEFAULT = 3 / 4;

@Entry({ routeName: PageRouteName.PAGE_DETAIL })
@ComponentV2
export struct PageDetail {
  // 游记ID
  @Local travelId: number = 0;
  @Local data: PostDetailModel = new PostDetailModel();
  @Local commentList: CommentModel[] = [];
  @Local isEditComment: boolean = false;
  @Local commentEditValue: string = '';
  @Local commentEditValueCopy: string = '';
  @Local aspectRatioSwiper: number = ASPECT_RADIO_DEFAULT;
  @Local imgAspectRadioList: number[] = [];
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  private scroller: Scroller = new Scroller();
  private contentH: number = 0;
  changeLiked: () => void = () => {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.CHANGE_LIKED,
      this.data);
  };

  @Monitor('data.travelogueEvaluateList')
  onValueChange(monitor: IMonitor) {
    let curValue: CommentModel[] = monitor.value()?.now as CommentModel[];
    this.data.travelogueEvaluateList = curValue;
    this.commentList = [...curValue];
  }

  async aboutToAppear() {
    const params: ESObject = this.getUIContext().getRouter().getParams();
    this.travelId = params.id;
    recordBrowse(this.travelId);
    await this.queryDetail();
  }

  queryDetail() {
    return queryTravelogueDetail(this.travelId).then((resp: ESObject) => {
      this.data = new PostDetailModel(resp.data);
      this.commentList = [...this.data.travelogueEvaluateList];
    }).catch(() => {
      ToastDialog.showToast({ message: '请求失败，请联网重试' });
    });
  }

  private share() {
    const imgList: string[] = this.data.images as string[];
    const context = this.getUIContext().getHostContext()!;
    const coverUrl = imgList.length ? handleImgSrc(context, imgList[0]) : '';

    const record: ShareRecordData = {
      title: this.data.title,
      subTitle: this.data.content,
      coverUrl: coverUrl,
      shareType: ShareContentType.LINK,
    };

    const picker = new SharePicker(record);
    picker.show(this.getUIContext());
  }

  onListChange() {
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

  @Builder
  buildTitle() {
    CommonHeader({
      title: '游记详情',
      showBackButton: true,
      backButtonClick: () => {
        this.getUIContext().getRouter().back();
      },
    });
  }

  @Builder
  buildFindItem(v: FindModule) {
    Row() {
      Image(v.img).width(24).height(24).objectFit(ImageFit.Contain);
      Text(v.label).fontSize(14).fontColor($r('app.color.grey_level_9')).fontWeight(500).margin({ left: 12 });
      Blank();
      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('app.color.grey_level_6'))
        .width(16)
        .height(16);
    }
    .borderRadius(8)
    .backgroundColor($r('app.color.find_item_bg'))
    .width(CommonConstant.FULL_PERCENT)
    .padding(12)
    .onClick(() => {
      if (v.isOpenApp) {
        let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

        try {
          context.openLink(v.targetUrl, {
            appLinkingOnly: false,
          }).then(() => {
            console.info('open link success.');
          }).catch((err: BusinessError) => {
            console.error(`open link failed. Code is ${err.code}, message is ${err.message}`);
          });
        } catch (paramError) {
          console.error(`Failed to start link. Code is ${paramError.code}, message is ${paramError.message}`);
        }
      } else {
        this.getUIContext().getRouter().pushNamedRoute({ name: v.targetUrl, params: v })
          .catch((err: BusinessError) => {
            UtilLog.error(`pushNameRoute error ${err}`);
        });
      }
    });
  }

  @Builder
  buildContent() {
    Column({ space: 12 }) {
      Column({ space: 10 }) {
        Text(this.data.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(28);
        Row({ space: 10 }) {
          Image(handleImgSrc(this.getUIContext().getHostContext()!, this.data.publisherAvatar))
            .width(40)
            .height(40)
            .clipShape(new CircleShape({ width: 40, height: 40 }));
          Column({ space: 2 }) {
            Text(this.data.publisher)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            Text(handleTimeFormat(this.data.publishTime))
              .fontSize(12)
              .fontColor($r('sys.color.font_tertiary'));
          }.alignItems(HorizontalAlign.Start);
        }.alignItems(VerticalAlign.Center);
      }.padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start);

      Swiper() {
        Repeat<string>(this.data.images as string[]).each((repeatItem: RepeatItem<string>) => {
          Image(handleImgSrc(this.getUIContext().getHostContext()!, repeatItem.item))
            .height(184)
            .width(CommonConstant.FULL_PERCENT)
            .borderRadius(16)
            .objectFit(ImageFit.Cover)
            .onComplete((event) => {
              if (event?.loadingStatus !== 0) {
                return;
              }
              if (event?.width && event?.height) {
                this.imgAspectRadioList.push(event.width / event.height);
              }
            });
        }).key((item: string, index: number) => item).virtualScroll();
      }
      .cachedCount(3)
      .width(CommonConstant.FULL_PERCENT)
      .height(184)
      .autoPlay(false)
      .loop(false)
      .padding({ left: 16, right: 16 })
      .indicator(
        new DotIndicator()
          .itemWidth(6)
          .selectedItemWidth(12)
          .color($r('sys.color.icon_secondary'))
          .selectedColor($r('sys.color.icon_on_primary'))
          .bottom(0),
      );

      Column({ space: 12 }) {
        Text(this.data.content)
          .fontSize(14)
          .fontWeight(400)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(20);

        if (this.data?.relatedModules?.length) {
          Column({ space: 4 }) {
            ForEach(this.data.relatedModules, (v: FindModule) => {
              this.buildFindItem(v);
            }, (v: FindModule) => v.targetUrl);
          };
        }

        Text('未经许可，请勿转载使用')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'));
      }.padding({ left: 16, right: 16, bottom: 16 }).alignItems(HorizontalAlign.Start);
    }
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((o, n) => {
      this.contentH = n.height as number;
    });
  }

  @Builder
  buildComment() {
    Column() {
      Row() {
        Text(`评论·${this.data.commentNum || 0}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
      }
      .width(CommonConstant.FULL_PERCENT)
      .padding({ bottom: 16 });
      List() {
        Repeat<CommentModel>(this.commentList).each((repeatItem: RepeatItem<CommentModel>) => {
          ListItem() {
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Image(handleImgSrc(this.getUIContext().getHostContext(), repeatItem.item.userHeadImg) || $r('app.media.user'))
                  .width(16)
                  .height(16)
                  .clipShape(new CircleShape({ width: 16, height: 16 }));
                Text(repeatItem.item.createBy || $r('app.string.comment_user_name_default'))
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(400)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              Column({ space: 8 }) {
                Text(repeatItem.item.evaluateContent)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(400)
                  .lineHeight(20);
                Row() {
                  Text(handleTimeFormat(repeatItem.item.createTime))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_tertiary'))
                    .fontWeight(400);
                  Text('回复')
                    .fontSize(12)
                    .fontColor($r('sys.color.font_tertiary'))
                    .fontWeight(400)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.isEditComment = true;
                    });
                  Blank();
                  Image(repeatItem.item.likeStatus === StatusFLAG.YES ?
                    $r('app.media.ic_public_good_filled') : $r('app.media.ic_public_good'))
                    .width(16)
                    .height(16)
                    .objectFit(ImageFit.Contain)
                    .onClick(() => {
                      const index = this.commentList.indexOf(repeatItem.item);
                      if (index === -1) {
                        return;
                      }
                      const curItem = repeatItem.item;
                      const item = new CommentModel();
                      item.id = curItem.id;
                      item.createBy = curItem.createBy;
                      item.createTime = curItem.createTime;
                      item.evaluateContent = curItem.evaluateContent;
                      item.userHeadImg = curItem.userHeadImg;
                      if (curItem.likeStatus === StatusFLAG.YES) {
                        item.likeStatus = StatusFLAG.NO;
                        item.likeNum = curItem.likeNum - 1;
                      } else {
                        item.likeStatus = StatusFLAG.YES;
                        item.likeNum = curItem.likeNum + 1;
                      }
                      const newList = [...this.commentList];
                      newList[index] = item;
                      this.commentList = newList;
                      this.data.travelogueEvaluateList = newList;
                      const apiCall: Promise<ESObject> = curItem.likeStatus === StatusFLAG.YES
                        ? cancelLikeComment(curItem.id)
                        : likeComment(curItem.id);
                      apiCall.catch(() => {
                        ToastDialog.showToast({ message: '请求失败，请联网重试' });
                      });
                    });
                  Text(handleCount(repeatItem.item.likeNum))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_tertiary'))
                    .fontWeight(400)
                    .margin({ left: 4 });
                }.width(CommonConstant.FULL_PERCENT);
              }.margin({ left: 24 }).alignItems(HorizontalAlign.Start);
            }.alignItems(HorizontalAlign.Start).width(CommonConstant.FULL_PERCENT).padding({ bottom: 12 });
          };
        }).key((item: CommentModel, index: number) => `${item.createTime}_${index}`).virtualScroll();
      }.scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      });

      Row() {
        Row({ space: 1 }) {
          ForEach([1, 2, 3, 4], () => {
            Divider().width(4).height(1);
          }, (item: number) => item.toString());
        };

        Text($r('app.string.comment_history_end'))
          .fontSize(10)
          .fontColor($r('app.color.grey_level_4'))
          .fontWeight(400)
          .lineHeight(14)
          .margin({ left: 6, right: 6 });

        Row({ space: 1 }) {
          ForEach([1, 2, 3, 4], () => {
            Divider().width(4).height(1);
          }, (item: number) => item.toString());
        };
      }.margin({ top: 12 }).width(CommonConstant.FULL_PERCENT).justifyContent(FlexAlign.Center);
    }
    .id(COMMENT_AREA_ID)
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 30,
    })
    .width(CommonConstant.FULL_PERCENT)
    .height(CommonConstant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start);
  }

  postComment() {
    commentTravelogue(this.travelId, this.commentEditValueCopy).then(() => {
      ToastDialog.showToast({ message: '评论成功，待审核通过后展示' });
      this.commentEditValueCopy = '';
      this.isEditComment = false;
    }).catch(() => {
      ToastDialog.showToast({ message: '请求失败，请联网重试' });
    });
  }

  @Builder
  buildInputSheet() {
    Row({ space: 10 }) {
      TextInput({ text: $$this.commentEditValueCopy })
        .height(40)
        .layoutWeight(1)
        .defaultFocus(true)
        .onChange(() => {
          this.commentEditValue = this.commentEditValueCopy;
        })
        .onSubmit(() => {
          this.postComment();
        });
      Button('发送').onClick(() => {
        if (!this.commentEditValueCopy) {
          ToastDialog.showToast({ message: '评论内容不可为空！' });
          return;
        }
        this.postComment();
      });
    }.width(CommonConstant.FULL_PERCENT).padding(20);

  }

  @Builder
  buildBottomBar() {
    Row({ space: 8 }) {
      TextInput({ placeholder: '发表评论', text: this.commentEditValue })
        .focusable(false)
        .layoutWeight(1)
        .height(40)
        .borderRadius(24)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: 500 })
        .onClick(() => {
          this.isEditComment = true;
        })
        .bindSheet($$this.isEditComment, this.buildInputSheet(), {
          preferType: SheetType.CENTER,
          height: SheetSize.FIT_CONTENT,
          showClose: false,
        });

      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Image(this.data.currentUserLikeStatus === StatusFLAG.YES ? $r('app.media.ic_public_like_filled') :
            $r('app.media.ic_public_like'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.likeNum))
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(400);
        }.width(40).height(40).justifyContent(FlexAlign.Center).onClick(() => {
          if (this.data.currentUserLikeStatus === StatusFLAG.YES) {
            cancelLikeTravelogue(this.travelId).then(() => {
              this.data.currentUserLikeStatus = StatusFLAG.NO;
              this.data.likeNum -= 1;
              this.data.commentNum = this.data.travelogueEvaluateList.length;
              this.changeLiked();
            }).catch(() => {
              ToastDialog.showToast({ message: '请求失败，请联网重试' });
            });
          } else {
            likeTravelogue(this.travelId).then(() => {
              this.data.currentUserLikeStatus = StatusFLAG.YES;
              this.data.likeNum += 1;
              this.data.commentNum = this.data.travelogueEvaluateList.length;
              this.changeLiked();
            }).catch(() => {
              ToastDialog.showToast({ message: '请求失败，请联网重试' });
            });
          }
        });

        Column({ space: 2 }) {
          Image($r('app.media.ic_public_message'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.commentNum || 0))
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(400);
        }.width(40).height(40).justifyContent(FlexAlign.Center).onClick(() => {
          if (this.scroller.currentOffset().yOffset >= this.contentH) {
            this.isEditComment = true;
            return;
          }
          this.scroller.scrollTo({ xOffset: 0, yOffset: this.contentH });
        });

        Column({ space: 2 }) {
          Image(this.data.currentUserCollectStatus === StatusFLAG.YES ? $r('app.media.ic_public_star_filled') :
            $r('app.media.ic_public_star'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.collectNum))
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(400);
        }.width(40).height(40).justifyContent(FlexAlign.Center).onClick(() => {
          if (this.data.currentUserCollectStatus === StatusFLAG.YES) {
            cancelFavorTravelogue(this.travelId).then(() => {
              this.data.currentUserCollectStatus = StatusFLAG.NO;
              this.data.collectNum -= 1;
              this.data.commentNum = this.data.travelogueEvaluateList.length;
            }).catch(() => {
              ToastDialog.showToast({ message: '请求失败，请联网重试' });
            });
          } else {
            favorTravelogue(this.travelId).then(() => {
              this.data.currentUserCollectStatus = StatusFLAG.YES;
              this.data.collectNum += 1;
              this.data.commentNum = this.data.travelogueEvaluateList.length;
            }).catch(() => {
              ToastDialog.showToast({ message: '请求失败，请联网重试' });
            });
          }
        });

        Column({ space: 2 }) {
          Image($r('app.media.ic_public_share'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.shareNum || 0))
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(400);
        }.width(40).height(40).justifyContent(FlexAlign.Center).onClick(() => {
          this.share();
        });
      }
    }
    .width(CommonConstant.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: this.windowBottomHeight,
    })
    .shadow({
      radius: 9,
      offsetX: 0,
      offsetY: -6,
      color: $r('app.color.detail_shadow'),
    });
  }

  build() {
    NavDestination() {
      Column() {
        this.buildTitle();

        Scroll(this.scroller) {
          Column() {
            this.buildContent();
            Row()
              .width(CommonConstant.FULL_PERCENT)
              .height(8)
              .backgroundColor($r('sys.color.background_secondary'));
            this.buildComment();
          };
        }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);

        this.buildBottomBar();
      }
      .height(CommonConstant.FULL_PERCENT)
      .width(CommonConstant.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'));
    }.hideTitleBar(true);
  }
}
