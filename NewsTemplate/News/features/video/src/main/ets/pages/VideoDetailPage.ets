import { VideoViewVm } from '../viewModels/VideoViewVm';
import { mediaquery, promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseTitle } from 'componentlib';
import { RouterModule } from 'commonlib';

@Builder
export function videoDetailPageBuilder() {
  VideoDetailPage();
}

@ComponentV2
export struct VideoDetailPage {
  vm: VideoViewVm = VideoViewVm.instance;
  public previewUri: Resource = $r('app.media.preview')
  public curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  public isAutoPlay: boolean = false
  public showControls: boolean = true
  @Local collectFlag: boolean = false;
  @Local videoUrl: string =
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-nkths/videoTest.mp4?token=b7c7a44b-894f-45ee-9c56-33c41350c570';
  controller: VideoController = new VideoController()
  @Local isFullScreen: boolean = false

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  handlerOrientation(type: number) {
    window.getLastWindow(getContext(this), (err, win) => {
      win.setPreferredOrientation(type)
    })
  }


  @Builder
  Comment() {
    Row() {
      CommentItemView({
        img: this.collectFlag ? $r('app.media.heart_collect') : $r('app.media.collect'),
        label: '收藏',
        onClickEvent: () => {
          this.collectFlag = !this.collectFlag
          promptAction.showToast({
            message: this.collectFlag ? '收藏成功' : '取消收藏',
            alignment: Alignment.Bottom,
            offset: { dx: 0, dy: -vp2px(60) },
          })
        }
      })

      CommentItemView({
        img: $r('app.media.share'),
        label: '分享',
        onClickEvent: () => {
          promptAction.showToast({
            message: '分享成功',
            alignment: Alignment.Bottom,
            offset: { dx: 0, dy: -vp2px(60) },
          })
        }
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({
      left: 16, top: 10, bottom: 10, right: 16,
    })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  ContentTitle() {
    Column({space: 8}) {
      Video({
        src: this.videoUrl,
        previewUri: this.previewUri,
        currentProgressRate: this.curRate,
        controller: this.controller,
      })
        .autoPlay(this.isAutoPlay)
        .controls(true)
        .height('30%')
        .width('100%')
        .onFullscreenChange((event) =>{
          this.isFullScreen = event.fullscreen
          if (event.fullscreen) {
            this.handlerOrientation(window.Orientation.LANDSCAPE)
          } else {
            this.handlerOrientation(window.Orientation.PORTRAIT)
          }
        })

      Column({space: 8}) {
        Text('华为携手伙伴发布城市全域数字化转型联合行动计划')
          .fontSize(`${16 + this.vm.changeFontSize}`)
          .fontWeight(FontWeight.Bold)

        Row({space: 8}) {
          Text('xx新闻')
            .fontSize(`${12 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontColor('#66000000')
          Text('2025-04-06 21.00.00')
            .fontSize(`${12 + this.vm.changeFontSize}`)
            .fontWeight('regular')
            .fontColor('#66000000')
        }

        Image($r('app.media.ic_fengjing_01'))
          .height(184)
          .width('100%')
          .borderRadius(8)
          .margin({ top: 24 })
        Text('华为中国合作伙伴大会2025期间，在“数智赋能城市全域数字化转型”论坛上，华为与客户、伙伴和专家围绕城市智能体架构、城市智能中枢、' +
          '数据要素等重点领域，共话政务与城市数字化发展趋势并分享实践经验。会上，华为基于“平台+生态”合作战略，携手19家合作伙伴发布城市全域' +
          '数字化转型联合行动计划，共同构建端到端解决方案能力，加速城市全域数字化转型。华为政务一网通军团研发总裁陈金助表示，在城市全域数字化' +
          '转型的背景下，数据要素、大模型等新兴技术与政务数字化、城市数字化等场景的结合为行业发展带来了多重机遇。')
          .fontSize(`${14 + this.vm.changeFontSize}`)
          .fontWeight(FontWeight.Regular)
          .margin({ top: 16 })
          .lineHeight(21)
      }
      .padding({left:16, right: 16})
      .alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        Scroll() {
          this.ContentTitle()
        }
        .width('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        this.Comment()
      }
      .layoutWeight(1)
      .padding({top: 8})
    }
    .height('100%')
    .width('100%')
    .title('视频详情')
  }
}


@ComponentV2
struct CommentItemView {
  vm: VideoViewVm = VideoViewVm.instance;
  @Param label: string = ''
  @Param img: ResourceStr = ''
  @Event onClickEvent: () => void = () => {}

  build() {
    Column({space: 4}) {
      Image(this.img)
        .width(24)
        .height(24)
        .onClick(() => {
          this.onClickEvent && this.onClickEvent()
        })
      Text(this.label)
        .fontSize(`${10 + this.vm.changeFontSize}`)
        .fontWeight(FontWeight.Regular)
    }
  }
}