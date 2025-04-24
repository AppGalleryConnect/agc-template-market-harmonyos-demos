import { MediaService, PlayControlComponent, PlayInfo, voiceList } from 'audio';
import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { Constant, routerToPetalMap } from 'common';
import { LocationType } from '../model/GuideInfo';
import { GuideVM } from '../viewmodel/GuideVM';

@Extend(Text)
function detailText(wid: number) {
  .width(wid)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis });
}

@ComponentV2
export struct LocationDetailModal {
  vm: GuideVM = GuideVM.instance;
  @Require @Param showDetail: boolean;
  @Require @Param distance: string;
  @Require @Param type: number;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Consumer('selectedGuide') selectedGuide: ESObject;
  @Event close: () => void;
  private playInfo: PlayInfo = AppStorageV2.connect(PlayInfo, 'playInfo', () => new PlayInfo())!;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Row({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            Image(this.selectedGuide.icon).size({ width: 48, height: 48 }).borderRadius(24);
            if (this.type === LocationType.ATTRACTION) {
              PlayControlComponent({ isPlay: this.playInfo.isPlay, url: this.selectedGuide.audio, isGuide: true })
                .hitTestBehavior(HitTestMode.Transparent);
            }
          };

          Column({ space: 4 }) {
            Text(this.selectedGuide.name).fontWeight(500).detailText(120);
            if (this.type === LocationType.ATTRACTION) {
              Text('真人讲解 走哪听哪')
                .fontColor('#2EB78A')
                .fontSize(10)
                .padding(2)
                .border({ color: '#2EB78A', width: 1, radius: 4 });
            } else {
              Text(this.selectedGuide.location).opacity(0.6).fontSize(10).detailText(200);
            }
          }.alignItems(HorizontalAlign.Start);
        }.justifyContent(FlexAlign.Start);

        Row({ space: 24 }) {
          Row({ space: 4 }) {
            Image($r('app.media.navigation')).size({ height: 14, width: 14 });

            Text('导航').onClick(() => {
              routerToPetalMap(this.selectedGuide.latitude, this.selectedGuide.longitude,
                this.selectedGuide.title, getContext(this) as common.UIAbilityContext);
            });
          }.alignItems(VerticalAlign.Center);

          if (this.type === LocationType.ATTRACTION) {
            Row({ space: 4 }) {
              Image($r('app.media.scenic_detail')).size({ height: 14, width: 14 });

              Text('详情').onClick(() => {
                MediaService.getInstance().releaseAvPlayer();
                this.mainPathStack.pushPathByName('AttractionDetail', this.selectedGuide.attractionId);
              });
            };
          }
        };
      }
      .clip(true)
      .height(100)
      .padding(12)
      .borderRadius(8)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
      .width(Constant.FULL_PERCENT);

      Image($r('app.media.close')).size({ width: 20, height: 20 }).margin({ top: 8, right: 8 }).onClick(() => {
        // 关闭释放播放资源
        MediaService.getInstance().releaseAvPlayer()
        this.close();
      });
    };
  }
}