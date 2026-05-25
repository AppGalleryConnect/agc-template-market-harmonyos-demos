
import { CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'
import { Video } from '@ohos_agcit/driver_license_exam_datasource';
import { SharePicker } from 'aggregated_share';
import { window } from '@kit.ArkUI';
import { ExamController } from 'exam'

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

  build() {
    NavDestination() {
      if (this.videoParam !== undefined) {
        Scroll() {
          Column() {
            Stack({alignContent:Alignment.TopStart}) {
              Video({
                src: this.videoParam.url,
              })
                .width(CommonConstants.FULL_WIDTH)
                .height(204)
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
            .height(204)

            Column({space:24}) {
              Text(this.videoParam.simpleDescription)
                .fontSize(this.examController.getFg(18))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .width(CommonConstants.FULL_WIDTH)
              Text(this.videoParam.description)
                .fontSize(this.examController.getFg(14))
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(this.examController.getFg(21))
                .width(CommonConstants.FULL_WIDTH)
              Text(this.videoParam.copyrightNotice)
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
    }
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .title('视频讲解')
    .menus(this.share)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady(() => {
      const preIndex = this.vm.navStack.size() - 1;
      const param: Video = this.vm.navStack.getParamByIndex(preIndex) as Video;
      this.videoParam = param;
    })

  }
}
