import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { RouterModule } from '@agctemplate/router_module';
import { BarVM } from '@agctemplate/widgets';
import { QQShareData, SharePicker } from 'aggregated_share';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';

const TAG = '[VideoRecordPlayPage]';

const SPEED_OPTIONS: media.PlaybackSpeed[] = [
  media.PlaybackSpeed.SPEED_FORWARD_0_75_X,
  media.PlaybackSpeed.SPEED_FORWARD_1_00_X,
  media.PlaybackSpeed.SPEED_FORWARD_1_25_X,
  media.PlaybackSpeed.SPEED_FORWARD_1_50_X,
  media.PlaybackSpeed.SPEED_FORWARD_2_00_X
];

@Builder
export function VideoRecordPlayPageBuilder() {
  VideoRecordPlayPage();
}

@ComponentV2
struct VideoRecordPlayPage {
  @Local filePath: string = '';
  @Local videoTitle: string = '直播回放';
  private xComponentController: XComponentController = new XComponentController();
  private avPlayer: media.AVPlayer | undefined = undefined;
  @Local isPlaying: boolean = false;
  @Local currentTime: number = 0;
  @Local duration: number = 0;
  @Local isInitialized: boolean = false;
  @Local isXComponentReady: boolean = false;
  @Local surfaceId: string = '';
  @Local currentSpeedIndex: number = 1;
  @Local showControls: boolean = true;
  @Local showSpeedMenu: boolean = false;
  @Local speedMenuX: number = 0;
  @Local speedMenuY: number = 0;
  @Local coverUrl: string =
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png';
  @Local endIconModifier: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize('24vp').fontColor(['#E5FFFFFF']);

  aboutToDisappear(): void {
    this.releasePlayer();
  }

  async releasePlayer(): Promise<void> {
    if (this.avPlayer) {
      try {
        await this.avPlayer.stop();
        this.avPlayer.release();
        this.avPlayer = undefined;
      } catch (error) {
        console.error(`${TAG} releasePlayer failed: ${JSON.stringify(error)}`);
      }
    }
  }

  async initPlayer(): Promise<void> {
    if (this.isInitialized || !this.filePath || !this.isXComponentReady) {
      console.info(
        `${TAG} initPlayer skipped: isInitialized=${this.isInitialized}, filePath=${this.filePath}, isXComponentReady=${this.isXComponentReady}`);
      return;
    }
    console.info(`${TAG} initPlayer start, filePath=${this.filePath}, surfaceId=${this.surfaceId}`);
    if (!this.surfaceId) {
      console.error(`${TAG} surfaceId is empty, retry later`);
      return;
    }

    try {
      let stat = fs.statSync(this.filePath);
      console.info(`${TAG} file size: ${stat.size}`);
      if (stat.size === 0) {
        console.error(`${TAG} file is empty!`);
        return;
      }

      let metadataPath = this.filePath.replace('live_', 'live_info_').replace('.mp4', '.json');
      let metadataFile: fs.File | null = null;
      try {
        metadataFile = fs.openSync(metadataPath, fs.OpenMode.READ_ONLY);
        let buffer = new ArrayBuffer(4096);
        let readLen = fs.readSync(metadataFile.fd, buffer);
        let metadataContent = util.TextDecoder.create('utf-8', { ignoreBOM: true })
          .decodeWithStream(new Uint8Array(buffer.slice(0, readLen)));

        interface RecordingMetadata {
          title: string;
          startTime: number;
          duration: number;
        }

        let metadata = JSON.parse(metadataContent) as RecordingMetadata;
        if (metadata.title) {
          this.videoTitle = metadata.title;
        }
      } catch (e) {
        console.info(`${TAG} no metadata file`);
      } finally {
        if (metadataFile !== null) {
          fs.close(metadataFile);
        }
      }

      this.avPlayer = await media.createAVPlayer();
      this.avPlayer.on('stateChange', async (state: string) => {
        console.info(`${TAG} stateChange: ${state}`);
        switch (state) {
          case 'initialized':
            if (this.avPlayer && this.surfaceId) {
              this.avPlayer.surfaceId = this.surfaceId;
              this.avPlayer.prepare();
            }
            break;
          case 'prepared':
            this.isInitialized = true;
            this.duration = this.avPlayer!.duration;
            this.avPlayer!.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
            this.setPlaybackSpeed(this.currentSpeedIndex);
            this.avPlayer!.play();
            this.isPlaying = true;
            console.info(`${TAG} playing`);
            break;
          case 'completed':
            this.isPlaying = false;
            this.avPlayer!.seek(this.duration);
            break;
          case 'stopped':
            this.isPlaying = false;
            break;
        }
      });
      this.avPlayer.on('timeUpdate', (time: number) => {
        this.currentTime = time;
      });
      this.avPlayer.on('error', (err: BusinessError) => {
        console.error(`${TAG} AVPlayer error: ${err.code}, ${err.message}`);
      });

      let file: fs.File | null = null;
      try {
        file = fs.openSync(this.filePath, fs.OpenMode.READ_ONLY);
        let fdPath = 'fd://' + file.fd;
        this.avPlayer.url = fdPath;
      } catch (error) {
        console.error(`${TAG} initPlayer failed: ${JSON.stringify(error)}`);
      }
    } catch (error) {
      console.error(`${TAG} initPlayer failed: ${JSON.stringify(error)}`);
    }
  }

