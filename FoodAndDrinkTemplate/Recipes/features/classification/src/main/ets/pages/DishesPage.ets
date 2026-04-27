import { Logger, RouterMap, RouterModule, SystemBarOperation } from 'commonlib';
import { DishesVM } from '../viewModels/DishesVM';
import { BasketItem } from 'shopping_basket';
import { CardLongTakeDelegate, LongTakeTransitionParam } from 'module_transition';
import { MovingPhotoView } from '@kit.MediaLibraryKit';
import { VideoView } from 'featured_recipes';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { DishesStep } from './DishesStep';
import { CommentModel } from '../model/CommentModel';
import { CommentPopup } from './CommentPopup';
import { HwAdService } from 'aggregated_ads';
import { CommentItem } from '../components/CommentItem';
import { BasicInfo } from '../components/BasicInfo';
import { BottomZone } from '../components/BottomZone';

@Builder
export function DishesPageBuilder() {
  DishesPage();
}

@ComponentV2
struct DishesPage {
  @Local vm: DishesVM = new DishesVM();
  @Local resources: SourceImageModel[] = []
  options: ImagePreviewOptions = new ImagePreviewOptions()
  @Local previewIndex: number = -1
  @Local isShow: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.vm.init();
    this.options
      .setImageActionListener({
        onPageChanged: (item: SourceImageModel, index: number) => {
          this.previewIndex = index
        },
        onLongPress: (index: number) => {
          Logger.info(`长按了第${index + 1}个资源`)
        },
      })
      .setPreviewListener({
        onBack: () => {
          this.previewIndex = -1
        },
      })
  }

  aboutToDisappear(): void {
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: '#ff090909',
    })
  }

  onPageHide(): void {
    console.log('onPageHide111')
  }

  private onBackPressed(): boolean {
    RouterModule.pop();
    return true;
  }

  @Computed
  get isInBasket() {
    return this.vm.basketList.list.some((item: BasketItem) => item.id === this.vm.recipeDetail?.id);
  }

  @Builder
  ContentBuilder() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          Scroll(this.vm.scroller) {
            Flex({
              direction: this.vm.breakPoint === 'sm' ? FlexDirection.Column : FlexDirection.Row,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Scroll() {
                Column() {
                  if (this.vm.recipeDetail?.video) {
                    if (this.vm.recipeDetail.thumbnail) {
                      Row() {
                        MovingPhotoView({
                          movingPhoto: this.vm.src,
                          controller: this.vm.controller
                        })
                      }
                      .height(305)
                      .width('100%')
                      .clip(true)
                      .aspectRatio(1)
                      .onClick(() => {
                        this.options
                          .setImageList([new SourceImageModel({
                            imageUrl: this.vm.recipeDetail?.thumbnail ?? '',
                          })])
                          .setInitIndex(0)
                        ImagePreview.open(this.getUIContext(), this.options)
                      })
                    } else {
                      Row() {
                        VideoView({
                          videoData: this.vm.recipeDetail,
                          isSlider: true,
                          showPip: this.vm.showPip,
                          isFullScreen: this.vm.isFullScreen,
                          breakPoint: this.vm.breakPoint,
                          detailScroller: this.vm.scroller,
                          isStop: this.vm.isStop,
                          showFullScreen: () => {
                            this.vm.showFullScreen()
                          }
                        });
                        if (this.vm.isFullScreen) {
                          Column() {
                            Row() {
                              Row() {
                                Image($r(`app.media.${this.vm.recipeDetail.authorAvatar}`))
                                  .width(40).height(40).borderRadius(20);
                                Text(this.vm.recipeDetail.author)
                                  .fontSize(14)
                                  .fontColor(Color.White)
                                  .margin({ left: 4 });
                              }.onClick(() => {
                                RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE,
                                  { 'id': this.vm.recipeDetail?.authorId } as Record<string, number>)
                              })

                              Button(this.vm.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
                                .fontSize($r('sys.float.Body_M'))
                                .fontColor(this.vm.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
                                .fontWeight(FontWeight.Medium)
                                .backgroundColor(this.vm.isFollower ? '#33FD4238' : '#FD4238')
                                .width(72)
                                .onClick(() => {
                                  this.vm.changeFollower(!this.vm.isFollower)
                                })
                            }
                            .width('100%')
                            .height(48)
                            .justifyContent(FlexAlign.SpaceBetween)

                            Text(this.vm.recipeDetail.description)
                              .fontSize(14)
                              .fontColor(Color.White)
                              .width('100%')
                              .margin({ top: 4 });
                            Row() {
                              Text(this.vm.isFold ? '展开' : '收起').fontColor(Color.White).fontSize(14)
                              Image(this.vm.isFold ? $r('app.media.ic_down_arrow') : $r('app.media.ic_top_arrow'))
                                .width(9).height(5)
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.SpaceBetween)
                            .margin({ top: 12 })
                            .onClick(() => {
                              this.vm.isFold = !this.vm.isFold;
                            })

                            if (!this.vm.isFold) {
                              Column() {
                                Text('菜谱更新于2025-06-15').fontColor(Color.White).fontSize(12).width('100%')
                                Button('查看更多详情', { controlSize: ControlSize.SMALL })
                                  .fontWeight(500)
                                  .fontFamily('HarmonyHeiTi')
                                  .fontSize($r('sys.float.Body_M'))
                                  .backgroundColor('#E84026')
                                  .margin({ top: 8 })
                                  .alignSelf(ItemAlign.Start)
                                  .onClick(() => {
                                    this.vm.isFullScreen = false;
                                  })
                              }
                              .width('100%')
                              .margin({ top: 12 })
                            }
                          }
                          .position({ y: '100%' })
                          .translate({y: this.vm.isFold ? -200 : -270})
                          .padding({ left: 16, right: 16 })
                        }
                      }
                      .width('100%')
                      .clip(true)
                      .height(this.vm.isFullScreen ? '100%' : this.vm.breakPoint === 'sm' ? '60%' : '100%')
                      .draggable(false)
                    }
                  } else {
                    if (this.vm.recipeDetail?.thumbnail.includes('.png')) {
                      Image(this.vm.recipeDetail?.thumbnail)
                        .imageStyles(this.vm.breakPoint)
                        .onClick(() => {
                          this.options
                            .setImageList([new SourceImageModel({
                              imageUrl: this.vm.recipeDetail?.thumbnail ?? '',
                            })])
                            .setInitIndex(0)
                          ImagePreview.open(this.getUIContext(), this.options)
                        })
                    } else {
                      Image($r(`app.media.${this.vm.recipeDetail?.thumbnail}`))
                        .imageStyles(this.vm.breakPoint)
                        .onClick(() => {
                          this.options
                            .setImageList([new SourceImageModel({
                              imageUrl: $r(`app.media.${this.vm.recipeDetail?.thumbnail}`),
                            })])
                            .setInitIndex(0)
                          ImagePreview.open(this.getUIContext(), this.options)
                        })
                    }
                  }
                  if (!this.vm.isFullScreen) {
                    if(this.vm.breakPoint === 'sm' || this.vm.recipeDetail?.thumbnail) {
                      BasicInfo({ dishesVm: this.vm })
                    }
                  }
                }
              }
              .scrollable(this.vm.breakPoint === 'sm' ? ScrollDirection.None : ScrollDirection.Vertical)
              .scrollBar(BarState.Off)
              .onDidScroll(() => {
              })
              .margin({ top: this.vm.breakPoint === 'sm'|| this.vm.recipeDetail?.video ? 0 : 90 })

              // 烹饪步骤
              if (!this.vm.isFullScreen) {
                Scroll(this.vm.stepScroller) {
                  Column() {
                    if(this.vm.breakPoint !== 'sm' && !this.vm.recipeDetail?.thumbnail) {
                      BasicInfo({ dishesVm: this.vm })
                    }

                    DishesStep({ dishesVm: this.vm, isShowDishModel: true })
                    // 信息流广告占位
                    Column() {
                      HwAdService({
                        // todo 替换广告id
                        adId: 'testu7m3hc4gvm',
                        adType: 3,
                      })
                        .borderRadius(16)
                        .clip(true)
                    }
                    .width('100%')
                    .height(this.vm.breakPoint === 'lg' || this.vm.breakPoint === 'xl' ? 330 : 214)
                    .margin({ top: 8 })
                    .padding({ left: 16, right: 16 })

                    this.commentBuilder()
                  }
                }
                .scrollable(this.vm.breakPoint === 'sm' ? ScrollDirection.None : ScrollDirection.Vertical)
                .scrollBar(BarState.Off)
                .margin({ top: this.vm.breakPoint === 'sm' ? 0 : 90 })
              }
            }
            .width('100%')
          }
          .scrollable(this.vm.breakPoint === 'sm' ? ScrollDirection.Vertical : ScrollDirection.None)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .onDidScroll(() => {
            const yOffset = this.vm.scroller.currentOffset().yOffset;
            if (yOffset > 500) {
              this.vm.showPip = true;
            } else {
              this.vm.showPip = false;
            }
          })
          // 底部互动专区
          BottomZone({ dishesVm: this.vm })
            .width(this.vm.breakPoint === 'lg' && !this.vm.isFullScreen ? '50%' : '100%')
        }
        .alignContent(this.vm.breakPoint === 'sm' || this.vm.breakPoint === 'lg' ?
          Alignment.BottomEnd : Alignment.Bottom)
        .layoutWeight(1)
      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .height('100%')

      Image(this.vm.breakPoint === 'sm' || this.vm.recipeDetail?.video ?
        $r('app.media.ic_left_arrow') : $r('app.media.ic_left_black_arrow'))
        .width(40)
        .height(40)
        .margin({ top: 40, left: this.vm.dishMargin })
        .onClick(() => {
          RouterModule.pop();
        })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  commentSheet() {
    CommentPopup({
      submitEvent: (count: number, content: string) => {
        this.submitResult(count, content);
      }
    })
      .width('100%')
  }

  @Builder
  commentBuilder() {
    Row() {
      Text(`评论·${this.vm.comments.length}`)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .height('56')
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ left: 16, right: 16 })

    if (this.vm.comments.length > 0) {
      List({ scroller: this.vm.commentsScroller }) {
        ForEach(this.vm.comments,
          ((item: CommentModel) => {
            ListItem() {
              CommentItem({ comment: item });
            };
          }), (item: CommentModel, index: number) => JSON.stringify(item) + index);
      }
      .onDidScroll(() => {
        const yOffset = this.vm.commentsScroller.currentOffset().yOffset;
      })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({ left: 16, right: 16 })
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .margin({ bottom: 100 })
    } else {
      Text('暂无评论，快来抢首评')
        .width('100%')
        .height(100)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 100 })
    }
  }

  submitResult(count: number, content: string) {
    this.vm.addComment(content, count);
    this.isShow = false;
    if (this.vm.breakPoint === 'sm') {
      this.vm.scroller.scrollEdge(Edge.Bottom)
    } else {
      this.vm.stepScroller.scrollEdge(Edge.Bottom)
    }
    this.vm.commentsScroller.scrollEdge(Edge.Top);
  }

  build() {
    NavDestination() {
      if (this.vm.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.vm.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    // 弹出页需要修改navDestination的背景颜色为session中的值
    .backgroundColor(this.vm.longTakeSession.navDestinationBgColor)
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.vm.longTakeSession.setNewSize({ width: '100%', height: '100%' });
    })
    .hideTitleBar(true)
    .onReady((navDestContext: NavDestinationContext) => {
      let param = navDestContext.pathInfo?.param as Record<string, Object>;
      this.vm.indexValue = param.indexValue as number;
      this.vm.longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
      if (this.vm.longTakeTransitionParam) {
        this.vm.longTakeSession.init(navDestContext, this.vm.longTakeTransitionParam, {
          pop: () => {
            RouterModule.pop()
          },
        });
      }
    })
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if(!isExpanding) {
        this.vm.isStop = true;
      }
    })
  }
}

@Extend(Text)
function textStyles(isFullScreen: boolean) {
  .fontSize(10)
  .fontFamily('HarmonyHeiTi')
  .fontColor(isFullScreen ? Color.White : $r('sys.color.font_primary'))
}

@Extend(Image)
function imageStyles(breakPoint: string) {
  .width(breakPoint === 'sm' ? '100%' : '90%')
  .borderRadius(breakPoint === 'sm' ? 0 : 16)
  // .margin({ top: breakPoint === 'sm' ? 0 : 80 })
  .height(290)
  .clip(true)
  .objectFit(ImageFit.Cover)
}

