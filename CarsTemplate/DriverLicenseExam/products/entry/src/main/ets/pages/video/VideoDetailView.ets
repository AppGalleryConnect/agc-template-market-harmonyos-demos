
import { CommonConstants, CommonModel, ObjectUtil } from '@ohos_agcit/driver_license_exam_commonlib'
import { Video } from '@ohos_agcit/driver_license_exam_datasource';
import { SharePicker } from 'aggregated_share';
import { window } from '@kit.ArkUI';
import { ExamController } from 'exam'
import { LongTakeAnimationProperties, CardLongTakeDelegate, LongTakeTransitionParam } from 'module_transition'
import { VideoDetailParam } from '../../types/Types'

@Builder
export function VideoDetailViewBuilder() {
  VideoDetailView()
}


@ComponentV2
struct VideoDetailView {
  vm: CommonModel = CommonModel.instance;
  @Local videUrl: string = ''
  @Local videoParam: Video | undefined = undefined;
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;
  examController:ExamController = ExamController.instance;
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  @Builder
  share() {
    Row() {
      Image($r('app.media.share'))
        .width(40)
        .height(40)
        .onClick(() => {
          const picker: SharePicker = new SharePicker({
            title: this.videoParam!.simpleDescription,
          });
          picker.show();
        })
    }
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .margin({
      right:16
    })
  }

  @Builder
  ContentBuilder() {
    Scroll() {
      Column() {
        Stack({alignContent:Alignment.TopStart}) {
          Video({
            src: this.videoParam!.url,
          })
            .width(CommonConstants.FULL_WIDTH)
            .height(this.vm.isLargeDevice ? 419 : 204)
            .objectFit(ImageFit.Auto)
            .onFullscreenChange((e?) => {
              try {
                window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => {
                  if (e && e.fullscreen) {
                    data.setPreferredOrientation(window.Orientation.LANDSCAPE); // 关键横屏设置
                  } else {
                    data.setPreferredOrientation(window.Orientation.PORTRAIT); // 关键横屏设置
                  }
                });
              } catch (err) {
              }

            })
            .onFinish(() => {
              try {
                window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => {
                  data.setPreferredOrientation(window.Orientation.PORTRAIT); // 关键横屏设置
                });
              } catch (err) {
              }
            })

        }
        .width(CommonConstants.FULL_WIDTH)
        .height(this.vm.isLargeDevice ? 419 : 204)

        Column({space:24}) {
          Text(this.videoParam!.simpleDescription)
            .fontSize(this.examController.getFg(18))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .width(CommonConstants.FULL_WIDTH)
          Text(this.videoParam!.description)
            .fontSize(this.examController.getFg(14))
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(this.examController.getFg(21))
            .width(CommonConstants.FULL_WIDTH)
          Text(this.videoParam!.copyrightNotice)
            .fontSize(this.examController.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .width(CommonConstants.FULL_WIDTH)
        }
        .padding({
          top:8,
          left:16,
          right:16
        })
      }
    }
    .scrollBar(BarState.Off)
  }

  build() {
    NavDestination() {
      if (this.videoParam !== undefined) {
        if (this.longTakeSession) {
          CardLongTakeDelegate({
            longTakeSession: this.longTakeSession,
            contentBuilder: (): void => {
              this.ContentBuilder()
            },
          })
        } else {
          this.ContentBuilder()
        }
      }
    }
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .id('VideoDetailView')
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .title('视频讲解')
    .menus(this.share)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((navDestContext: NavDestinationContext) => {
      let param = navDestContext.pathInfo?.param as VideoDetailParam;
      // 参数在 'video' 字段中
      if (ObjectUtil.isNotNull(param) && ObjectUtil.isNotNull(param.video)) {
        this.videoParam = param.video;
      }
      if (ObjectUtil.isNotNull(param) && ObjectUtil.isNotNull(param.longTakeTransitionParam)) {
        this.longTakeTransitionParam = param.longTakeTransitionParam!;
        this.longTakeSession.init(navDestContext, this.longTakeTransitionParam, {
          pop: () => {
            navDestContext.pathStack.pop()
          },
        });
      }
    })

  }
}
