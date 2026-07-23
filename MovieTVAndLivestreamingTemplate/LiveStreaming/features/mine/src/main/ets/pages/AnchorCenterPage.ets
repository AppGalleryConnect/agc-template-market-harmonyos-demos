import { getMyFollower, getMyFollowing, Profile } from '@agctemplate/detail'
import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { Audience, UserInfo } from 'live_interaction'
import { AppStorageV2, NavDestinationModifier, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { AppStorageKeys, BarVM, BreakPoint, BreakPointValue, ColorMode } from '@agctemplate/widgets'
import { ConfigurationConstant, common } from '@kit.AbilityKit'
import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

interface liveModel {
  title: string;
  date: string;
  duration: string;
  img: ResourceStr;
  filePath: string;
  startTimestamp: number;
  audienceCount: number;
  newFansCount: number;
}

interface LiveDataModel {
  title: string;
  number: number;
}

@ComponentV2
export struct AnchorCenterPage {
  @Local audience: Audience = new Audience()
  @Local isMyself: boolean = true
  @Local logoUser: UserInfo = RouterModule.getNavParam<UserInfo>({ url: RouterMap.ANCHOR_CENTER_PAGE })!
  @Local mutualFollow: string[] = []
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local textItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '今日' },
    { text: '近7日' },
    { text: '近30天' },
  ]);
  @Local textSelectedIndex: number = 0;
  @Local anchorLiveItem: liveModel[] = [];
  @Local allRecordings: liveModel[] = [];
  @Local liveDataList: LiveDataModel[] = [
    {
      title: '开播次数',
      number: 0
    },
    {
      title: '观众人数',
      number: 0
    },
    {
      title: '新增粉丝',
      number: 0
    },
    {
      title: '开播时长',
      number: 0
    }
  ]
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier()

  aboutToAppear(): void {
    this.getAudience();
    this.loadLocalRecordings();
  }

  async loadLocalRecordings(): Promise<void> {
    try {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let pathDir = context.filesDir;
      console.info(`[AnchorCenterPage] filesDir: ${pathDir}`);
      let listFileOption: ListFileOptions = {
        recursion: false,
        listNum: 0,
        filter: { suffix: ['.mp4'] }
      };
      let filenames = await fs.listFile(pathDir, listFileOption);
      console.info(`[AnchorCenterPage] found ${filenames?.length ?? 0} mp4 files`);
      if (filenames && filenames.length > 0) {
        let recordings: liveModel[] = [];
        for (let i = 0; i < filenames.length; i++) {
          let filename = filenames[i];
          if (!filename.endsWith('.mp4')) {
            continue;
          }
          let filePath = pathDir + '/' + filename;
          let stat = fs.statSync(filePath);
          let timestampStr = filename.replace('live_', '').replace('.mp4', '');
          let metadataPath = pathDir + '/live_info_' + timestampStr + '.json';
          let title = '直播回放';
          let startTime = stat.mtime;
          let duration = '';
          let metadataFile: fs.File | null = null;
            try {
              metadataFile = fs.openSync(metadataPath, fs.OpenMode.READ_ONLY);
              let buffer = new ArrayBuffer(4096);
              let readLen = fs.readSync(metadataFile.fd, buffer);
              let metadataContent = util.TextDecoder.create('utf-8', { ignoreBOM: true }).decodeWithStream(new Uint8Array(buffer.slice(0, readLen)));
            interface RecordingMetadata {
              title: string;
              startTime: number;
              duration: number;
            }
            let metadata = JSON.parse(metadataContent) as RecordingMetadata;
            if (metadata.title) {
              title = metadata.title;
            }
            if (metadata.startTime) {
              startTime = metadata.startTime;
            }
            if (metadata.duration) {
              let durationSec = Math.floor(metadata.duration / 1000);
              let hours = Math.floor(durationSec / 3600);
              let minutes = Math.floor((durationSec % 3600) / 60);
              if (hours > 0) {
                duration = `${hours} 小时${minutes}分钟`;
              } else {
                duration = `${minutes} 分钟`;
              }
            }
          } catch (e) {
              console.info(`[AnchorCenterPage] no metadata file for ${filename}`);
            } finally {
              if (metadataFile !== null) {
                fs.close(metadataFile);
              }
            }
          let date = new Date(startTime);
          let dateStr = date.toLocaleDateString('zh-CN') + ' ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
          let audienceCount = Math.floor(Math.random() * 500) + 100;
          let newFansCount = Math.floor(Math.random() * 50) + 5;
          recordings.push({
            title: title,
            date: dateStr,
            duration: duration,
            img: $r('app.media.live_image_1'),
            filePath: filePath,
            startTimestamp: startTime,
            audienceCount: audienceCount,
            newFansCount: newFansCount
          });
        }
        if (recordings.length > 0) {
          this.allRecordings = recordings;
        }
      }
      this.filterRecordingsByTimeRange();
    } catch (error) {
      console.error(`[AnchorCenterPage] loadLocalRecordings failed: ${JSON.stringify(error)}`);
      this.anchorLiveItem = [];
    }
  }

  @Monitor('textSelectedIndex')
  onSelectedIndexChange(monitor: IMonitor) {
    this.filterRecordingsByTimeRange();
  }

  filterRecordingsByTimeRange(): void {
    let now = Date.now();
    let rangeStart = 0;
    switch (this.textSelectedIndex) {
      case 0:
        rangeStart = new Date(new Date().setHours(0, 0, 0, 0)).getTime();
        break;
      case 1:
        rangeStart = now - 7 * 24 * 60 * 60 * 1000;
        break;
      case 2:
        rangeStart = now - 30 * 24 * 60 * 60 * 1000;
        break;
    }
    let filteredRecordings = this.allRecordings.filter((item: liveModel) => {
      return item.startTimestamp >= rangeStart;
    });
    let totalDurationMs = 0;
    let totalAudienceCount = 0;
    let totalNewFansCount = 0;
    for (let i = 0; i < filteredRecordings.length; i++) {
      let durationStr = filteredRecordings[i].duration;
      let hourMatch = durationStr.match(/(\d+)\s*小时/);
      let minuteMatch = durationStr.match(/(\d+)\s*分钟/);
      if (hourMatch) {
        totalDurationMs += parseInt(hourMatch[1]) * 60 * 60 * 1000;
      }
      if (minuteMatch) {
        totalDurationMs += parseInt(minuteMatch[1]) * 60 * 1000;
      }
      totalAudienceCount += filteredRecordings[i].audienceCount;
      totalNewFansCount += filteredRecordings[i].newFansCount;
    }
    let totalMinutes = Math.floor(totalDurationMs / 60000);
    this.anchorLiveItem = filteredRecordings;
    this.liveDataList = [
      { title: '开播次数', number: filteredRecordings.length },
      { title: '观众人数', number: totalAudienceCount },
      { title: '新增粉丝', number: totalNewFansCount },
      { title: '开播时长', number: totalMinutes }
    ];
  }

  getMutualConnections(followingList: string[], followersList: string[]): string[] {
    return followingList.filter(id => followersList.includes(id))
  }

  async getAudience() {
    this.audience!.followingList = await getMyFollowing()
    this.audience!.followersList = await getMyFollower()
    this.audience!.id = this.logoUser.id.toString().padStart(7, '0')
    this.audience!.nickName = this.logoUser.name
    this.audience!.avatar = this.logoUser.avatar
    this.audience!.gender = this.logoUser.sex === '女' ? 0 : 1
    this.audience!.bio = this.logoUser.bio
    this.audience!.likesCount = this.logoUser.likesCount
    this.mutualFollow = this.getMutualConnections(this.audience!.followingList, this.audience!.followersList)
  }

  @Builder
  FunctionButton() {
    Row() {
      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row() {
          SymbolGlyph($r('sys.symbol.video_star')).fontSize(16).fontColor([$r('sys.color.font_on_primary')])
          Text('去开播').fontSize(14).fontColor($r('sys.color.font_on_primary')).margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .padding({
          top: 4,
          bottom: 4,
          left: 8,
          right: 8
        })
      }
      .backgroundColor('#EE5D1A')
      .width(78)
      .height(27)
      .borderRadius(14)
    }
    .padding({ right: 30, top: 18.5 })
    .onClick(() => {
      RouterModule.push({ url: RouterMap.Camera_Page })
    })
  }

  build() {
    NavDestination() {
      Profile({
        audience: this.audience!,
        isMyself: this.isMyself,
        mutualFollow: this.mutualFollow,
        popCall: () => {
          this.audience = new Audience()
          this.getAudience()
        }
      })
      Scroll() {
        Column() {
          Column({ space: 12 }) {
            Text('直播数据')
              .fontSize(18)
              .fontWeight(700)
              .fontColor($r('sys.color.font_primary'))
              .width('100%')

            Row({ space: 8 }) {
              TabSegmentButtonV2({
                items: this.textItems,
                selectedIndex: this.textSelectedIndex!!,
                onItemClicked: (idx: number) => {
                  this.textSelectedIndex = idx;
                },
              })
                .width(this.breakPoint.value === BreakPointValue.SM ? 328 : 448)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            Grid() {
              ForEach(this.liveDataList, (item: LiveDataModel) => {
                GridItem() {
                  Column({ space: 4 }) {
                    Text(item.number.toString())
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                    Text(item.title)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .width('100%')
            .height(74)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(12)
            .padding(12)
          }
          .margin({ bottom: 24 })

          Column({ space: 12 }) {
            Text('直播回放')
              .fontSize(18)
              .fontWeight(700)
              .fontColor($r('sys.color.font_primary'))
              .width('100%')

            Column({ space: 12 }) {
              ForEach(this.anchorLiveItem, (item: liveModel) => {
                Row({ space: 12 }) {
                  Image(item.img)
                    .width(120)
                    .aspectRatio(16 / 9)
                    .borderRadius(8)

                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(14)
                      .fontWeight(500)
                      .lineHeight(19)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 8 }) {
                      Text(item.date)
                        .fontSize(10)
                        .lineHeight(13)
                        .fontColor($r('sys.color.font_secondary'))
                      Text(item.duration)
                        .fontSize(10)
                        .lineHeight(13)
                        .fontColor($r('sys.color.font_secondary'))
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius(12)
                .padding(8)
                .onClick(() => {
                  if (item.filePath) {
                    RouterModule.push({ url: RouterMap.VIDEO_RECORD_PLAY_PAGE, param: item.filePath });
                  }
                })
              })
            }
          }
          .width('100%')
        }
        .padding({
          left: 16,
          right: 16,
          bottom: 16,
          top: 24
        })
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .backgroundImage(this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '' :
      $r('app.media.profile_background'))
    .backgroundImageSize(ImageSize.FILL)
    .title('主播中心')
    .attributeModifier(this.navDestinationModifier)
    .padding({ top: BarVM.instance.staBarH })
    .align(Alignment.Top)
    .menus(this.FunctionButton())
  }
}

@Builder
export function AnchorCenterBuilder() {
  AnchorCenterPage()
}