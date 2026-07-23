import { CommonModel, CommonConstants, ObjectUtil } from '@ohos_agcit/driver_license_exam_commonlib';
import { GuideData, GuideService } from '@ohos_agcit/driver_license_exam_guide';
import { KEMUTAB_LIST } from '../../constants/Constants';
import { KEMUTabListItem, VideoDetailParam } from '../../types/Types';
import { EXAM_MANAGER_TYPE, ROUTE_PARAM, Video, ExamService,
  RouteCommonParam } from '@ohos_agcit/driver_license_exam_datasource';
import { webViewParam } from '../../components/WebContainer';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

@ComponentV2
struct CanvasView {
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  @Param didCount: number = 0;
  @Param totalCount: number = 0;

  @Monitor('didCount')
  drawProgress() {
    const width = this.context.width;
    const height = this.context.height;
    this.context.clearRect(0, 0, width, height);

    const doneWidth = width * this.didCount / this.totalCount;
    this.context.beginPath();
    this.context.strokeStyle = '#64BB5C';
    this.context.lineWidth = 2;
    this.context.setLineDash([5, 0]);
    this.context.moveTo(0, 5);
    this.context.lineTo(doneWidth, 5);
    this.context.stroke();

    this.context.beginPath();
    this.context.strokeStyle = 'rgba(0, 0, 0, 0.3)';
    this.context.lineWidth = 2;
    this.context.setLineDash([5, 3]);
    this.context.moveTo(doneWidth, 5);
    this.context.lineTo(width, 5);
    this.context.stroke();
  }

  build() {
    Canvas(this.context)
      .width(CommonConstants.FULL_WIDTH)
      .height(10)
      .onReady(() => {
        this.drawProgress();
      });
  }
}

@ComponentV2
export struct HomeView {
  vm: CommonModel = CommonModel.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local currentTab: number = 0;
  @Param didCount: number = 0;
  @Param totalCount: number = 0;
  guideService: GuideService = GuideService.instance;
  @Local videoList: Video[] = this.examService.getVideList();
  @Local guideData: GuideData = GuideData.instance;
  swiperController: SwiperController = new SwiperController();
  @Event tabChange: (index: number) => void = () => {};

  @Monitor('guideData.driveStage')
  dirveStage() {
    this.currentTab = this.guideData.driveStage as number - 1;
    this.tabChange(this.currentTab);
  }

