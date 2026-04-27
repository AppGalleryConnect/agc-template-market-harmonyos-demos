import { wifiManager } from '@kit.ConnectivityKit';
import { common } from '@kit.AbilityKit';
import { UtilLog as Logger, UtilLog } from '@hw-agconnect/util-log';
import { getInstance, RouterMap, setPathStack } from '../util/Route';
import { CustomTitle } from '../components/CustomTitle';
import { CastPageVM } from '../viewModels/CastPageVM';
import { PermissionUtil } from '../util/PermissionUtil';
import { AudioPicker } from '../components/AudioPicker';
import { CastService } from '../service/CastService';
import { MediaData, MediaType } from '../model/Index';
import { CastPicker } from '../components/CastPicker';
import { toastUtil } from '../util/ToastUtil';


@Builder
export function CastPageBuilder() {
  CastPage();
}

@ComponentV2
export struct CastPage {
  castService: CastService = CastService.getInstance();
  vm: CastPageVM = CastPageVM.instance;
  ctx: Context = this.getUIContext().getHostContext() as Context;
  uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.vm.getWifiInfo();
    PermissionUtil.requestPermissions(['ohos.permission.READ_IMAGEVIDEO'], this.uiContext);
    try {
      wifiManager.on('wifiConnectionChange', this.vm.getWifiInfo);
    } catch (e) {
      UtilLog.error(`wifiConnectionChange listen failed with error ${JSON.stringify(e)}`);
    }
  }

  aboutToDisappear(): void {
    try {
      wifiManager.off('wifiConnectionChange', this.vm.getWifiInfo);
    } catch (e) {
      UtilLog.error(`wifiConnectionChange listen off failed with error ${JSON.stringify(e)}`);
    }
  }

  build() {
    NavDestination() {
      CustomTitle({ title: '本地影音投屏' });
      Column({ space: 16 }) {
        Column() {
          Row({ space: 8 }) {
            Image(this.vm.connState === wifiManager.ConnState.CONNECTED ? $r('app.media.wifi_success') :
              $r('app.media.wifi_minus')).width(24);
            Text(this.vm.connState === wifiManager.ConnState.CONNECTED ? this.vm.wifiName : '没有网络')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'));
          }.width('100%').height(40);

          CastPicker({
            text: this.castService.castStatusModel.isCasting ? this.castService.castStatusModel.currentDeviceName :
              '开始连接设备',
          });
        }
        .width('100%')
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .padding({ left: 12, right: 12, bottom: 12 });


        Grid() {
          GridItem() {
            Column({ space: 14 }) {
              Image($r('app.media.ic_video_file')).width(48).height(48);
              Text('视频')
                .fontColor('rgba(162, 101, 255, 1)')
                .barTextExtend();

            }.toolBarExtend()
            .backgroundColor('rgba(233, 220, 255, 1)');
          }.onClick(() => {
            if (CastService.getInstance().castStatusModel.isCasting) {
              getInstance().pushPathByName(RouterMap.LIST, 0);
            } else {
              toastUtil.showToast('请先连接投屏设备');
            }
          });


          GridItem() {
            AudioPicker({
              isCasting: this.castService.castStatusModel.isCasting,
              onSelect: (castParams) => {
                getInstance().pushPathByName(RouterMap.CONTROLLER, castParams);
              },
            }) {
              Column({ space: 14 }) {
                Image($r('app.media.ic_audio_file')).width(48).height(48);
                Text('音乐')
                  .fontColor('rgba(54, 165, 44, 1)')
                  .barTextExtend();

              }.toolBarExtend()
              .backgroundColor('rgba(219, 239, 219, 1)');
            };
          };

        }.columnsTemplate('1fr 1fr ')
        .columnsGap(8);

      }.layoutWeight(1)
      .padding({ top: 8, left: 16, right: 16 });

    }.hideTitleBar(true)
    .linearGradient({
      angle: 180,
      colors: [['rgba(191, 208, 255, 1)', 0.0], ['rgba(255, 255, 255, 0)', 1.0]],
    })
    .onShown(async () => {
      await this.vm.fetchCover(this.ctx);
      this.castService.init(this.uiContext).then(() => {
        if (!this.vm.appCover) {
          return;
        }
        const coverData: MediaData = {
          name: '投屏工具',
          head: this.vm.appCover,
          duration: 1,
          mediaType: MediaType.VIDEO,
          url: '',
          sortId: 1,
          id: '1',
        };
        CastService.getInstance().setAVMetadata(coverData, 0);
      });
    })
    .onReady((ctx) => {
      toastUtil.setUiContext(this.getUIContext());
      setPathStack(ctx.pathStack);
      Logger.setGlobalConfig({
        tag: 'cast_tool', // 指定日志标识
        domain: 0xff00, // 日志对应的领域标识
        open: true,
        showStack: false,
        showBorder: false,
        showDivider: false,
      });
    });
  }
}


@Extend(Text)
function barTextExtend() {
  .fontSize($r('sys.float.Subtitle_L'))
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.End)
  .width('100%');
}

@Extend(Column)
function toolBarExtend() {
  .padding({
    left: 10,
    top: 18,
    right: 16,
    bottom: 16,
  })
  .borderRadius(20)
  .alignItems(HorizontalAlign.Start);
}
