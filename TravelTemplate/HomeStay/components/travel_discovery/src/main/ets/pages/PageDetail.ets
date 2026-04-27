import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { image } from '@kit.ImageKit';
import { CircleShape } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
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
} from '../utils/ApiManage';

const COMMENT_AREA_ID = 'CommentArea';
const ASPECT_RADIO_DEFAULT = 3 / 4;

@Entry({ routeName: PageRouteName.PAGE_DETAIL })
@ComponentV2
export struct PageDetail {
  // 游记ID
  @Local travelId: number = 0;
  @Local data: PostDetailModel = new PostDetailModel();
  @Local isEditComment: boolean = false;
  @Local commentEditValue: string = '';
  @Local commentEditValueCopy: string = '';
  @Local aspectRatioSwiper: number = ASPECT_RADIO_DEFAULT;
  @Local imgAspectRadioList: number[] = [];
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  private scroller: Scroller = new Scroller();
  private contentH: number = 0;
  private firstImgBuffer: ArrayBuffer | null = null;
  changeLiked: () => void = () => {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.CHANGE_LIKED,
      this.data);
  };

  @Monitor('data.travelogueEvaluateList')
  onValueChange(monitor: IMonitor) {
    let curValue: CommentModel[] = monitor.value()?.now as CommentModel[];
    this.data.travelogueEvaluateList = curValue;
  }

  async aboutToAppear() {
    const params: ESObject = this.getUIContext().getRouter().getParams();
    this.travelId = params.id;
    recordBrowse(this.travelId);
    await this.queryDetail();
    this.queryFirstImgBuffer().then((resp) => {
      this.firstImgBuffer = resp;
    });
  }

  queryDetail() {
    return queryTravelogueDetail(this.travelId).then((resp: ESObject) => {
      this.data = new PostDetailModel(resp.data);
    }).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
    });
  }

  async queryFirstImgBuffer() {
    const imgList: string[] = this.data.images as string[];
    if (imgList.length) {
      const context = this.getUIContext().getHostContext()!;
      const imgUrlRaw = imgList[0];
      const imgUrlNew = handleImgSrc(context, imgUrlRaw);
      if (imgUrlNew.startsWith('https')) {
        const resp: http.HttpResponse = await http.createHttp().request(imgUrlNew);
        return resp.result as ArrayBuffer;
      } else if (imgUrlRaw.startsWith('mockImage://')) {
        const resourceName = imgUrlRaw.split('//')[1];
        const resp = await context.resourceManager.getMediaByName(resourceName);
        return resp.buffer as ArrayBuffer;
      } else {
        return null;
      }

    }
    return null;
  }

  async getThumbnailBuffer() {
    let arrayBuffer: ArrayBuffer;
    if (this.firstImgBuffer) {
      arrayBuffer = this.firstImgBuffer;
    } else {
      // 生成应用图标缩略图
      const contextFaker: Context = this.getUIContext().getHostContext()!;
      const iconUint8Array = contextFaker.resourceManager.getMediaContentSync($r('app.media.app_icon').id);
      arrayBuffer =
        iconUint8Array.buffer.slice(iconUint8Array.byteOffset, iconUint8Array.byteLength + iconUint8Array.byteOffset);
    }

    let imageSourceApi: image.ImageSource | undefined = undefined;
    try {
      imageSourceApi = image.createImageSource(arrayBuffer);
    } catch (e) {
      UtilLog.error(`getThumbnailBuffer error ${JSON.stringify(e)}`);
    }

    let opts: image.InitializationOptions = { size: { height: 6, width: 6 } };
    const pixelMap: image.PixelMap | undefined = await imageSourceApi?.createPixelMap(opts);
    let pictureObj: image.Picture = image.createPicture(pixelMap);
    if (this.firstImgBuffer) {
      await pixelMap?.scale(0.1, 0.1);
    }
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    const buffer = await imagePackerApi.packing(pictureObj, {
      format: 'image/jpeg', // 当前只支持'image/jpeg','image/webp'和'image/png'类型图片.
      quality: 50, // JPEG编码中设定输出图片质量的参数,取值范围为0-100，建议适当压缩,图片过大无法拉起分享
    });

    return buffer;
  }

  private async share() {
    const buffer = await this.getThumbnailBuffer();
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      // todo 如果有元服务的appplink则可设置为HYPERLINK，content传applink地址
      utd: utd.UniformDataType.TEXT,
      content: this.data.content,
      title: this.data.title, // 不传title时 显示链接
      description: this.data.content, // 不传则不显示描述内容
      thumbnail: new Uint8Array(buffer), // 推荐传入应用图标 不传则显示默认html图标
    });
    // 进行分享面板显示
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE,
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
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
    Row() {
      Image($r('app.media.ic_public_back'))
        .height(16)
        .fillColor($r('app.color.grey_level_9'))
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.getUIContext().getRouter().back();
        });

      Image(handleImgSrc(this.getUIContext().getHostContext()!, this.data.publisherAvatar))
        .width(32)
        .height(32)
        .clipShape(new CircleShape({ width: 32, height: 32 }))
        .margin({ left: 8, right: 4 });

      Text(this.data.publisher)
        .fontColor($r('app.color.grey_level_9'))
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(16)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 2 });

      Blank();
      Image($r('app.media.ic_public_share'))
        .width(22)
        .fillColor($r('app.color.grey_level_9'))
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.share();
        });

    }
    .width(CommonConstant.FULL_PERCENT)
    .height(44)
    .padding({ left: 10, right: 10 })
    .backgroundColor($r('app.color.white'));
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
        this.getUIContext().getRouter().pushNamedRoute({ name: v.targetUrl, params: v });
      }
    });
  }

  @Builder
  buildContent() {
    Column({ space: 10 }) {
      // 帖子图片
      Swiper() {
        Repeat<string>(this.data.images as string[]).each((repeatItem: RepeatItem<string>) => {
          Image(handleImgSrc(this.getUIContext().getHostContext()!, repeatItem.item))
            .height(CommonConstant.FULL_PERCENT)
            .width(CommonConstant.FULL_PERCENT)
            .margin({ bottom: 30 })
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
      .aspectRatio(this.aspectRatioSwiper)
      .autoPlay(false)
      .loop(false)
      .indicator(
        new DotIndicator()
          .itemWidth(6)
          .selectedItemWidth(12),
      );

      Column({ space: 10 }) {
        // 帖子标题
        Text(this.data.title).fontSize(20).fontWeight(500).fontColor($r('app.color.grey_level_9')).lineHeight(28);
        // 帖子内容
        Text(this.data.content)
          .fontSize(14).fontWeight(400).fontColor($r('app.color.grey_level_9')).lineHeight(20);

        // 发现模块
        if (this.data?.relatedModules?.length) {
          Column({ space: 4 }) {
            ForEach(this.data.relatedModules, (v: FindModule) => {
              this.buildFindItem(v);
            }, (v: FindModule) => v.targetUrl);
          };
        }

        // 发表时间
        Text(handleTimeFormat(this.data.publishTime))
          .fontSize(10)
          .fontColor($r('app.color.grey_level_4'))
          .fontWeight(400)
          .lineHeight(14);

      }.padding({ left: 10, right: 14, bottom: 10 }).alignItems(HorizontalAlign.Start);
    }
    .borderWidth({ bottom: 0.5 })
    .borderColor($r('app.color.grey_level_4'))
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((o, n) => {
      this.contentH = n.height as number;
    });
  }

  @Builder
  buildComment() {
    Column({ space: 10 }) {
      Text($r('app.string.total_comment_desc', (this.data.commentNum || 0).toString()))
        .fontSize(10)
        .fontColor($r('app.color.grey_level_6'))
        .fontWeight(400)
        .lineHeight(14);
      List() {
        ForEach(this.data.travelogueEvaluateList, (v: CommentModel) => {
          ListItem() {
            Row({ space: 8 }) {
              Image(handleImgSrc(this.getUIContext().getHostContext(), v.userHeadImg) || $r('app.media.user'))
                .width(34)
                .height(34)
                .clipShape(new CircleShape({ width: 34, height: 34 }));
              Column({ space: 2 }) {
                Text(v.createBy || $r('app.string.comment_user_name_default'))
                  .fontSize(12)
                  .fontColor($r('app.color.grey_level_4'))
                  .fontWeight(400)
                  .lineHeight(16);
                Text(v.evaluateContent)
                  .fontSize(12).fontColor($r('app.color.grey_level_6')).fontWeight(400).lineHeight(16);
                Text(handleTimeFormat(v.createTime))
                  .fontSize(10)
                  .fontColor($r('app.color.grey_level_4'))
                  .fontWeight(400)
                  .lineHeight(14);
              }.alignItems(HorizontalAlign.Start).layoutWeight(1);
            }.alignItems(VerticalAlign.Top).margin({ bottom: 8 }).width(CommonConstant.FULL_PERCENT);
          };
        }, (v: CommentModel) => v.createTime.toString());
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
      left: 10,
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
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.comment_success_msg') });
      this.commentEditValueCopy = '';
      this.isEditComment = false;
    }).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.query_fail') });
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
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.comment_null_msg') });
          return;
        }
        this.postComment();
      });
    }.width(CommonConstant.FULL_PERCENT).padding(20);

  }

  @Builder
  buildBottomBar() {
    Row({ space: 22 }) {
      Stack() {
        TextInput({ text: this.commentEditValue })
          .focusable(false)
          .layoutWeight(1)
          .height(36)
          .backgroundColor('#F2F2F2')
          .onClick(() => {
            this.isEditComment = true;
          })
          .bindSheet($$this.isEditComment, this.buildInputSheet(), {
            preferType: SheetType.CENTER,
            height: SheetSize.FIT_CONTENT,
            showClose: false,
          });
        Row({ space: 4 }) {
          Image($r('app.media.ic_public_edit_filled'))
            .width(14)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.grey_level_4'));
          Text($r('app.string.comment_placeholder'))
            .fontColor($r('app.color.grey_level_4'))
            .fontSize(12)
            .lineHeight(16)
            .fontWeight(500);
        }.margin({ left: 10 }).visibility(this.commentEditValue ? Visibility.Hidden : Visibility.Visible);
      }.layoutWeight(1).align(Alignment.Start).hitTestBehavior(HitTestMode.Transparent);

      Row({ space: 16 }) {
        Row({ space: 6 }) {
          Image(this.data.currentUserLikeStatus === StatusFLAG.YES ? $r('app.media.ic_public_like_filled') :
            $r('app.media.ic_public_like'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.likeNum))
            .fontSize(14)
            .fontColor($r('app.color.grey_level_6'))
            .lineHeight(20)
            .fontWeight(400);
        }.onClick(() => {
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

        Row({ space: 6 }) {
          Image(this.data.currentUserCollectStatus === StatusFLAG.YES ? $r('app.media.ic_public_mark_filled') :
            $r('app.media.ic_public_favourites'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);
          Text(handleCount(this.data.collectNum))
            .fontSize(14)
            .fontColor($r('app.color.grey_level_6'))
            .lineHeight(20)
            .fontWeight(400);
        }.onClick(() => {
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

        Row({ space: 6 }) {
          Image($r('app.media.ic_public_message'))
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.grey_level_9'));
          Text(handleCount(this.data.commentNum || 0))
            .fontSize(14)
            .fontColor($r('app.color.grey_level_6'))
            .lineHeight(20)
            .fontWeight(400);
        }.onClick(() => {
          console.debug('this.contentH=' + this.contentH);
          if (this.scroller.currentOffset().yOffset >= this.contentH) {
            this.isEditComment = true;
            return;
          }
          this.scroller.scrollTo({ xOffset: 0, yOffset: this.contentH });
        });
      };
    }
    .width(CommonConstant.FULL_PERCENT)
    .padding({
      left: 10,
      right: 10,
      top: 10,
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
            this.buildComment();
          };
        }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);

        this.buildBottomBar();
      }
      .padding({ top: this.windowTopHeight })
      .height(CommonConstant.FULL_PERCENT)
      .width(CommonConstant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}