  @Builder
  advertisement(img: Resource | string, text: string) {
    Stack() {
      Image(img)
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .borderRadius(16);

      Text(text)
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontFamily('HarmonyOS Sans')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .maxFontScale(1)
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(this.vm.isLargeDevice ? 280 : 136)
    .borderRadius(16)
    .alignContent(Alignment.Center)
    .onClick(() => {
      const param: webViewParam = {
        title: text,
        path: 'developer.huawei.com/consumer/cn',
      };
      this.vm.navStack.pushPathByName('webContainer', param);
    })
  }

  @Builder
  subjectTwoAndThree() {
    Scroll() {
      Column({ space: 12 }) {
        this.advertisement($r('app.media.video_ad_bg'), '视频多看一遍，考试易过一分');
        Column({ space: 12 }) {
          Text('考场必考项目讲解')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .width(CommonConstants.FULL_WIDTH)
            .maxFontScale(1);
          List({ space: this.vm.isLargeDevice ? 23 : 12 }) {
            ForEach(this.videoList, (item: Video, index: number) => {
              ListItem() {
                Column({ space: 8 }) {
                  RelativeContainer() {
                    Image(item.poster)
                      .width(CommonConstants.FULL_WIDTH)
                      .height(CommonConstants.FULL_HEIGHT);

                    Image($r('app.media.play_button'))
                      .width(24)
                      .height(24)
                      .alignRules({
                        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                        right: { anchor: '__container__', align: HorizontalAlign.End },
                      })
                      .offset({
                        x: -8,
                        y: -8,
                      });
                  }
                  .height(this.vm.isLargeDevice ? 116 : 80)
                  .width(CommonConstants.FULL_WIDTH)
                  .onClick(() => {
                    let param: VideoDetailParam = {
                      video: item,
                    };
                    let componentId = 'video_' + index;
                    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
                      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), componentId, 9);
                    if (ObjectUtil.isNotNull(longTakeTransitionParam)) {
                      param.longTakeTransitionParam = longTakeTransitionParam;
                    }
                    this.vm.navStack.pushPathByName('videoDetailView', param);
                  })
                  .id('video_' + index);
                  Text(item.name)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                    .width(CommonConstants.FULL_WIDTH)
                    .maxFontScale(1);
                }
                .width(this.vm.isLargeDevice ? 156 : 104);
              }
            }, (item: Video) => JSON.stringify(item));
          }
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off);
        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .alignItems(HorizontalAlign.Start)
        .height(this.vm.isLargeDevice ? 200 : 164)
        .width(CommonConstants.FULL_WIDTH)
        .padding({
          top: 12,
          left: 12,
          bottom: 12,
        });
      }
      .width(CommonConstants.FULL_WIDTH);
    }
    .scrollBar(BarState.Off)
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .align(Alignment.TopStart);
  }

  @Builder
  subjectOneAndFour() {
    Scroll() {
      Column({ space: 12 }) {
        this.advertisement($r('app.media.banner1'), '学好驾车，安全你我');

        Column({ space: 8 }) {
          Row() {
            Image($r('app.media.shunxu_practice'))
              .width(24)
              .height(24)
              .margin({ left: 12, right: 4 });

            Text('顺序练习')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .maxFontScale(1);

            Blank();

            Text('前往练习')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ right: 4 })
              .maxFontScale(1);

            Image($r('app.media.right_triangle'))
              .width(16)
              .height(16)
              .margin({ right: 12 });
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(42)
          .borderRadius(8)
          .backgroundColor('#64BB5C')
          .onClick(() => {
            const param: ROUTE_PARAM = {
              title: '顺序练习',
              type: EXAM_MANAGER_TYPE.sequence,
            };
            this.vm.navStack.pushPathByName('practiceView', param);
          });

          Row() {
            Text('练习进度')
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
              .maxFontScale(1);

            Stack({ alignContent: Alignment.Center }) {
              CanvasView({
                didCount: this.didCount,
                totalCount: this.totalCount,
              });
            }
            .layoutWeight(1)
            .height(10)
            .margin({ left: 4, right: 4 });

            Text(`${this.didCount}/${this.totalCount}`)
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
              .maxFontScale(1);
          }
          .width(CommonConstants.FULL_WIDTH);
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(12)
        .height(98)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .justifyContent(FlexAlign.SpaceAround);

        Column() {
          Row() {
            Image($r('app.media.trophy'))
              .width(24)
              .height(24)
              .margin({ right: 4 });

            Text('模拟考试')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .maxFontScale(1);

            Blank();

            Text('仿真冲刺')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ right: 4 })
              .maxFontScale(1);

            Image($r('app.media.right_triangle'))
              .width(16)
              .height(16);
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(42)
          .borderRadius(8)
          .backgroundColor('#46B1E3')
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            const param: ROUTE_PARAM = {
              title: '模拟考试',
              type: EXAM_MANAGER_TYPE.mock_exam,
              examManager: this.examService.getMockExamManager('模拟考试'),
            };
            this.vm.navStack.pushPathByName('practiceView', param);
          });
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(66)
        .padding(12)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        Row() {
          Column({ space: 4 }) {
            Image($r('app.media.special_practice'))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain);

            Text('专项练习')
              .fontSize(14)
              .lineHeight(19)
              .fontColor($r('sys.color.font_primary'))
              .maxFontScale(1);
          }
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.vm.navStack.pushPathByName('specialExercisesView', true);
          });

          Column({ space: 4 }) {
            Image($r('app.media.tel_program'))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain);

            Text('视频课程')
              .fontSize(14)
              .lineHeight(19)
              .fontColor($r('sys.color.font_primary'))
              .maxFontScale(1);
          }
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.vm.navStack.pushPathByName('videoListView', true);
          });

          Column({ space: 4 }) {
            Image($r('app.media.wrong_questing'))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain);

            Text('错题收藏')
              .fontSize(14)
              .lineHeight(19)
              .fontColor($r('sys.color.font_primary'))
              .maxFontScale(1);
          }
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.vm.navStack.pushPathByName('collectionView', true);
          });
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding(12)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center);
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding({ bottom: 60 });
    }
    .scrollBar(BarState.Off)
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .align(Alignment.TopStart);
  }

  @Builder
  tab() {
    Row() {
      ForEach(KEMUTAB_LIST, (item: KEMUTabListItem, index: number) => {
        Column() {
          Text(item.label)
            .fontColor(this.currentTab === index ? $r('sys.color.font_primary') :
              $r('sys.color.font_secondary'))
            .fontSize(14)
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .margin({ top: 4, bottom: 4 })
            .maxFontScale(1)
            .textAlign(TextAlign.Center);

          if (this.currentTab === index) {
            Divider()
              .color($r('sys.color.comp_divider'))
              .strokeWidth(2)
              .width(CommonConstants.FULL_WIDTH)
              .margin({ top: 4 });
          }
        }
        .layoutWeight(1)
        .height(CommonConstants.FULL_HEIGHT)
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          this.swiperController.changeIndex(index);
          this.tabChange(index);
        });
      }, (item: KEMUTabListItem) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(48)
    .margin({
      top: 12,
    });
  }

  @Builder
  topArea() {
    Row() {
      Text($r('app.string.homepage'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .maxFontScale(1);
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 12,
      bottom: 12,
    });
  }

  build() {
    Stack() {
      Image($r('app.media.guide_bg'))
        .width(CommonConstants.FULL_WIDTH)
        .height(268);

      Column() {
        Column() {
          this.topArea();
          Row() {
            Row() {
              Text(this.guideService.getGuideData().city)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ right: 4 })
                .maxFontScale(1);

              Image($r('app.media.city_triangle'))
                .width(12)
                .height(12)
                .objectFit(ImageFit.Contain);
            }
            .onClick(() => {
              const param: RouteCommonParam = {
                fromPage: 'HomeView',
              };
              this.vm.navStack.pushPathByName('selectCityView', param, true);
            })
            .margin({ left: 12, right: 8 });

            // 搜索框
            Row({ space: 8 }) {
              Image($r('app.media.ic_glass'))
                .width(16)
                .fillColor($r('sys.color.icon_primary'));

              Text('请输入关键字搜索')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
                .maxFontScale(1);
            }
            .backgroundColor($r('app.color.search_background'))
            .height(40)
            .layoutWeight(1)
            .margin({ right: 12 })
            .padding(12)
            .borderRadius(8)
            .onClick(() => {
              this.vm.navStack.pushPathByName('SearchPage', undefined);
            });
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(64)
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(16);

          this.tab();

          Swiper(this.swiperController) {
            this.subjectOneAndFour();
            this.subjectTwoAndThree();
            this.subjectTwoAndThree();
            this.subjectOneAndFour();
          }
          .layoutWeight(1)
          .cachedCount(0)
          .index(this.currentTab)
          .loop(false)
          .indicator(false)
          .onChange((targetIndex: number) => {
            this.currentTab = targetIndex;
          });
        }
        .width(CommonConstants.FULL_WIDTH)
        .layoutWeight(1)
        .padding({
          top: this.getUIContext().px2vp(AppStorage.get('topRectHeight') || 0) + 10,
          left: 16,
          right: 16,
        });
      }
      .width(CommonConstants.FULL_WIDTH)
      .layoutWeight(1);
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .alignContent(Alignment.Top)
    .backgroundColor($r('sys.color.background_secondary'));
  }
}