  setPlaybackSpeed(index: number): void {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(SPEED_OPTIONS[index]);
    }
  }

  togglePlayPause(): void {
    if (this.avPlayer) {
      if (this.isPlaying) {
        try {
          this.avPlayer.pause();
        } catch (e) {
          console.error(`${TAG} pause failed: ${e}`);
        }
        this.isPlaying = false;
      } else {
        if (this.currentTime >= this.duration - 1000) {
          try {
            this.avPlayer.seek(0);
          } catch (e) {
            console.error(`${TAG} seek failed: ${e}`);
          }
        }
        try {
          this.avPlayer.play();
        } catch (e) {
          console.error(`${TAG} play failed: ${e}`);
        }
        this.isPlaying = true;
      }
    }
  }

  cycleSpeed(): void {
    this.currentSpeedIndex = (this.currentSpeedIndex + 1) % SPEED_OPTIONS.length;
    this.setPlaybackSpeed(this.currentSpeedIndex);
  }

  openSpeedMenu(): void {
    this.showSpeedMenu = true;
  }

  closeSpeedMenu(): void {
    this.showSpeedMenu = false;
  }

  selectSpeed(index: number): void {
    this.currentSpeedIndex = index;
    this.setPlaybackSpeed(index);
    this.showSpeedMenu = false;
  }

  getSpeedLabel(): string {
    let labels: string[] = ['0.75x', '1x', '1.25x', '1.5x', '2x'];
    return labels[this.currentSpeedIndex];
  }

  getSpeedLabelByIndex(index: number): string {
    let labels: string[] = ['0.75x', '1x', '1.25x', '1.5x', '2x'];
    return labels[index];
  }

  @Builder
  MySpeedMenu() {
    Menu() {
      MenuItem({ content: '0.75x', symbolEndIcon: this.currentSpeedIndex === 0 ? this.endIconModifier : undefined })
        .selected(this.currentSpeedIndex === 0)
        .contentFont({ size: 16, weight: 500 })
        .contentFontColor(this.currentSpeedIndex === 0 ? '#EE5D1A' : '#E5FFFFFF')
        .onClick(() => {
          this.selectSpeed(0);
        })
      MenuItem({ content: '1.0x', symbolEndIcon: this.currentSpeedIndex === 1 ? this.endIconModifier : undefined })
        .selected(this.currentSpeedIndex === 1)
        .contentFont({ size: 16, weight: 500 })
        .contentFontColor(this.currentSpeedIndex === 1 ? '#EE5D1A' : '#E5FFFFFF')
        .onClick(() => {
          this.selectSpeed(1);
        })
      MenuItem({ content: '1.25x', symbolEndIcon: this.currentSpeedIndex === 2 ? this.endIconModifier : undefined })
        .selected(this.currentSpeedIndex === 2)
        .contentFont({ size: 16, weight: 500 })
        .contentFontColor(this.currentSpeedIndex === 2 ? '#EE5D1A' : '#E5FFFFFF')
        .onClick(() => {
          this.selectSpeed(2);
        })
      MenuItem({ content: '1.5x', symbolEndIcon: this.currentSpeedIndex === 3 ? this.endIconModifier : undefined })
        .selected(this.currentSpeedIndex === 3)
        .contentFont({ size: 16, weight: 500 })
        .contentFontColor(this.currentSpeedIndex === 3 ? '#EE5D1A' : '#E5FFFFFF')
        .onClick(() => {
          this.selectSpeed(3);
        })
      MenuItem({ content: '2.0x', symbolEndIcon: this.currentSpeedIndex === 4 ? this.endIconModifier : undefined })
        .selected(this.currentSpeedIndex === 4)
        .contentFont({ size: 16, weight: 500 })
        .contentFontColor(this.currentSpeedIndex === 4 ? '#EE5D1A' : '#E5FFFFFF')
        .onClick(() => {
          this.selectSpeed(4);
        })
    }
    .padding({ left: 16, right: 16 })
    .menuItemDivider({
      color: $r('sys.color.comp_divider'),
      startMargin: LengthMetrics.vp(12),
      endMargin: LengthMetrics.vp(12),
      strokeWidth: LengthMetrics.px(1)
    })
    .width(224)
    .backgroundColor('#E62E3033')
    .borderRadius(12)
  }

  onSeek(time: number): void {
    if (this.avPlayer) {
      this.avPlayer.seek(time);
    }
  }

  onDidBuild(): void {
    console.info(`${TAG} onDidBuild, filePath=${this.filePath}, isXComponentReady=${this.isXComponentReady}`);
    if (this.filePath && this.isXComponentReady && !this.isInitialized) {
      this.initPlayer();
    }
  }

  onShown(): void {
    console.info(
      `${TAG} onShown, filePath=${this.filePath}, isXComponentReady=${this.isXComponentReady}, isInitialized=${this.isInitialized}`);
    if (this.filePath && this.isXComponentReady && !this.isInitialized) {
      this.initPlayer();
    }
  }

  build() {
    NavDestination() {
      Stack() {
        XComponent({
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .width('100%')
          .height('100%')
          .onLoad(() => {
            console.info(`${TAG} XComponent onLoad`);
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
            this.isXComponentReady = true;
            this.initPlayer();
          })

        Column() {
          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
            }
            .backgroundColor('#1AFFFFFF')
            .width(40)
            .height(40)
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              RouterModule.pop()
            })

            Text(this.videoTitle)
              .fontSize(14)
              .fontWeight(500)
              .lineHeight(19)
              .fontColor('#FFFFFF')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .margin({ left: 8, right: 8 })

            Row() {
              SymbolGlyph($r('sys.symbol.share'))
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
            }
            .backgroundColor('#1AFFFFFF')
            .width(40)
            .height(40)
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              const picker: SharePicker = new SharePicker({
                title: this.videoTitle,
                subTitle: '直播模板',
                coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png',
                createTime: new Date('2025/09-15 08:00:00').getTime(),
                thumbUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png',
                landingPageUrl: 'https://developer.huawei.com/consumer/cn/activity/301757474300821213',
              });

              picker.setSignQQShareDataCB((shareJson: string) => {
                const signData = new QQShareData();
                signData.shareJson = shareJson;
                signData.timestamp = Date.parse(new Date().toString()) / 1000;
                signData.nonce = Math.floor(Math.random() * 100000000);
                signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ=';
                return Promise.resolve(signData);
              })

              try {
                picker.show(this.getUIContext(), {
                  autoClose: true,
                });
              } catch (e) {
                console.error(`${TAG} SharePicker show failed: ${e}`);
              }
            })
          }
          .width('100%')
          .height(56)

          Blank()

          Column() {
            Row() {
              Text(this.formatTime(this.currentTime))
                .fontSize(12)
                .fontColor('#FFFFFF')

              Slider({
                value: this.duration > 0 ? (this.currentTime / this.duration) * 100 : 0,
                min: 0,
                max: 100,
                style: SliderStyle.OutSet
              })
                .layoutWeight(1)
                .blockColor('#EE5D1A')
                .trackColor('rgba(255,255,255,0.3)')
                .selectedColor('#EE5D1A')
                .showTips(false)
                .onChange((value: number) => {
                  let seekTime = Math.floor((value / 100) * this.duration);
                  this.onSeek(seekTime);
                })

              Text(this.formatTime(this.duration))
                .fontSize(12)
                .fontColor('#FFFFFF')
            }
            .width('100%')

            Row() {
              SymbolGlyph(this.isPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play'))
                .fontSize(24)
                .fontColor(['#E6FFFFFF'])
                .onClick(() => {
                  this.togglePlayPause();
                })

              Blank()

              SymbolGlyph($r('sys.symbol.speed_multiple'))
                .fontSize(24)
                .fontColor(['#E6FFFFFF'])
                .bindMenu(this.MySpeedMenu())
            }
            .margin({ top: 8 })
            .width('100%')
          }
          .width('100%')
          .padding({ bottom: 24 })
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: BarVM.instance.staBarH,
          bottom: BarVM.instance.aiBarH
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.filePath = context.pathInfo.param as string;
      console.info(`${TAG} onReady, filePath: ${this.filePath}`);
    })
  }

  formatTime(ms: number): string {
    let totalSeconds = Math.floor(ms / 1000);
    let hours = Math.floor(totalSeconds / 3600);
    let minutes = Math.floor((totalSeconds % 3600) / 60);
    let seconds = totalSeconds % 60;
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds)
      .padStart(2, '0')}`;
  }
}
