import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import arEngine from 'libentry.so';
import { ARMeasureVM } from '../viewmodel/ARMeasureVM';
import { PromptActionUtil } from '../util/PromptActionUtil';
import { MeasureType, MEASURE_TYPE_LIST } from '../constant/Constant';
import { Hint, History, MeasureModule, MeasureRecord } from '../model/Index';
import { instructionHint } from '../component/InstructionHint';
import { clearHistoryHint } from '../component/ClearHistoryHint';
import { viewRecordHint } from '../component/ViewRecordHint';

@Builder
export function ARMeasureBuilder() {
  ARMeasure();
}

let getUIContext: UIContext;
let hintContentNode: ComponentContent<Object>;
let clearHistoryNode: ComponentContent<Object>;
let recordContentNode: ComponentContent<Object>;

@ComponentV2
export struct ARMeasure {
  vm: ARMeasureVM = ARMeasureVM.instance;
  @Local hasPermission: boolean = false;
  @Local context: Context = this.getUIContext().getHostContext() as Context;

  aboutToAppear(): void {
    getUIContext = this.getUIContext();
    hintContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[number]>(instructionHint), MeasureType.VOLUME);
    clearHistoryNode =
      new ComponentContent(getUIContext, wrapBuilder<[Hint]>(clearHistoryHint), new Hint());
    recordContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[MeasureRecord]>(viewRecordHint), new MeasureRecord());
  }

  aboutToDisappear(): void {
    this.vm.saveMeasureRecord();
    this.vm.semanticDenseMode = MeasureType.VOLUME;
    hintContentNode.update(this.vm.semanticDenseMode);
    // 模式切换
    this.vm.switchMode(this.context);
  }

  showHintDialog(uiContext: UIContext, node: ComponentContent<Object>) {
    PromptActionUtil.setContext(uiContext);
    PromptActionUtil.setContentNode(node);
    PromptActionUtil.setOptions({
      alignment: DialogAlignment.Top,
      offset: { dx: 0, dy: 160 },
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'ARMeasure', JSON.stringify(dismissDialogAction.reason));
      },
    });
    PromptActionUtil.openDialog();
  }

  showDialog(node: ComponentContent<Object>) {
    PromptActionUtil.setContext(getUIContext);
    PromptActionUtil.setContentNode(node);
    PromptActionUtil.setOptions({
      levelMode: LevelMode.OVERLAY,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'ARMeasure', JSON.stringify(dismissDialogAction.reason));
      },
    });
    PromptActionUtil.openDialog();
  }

  @Builder
  VolumeHistoryPicker() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.vm.measureHistory.list, (item: History) => {
          ListItem() {
            Row() {
              Row({ space: 16 }) {
                Image(item.type === MeasureType.VOLUME ? $r('app.media.volume_inactive') :
                  $r('app.media.space_inactive'))
                  .size({ width: 24, height: 24 });

                Column({ space: 2 }) {
                  Text(this.vm.getText(item.record, item.type))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('calc(100% - 60vp)');
                  Text(this.vm.getFormatTime(item.time)).fontSize(14).fontColor($r('sys.color.font_secondary'));
                }.alignItems(HorizontalAlign.Start);
              };

              Image($r('app.media.ar_chevron_right')).size({ width: 12, height: 24 });
            }
            .borderRadius(20)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding(12)
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              let data = this.vm.getText(item.record, item.type);
              let record: MeasureRecord = {
                type: item.type,
                record: data,
                copyCallBack: (): void => {
                  this.vm.copyText(this.getUIContext(), data);
                },
              };
              recordContentNode.update(record);
              this.showDialog(recordContentNode);
            });
          };
        }, (item: History) => item.time.toString());
      }.padding(16).height('80%');

      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.clean_measure_history')).size({ width: 24, height: 24 });
          Text('清除全部记录')
            .fontColor($r('sys.color.font_on_primary'));
        }.onClick(() => {
          let hint: Hint = {
            message: '是否清除全部测量记录？',
            confirmCallBack: (): void => {
              this.vm.measureHistory.list = [];
              PromptActionUtil.closeDialog(clearHistoryNode);
            },
            cancelCallBack: () => {
              PromptActionUtil.closeDialog(clearHistoryNode);
            },
          };
          clearHistoryNode.update(hint);
          this.showDialog(clearHistoryNode);
        });
      }
      .borderRadius(20)
      .width('calc(100% - 32vp)')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .padding({ top: 8, bottom: 8 })
      .margin({ bottom: 32 });
    }.height('100%').justifyContent(FlexAlign.SpaceBetween);
  }

  build(): void {
    NavDestination() {
      Image($r('app.media.ar_history'))
        .size({ width: 40, height: 40 })
        .position({ left: 16, top: 64 })
        .zIndex(2)
        .onClick(() => {
          this.vm.isShowHistoryPicker = true;
        })
        .bindSheet($$this.vm.isShowHistoryPicker, this.VolumeHistoryPicker(), {
          title: { title: '测量记录' },
          preferType: SheetType.CENTER,
          height: '60%',
        });

      Image($r('app.media.ar_hint'))
        .size({ width: 40, height: 40 })
        .position({ right: 16, top: 64 })
        .zIndex(3)
        .onClick(() => {
          this.showHintDialog(getUIContext, hintContentNode);
        });

      Column({ space: 12 }) {
        ForEach(MEASURE_TYPE_LIST, (item: MeasureModule) => {
          Image(item.id === this.vm.semanticDenseMode ? item.activeIcon : item.defaultIcon)
            .size({ width: 40, height: 40 }).onClick(() => {
            if (this.vm.semanticDenseMode !== item.id) {
              // 切换保存数据
              this.vm.saveMeasureRecord();
              this.vm.semanticDenseMode = item.id;
              hintContentNode.update(this.vm.semanticDenseMode);
              // 模式切换
              this.vm.switchMode(this.context);
            }
          });
        });
      }.zIndex(4).position({ right: 16, bottom: 160 });

      if (this.vm.hasMeasured) {
        Column({ space: 12 }) {
          Text('测量结果').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_on_primary'));

          Text(this.vm.getText(this.vm.semanticDenseMode === MeasureType.VOLUME ? this.vm.volumeData :
            this.vm.spaceData, this.vm.semanticDenseMode))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'));

          Text('Tips：您可以点击屏幕手动保存测试结果')
            .fontSize(12)
            .fontColor($r('sys.color.font_on_secondary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 12 });
        }
        .position({ left: 16, top: 120 })
        .backgroundColor($r('sys.color.mask_fourth'))
        .width('calc(100% - 32vp)')
        .borderRadius(20)
        .padding(24)
        .zIndex(5)
        .alignItems(HorizontalAlign.Center);
      } else {
        Text(this.vm.semanticDenseMode === MeasureType.VOLUME ? '缓缓移动设备，覆盖物体长宽高所在面' :
          '缓缓移动设备，覆盖空间各个测量面')
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(14)
          .textAlign(TextAlign.Center)
          .position({ left: 16, top: 120 })
          .backgroundColor($r('sys.color.mask_fourth'))
          .width('calc(100% - 32vp)')
          .borderRadius(20)
          .zIndex(5)
          .padding({
            top: 8,
            bottom: 8,
            left: 12,
            right: 12,
          });
      }

      if (this.vm.semanticDenseMode === MeasureType.VOLUME) {
        XComponent({ id: this.vm.volumeIdStr, type: XComponentType.SURFACE, libraryname: 'entry' })
          .opacity(0.2)
          .onLoad(() => {
            if (this.vm.isSupported) {
              this.vm.load(this.vm.volumeIdStr);
            }
          })
          .onDestroy(() => {
            this.vm.destroy();
          });
      } else {
        XComponent({ id: this.vm.spaceIdStr, type: XComponentType.SURFACE, libraryname: 'entry' })
          .opacity(0.2)
          .onLoad(() => {
            if (this.vm.isSupported) {
              this.vm.load(this.vm.spaceIdStr);
            }
          })
          .onDestroy(() => {
            this.vm.destroy();
          });
      }
    }
    .onClick(() => {
      if (this.vm.hasMeasured) {
        this.vm.saveManually();
      }
    })
    .onAppear(() => {
      this.vm.init(this.context, this.vm.volumeIdStr);
    })
    .onWillDisappear(async () => {
      arEngine.stop(this.vm.volumeIdStr);
      arEngine.stop(this.vm.spaceIdStr);
    })
    .onShown(() => {
      if (this.vm.isSupported) {
        arEngine.show(this.vm.volumeIdStr);
      }
    })
    .onHidden(() => {
      arEngine.hide(this.vm.volumeIdStr);
      arEngine.hide(this.vm.spaceIdStr);
    })
    .onReady((context: NavDestinationContext) => {
      this.vm.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      this.vm.pageInfos.pop();
      return true;
    })
    .hideTitleBar(true)
    .hideBackButton(true);
  }
}