import { common } from '@kit.AbilityKit';
import { TextReader } from '@kit.SpeechKit';
import { VoiceComponent } from 'attraction_announcement';
import { PlayInfo, SystemUtil } from 'module_base';
import { LocationType } from '../model/GuideInfo';
import { AttractionGuideVM } from '../viewmodel/AttractionGuideVM';

@Extend(Text)
function detailText(wid: number) {
  .width(wid)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis });
}

@ComponentV2
export struct LocationDetailModal {
  vm: AttractionGuideVM = AttractionGuideVM.instance;
  @Require @Param showDetail: boolean;
  @Require @Param distance: string;
  @Require @Param type: number;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Event close: () => void;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Row({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            Image(this.vm.selectedGuide.icon).size({ width: 48, height: 48 }).borderRadius(24);
            if (this.type === LocationType.ATTRACTION) {
              VoiceComponent({
                playInfo: {
                  playId: this.vm.selectedGuide.attractionId.toString(),
                  introduction: this.vm.selectedGuide.introduction,
                  title: this.vm.selectedGuide.name,
                  imageUrl: this.vm.selectedGuide.banner,
                  panelName: '松山湖景区',
                  panelIcon: $r('app.media.app_icon'),
                } as PlayInfo,
              });
            }
          };

          Column({ space: 4 }) {
            Text(this.vm.selectedGuide.name).fontWeight(500).detailText(120);
            if (this.type === LocationType.ATTRACTION) {
              Text('真人讲解 走哪听哪')
                .fontColor('#2EB78A')
                .fontSize(10)
                .padding(2)
                .border({ color: '#2EB78A', width: 1, radius: 4 });
            } else {
              Text(this.vm.selectedGuide.location).opacity(0.6).fontSize(10).detailText(200);
            }
          }.alignItems(HorizontalAlign.Start);
        }.justifyContent(FlexAlign.Start);

        Row({ space: 24 }) {
          Row({ space: 4 }) {
            Image($r('app.media.navigation')).size({ height: 14, width: 14 });

            Text('导航').onClick(() => {
              SystemUtil.routerToPetalMap(this.vm.selectedGuide.latitude, this.vm.selectedGuide.longitude,
                this.vm.selectedGuide.title, this.getUIContext().getHostContext() as common.UIAbilityContext);
            });
          }.alignItems(VerticalAlign.Center);

          if (this.type === LocationType.ATTRACTION) {
            Row({ space: 4 }) {
              Image($r('app.media.scenic_detail')).size({ height: 14, width: 14 });

              Text('详情').onClick(() => {
                TextReader.stop().then(() => {
                  TextReader.release();
                });
                this.mainPathStack.pushPathByName('AttractionDetail', this.vm.selectedGuide.attractionId);
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
      .backgroundColor($r('sys.color.font_on_primary'))
      .width('100%');

      Image($r('app.media.close')).size({ width: 20, height: 20 }).margin({ top: 8, right: 8 }).onClick(() => {
        // 关闭释放播放资源
        TextReader.stop().then(() => {
          TextReader.release();
        });
        this.close();
      });
    };
  }
}