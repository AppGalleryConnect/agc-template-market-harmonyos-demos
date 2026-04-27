import { common } from '@kit.AbilityKit';
import { CastingLayer } from '../components/CastingLayer';
import { CastService } from '../service/CastService';
import { CastControllerPageVM } from '../viewModels/CastControllerPageVM';
import { AudioPicker } from '../components/AudioPicker';
import { VideoList } from '../components/VideoList';
import { getInstance, RouterMap } from '../util/Route';
import { MediaType } from '../model/Index';


@Builder
export function CastControllerPageBuilder() {
  CastControllerPage();
}


@ComponentV2
export struct CastControllerPage {
  castService: CastService = CastService.getInstance();
  vm: CastControllerPageVM = CastControllerPageVM.instance;

  // 链接断开后退出
  @Monitor('castService.castStatusModel.isCasting')
  onStatusChange(monitor: IMonitor) {
    if (!this.castService.castStatusModel.isCasting) {
      getInstance().popToName(RouterMap.HOME);
    }
  }

  @Builder
  videoListBuilder() {
    Column() {
      VideoList({
        onSelect: (param) => {
          this.vm.isVideoListShow = false;
          this.vm.changeFile(param);
        },
      });
    }.padding({ top: 8, left: 16, right: 16 });
  }

  aboutToAppear(): void {
    this.castService.init(this.getUIContext().getHostContext() as common.UIAbilityContext);
    this.castService.registerSessionListener(this.vm);
    this.vm.getRouteParm();
    this.castService.setAVMetadata(this.vm.mediaList[this.vm.currentIndex],
      this.vm.mediaList[this.vm.currentIndex].duration);
    this.castService.play();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          CastingLayer({
            title: this.vm.mediaList[this.vm.currentIndex].name,
            castService: this.castService,
            isSwitch: this.vm.mediaType === MediaType.VIDEO,
            onBack: () => {
              this.castService.pause();
              getInstance().pop();
            },
            onPlayNext: () => {
              this.vm.onPlayNext();
            },
            onPlayPre: () => {
              this.vm.onPlayPre();
            },
          });
        }.layoutWeight(1);

        Row() {
          Text(`文件名称：${this.vm.mediaList[this.vm.currentIndex].name}`)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .width('calc(100% - 120vp)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.MARQUEE });

          if (this.vm.mediaType === MediaType.VIDEO) {
            Button('列表')
              .btnExtend()
              .onClick(() => {
                this.vm.isVideoListShow = true;
              })
              .bindSheet($$this.vm.isVideoListShow, this.videoListBuilder, {
                title: {
                  title: '文件列表',
                },
                height: 592,
                preferType: SheetType.CENTER,
              });
          } else {
            AudioPicker({
              isCasting: this.castService.castStatusModel.isCasting,
              onSelect: (param) => {
                this.vm.changeFile(param);
              },
              onError: () => {
                this.castService.play();
              },
              onPicker: () => {
                this.castService.pause();
              },
            }) {
              Button('列表')
                .btnExtend();
            };
          }


        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('sys.color.background_tertiary'));
      }
      .width('100%')
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .backgroundColor($r('sys.color.background_primary'));

    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.background_tertiary'))
    .onBackPressed(() => {
      this.castService.pause();
      return false;
    });
  }
}


@Extend(Button)
function btnExtend() {
  .width(72)
  .height(28)
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Body_M'))
  .backgroundColor('rgba(0, 0, 0, 0.05)');
}
