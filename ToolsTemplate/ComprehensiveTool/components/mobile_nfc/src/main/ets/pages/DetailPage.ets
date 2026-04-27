import { LevelMode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { ACTION_TYPE } from '../common/Enum';
import { getNfcCardBgImg } from '../common/nfc/Nfc';
import { PromptActionUtil } from '../common/PromptActionUtil';
import { getNavPathStack } from '../common/Route';
import Util from '../common/Util';
import { ActionModel, DetailModel } from '../model/Index';
import { DetailVM } from '../viewmodel/DetailVM';

let uIContext: UIContext;

@Builder
export function DetailPageBuilder() {
  DetailPage();
}

@ComponentV2
struct DetailPage {
  vm: DetailVM = DetailVM.instance;

  aboutToAppear(): void {
    uIContext = this.getUIContext();
    PromptActionUtil.setOptions({
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'NFCDetailPage', JSON.stringify(dismissDialogAction.reason));
      },
    });
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Stack({ alignContent: Alignment.TopStart }) {
                Image(getNfcCardBgImg(this.vm.nfcInfo.type)).size({ width: '100%', height: 186 })
                  .fitOriginalSize(true);
                Row({ space: 8 }) {
                  Text(this.vm.nfcInfo?.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_emphasize'))
                    .fontSize(17);

                  Image($r('app.media.ic_edit')).size({ width: 16, height: 16 });
                }.padding(12).onClick(() => {
                  PromptActionUtil.setContext(this.getUIContext());
                  this.vm.rename(uIContext);
                });
              };

              this.infoItemBuilder($r('app.media.ic_detail_time'), '添加时间',
                Util.getFormatDateStr(this.vm.nfcInfo!.ltime, 'yyyy-MM-dd HH:mm:ss'));
              if (this.vm.nfcInfo?.balance === -1) {
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_detail_id'), '卡片ID', this.vm.nfcInfo!.cardId.toUpperCase());
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_detail_memory'), '内存大小',
                  this.vm.nfcInfo!.dataSize.toString());
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_detail_sector'), '扇区数', this.vm.nfcInfo!.section.toString());
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_detail_block'), '总块数', this.vm.nfcInfo!.blocks.toString());
                Divider().margin({ top: 12 });
              } else {
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_transport_card_id'), '卡号',
                  this.vm.nfcInfo!.cardId.toUpperCase());
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_balance'), '余额（元）', this.vm.nfcInfo!.balance.toFixed(2));
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_city'), '城市', this.vm.nfcInfo!.city);
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_release_time'), '发行日期', this.vm.nfcInfo!.issuing);
                Divider().margin({ top: 12 });
                this.infoItemBuilder($r('app.media.ic_detail_block'), '有效日期', this.vm.nfcInfo!.effective);
                Divider().margin({ top: 12 });
              }
            };

            if (this.vm.nfcInfo?.balance === -1) {
              Row() {
                Row() {
                  Image($r('app.media.ic_detail_sector_detail')).size({ width: 16, height: 16 });
                  Text('扇区详情').fontSize(14).opacity(0.9);
                };

                Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
              }.width('100%').margin({ top: 8, bottom: 24 }).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
                getNavPathStack()
                  .pushPathByName('SectorDetailPage', JSON.parse(this.vm.nfcInfo.sectionInfo) as string[][]);
              });

              if (this.vm.nfcInfo.isMine) {
                Button('克隆卡片')
                  .width('100%')
                  .height(40)
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('sys.color.confirm'))
                  .onClick(() => {
                    getNavPathStack()
                      .pushPathByName('ActionPage',
                        new ActionModel(ACTION_TYPE.ACTION_CLONE, undefined, this.vm.nfcInfo));
                  });
              } else {
                Button('保存到卡包')
                  .width('100%')
                  .height(40)
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('sys.color.background_emphasize'))
                  .onClick(() => {
                    this.vm.addMine(this.vm.nfcInfo?.cardId ?? '', this.vm.nfcInfo?.type ?? 0, uIContext);
                  });
              }
            }
          };
        }
        .width('100%')
        .scrollBar(BarState.Off);
      }
      .width('100%')
      .height('100%')
      .padding(16);
    }.title('卡片详情').onReady((ctx) => {
      this.vm.data = ctx.pathInfo.param as DetailModel;
      this.vm.nfcInfo = this.vm.data.nfcInfo;
    });
  }

  @Builder
  infoItemBuilder(icon: Resource, title: string, desc: string) {
    Row({ space: 12 }) {
      Row({ space: 8 }) {
        Image(icon).size({ width: 16, height: 16 }).fitOriginalSize(true);
        Text(title)
          .fontSize(14)
          .opacity(0.9)
          .fontColor($r('sys.color.font_primary'));
      };

      Text(desc)
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'));
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 12 });
  }
}