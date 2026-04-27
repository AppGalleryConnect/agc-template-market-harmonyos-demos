import { HashSet } from '@kit.ArkTS';
import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { getMyNfcName, getNfcItemImg, getNfcName, OnNfcChanged } from '../common/nfc/Nfc';
import { NfcInfo, nfcCardInfo } from '../db/NfcCardInfo';
import { delDialog, DelDialogParams } from '../components/DelDialog';
import { getNavPathStack } from '../common/Route';
import { ActionModel, DetailModel } from '../model/Index';
import { ACTION_TYPE, PAGE_TYPES } from '../common/Enum';
import { CardListVM } from '../viewmodel/CardListVM';
import { PromptActionUtil } from '../common/PromptActionUtil';

@ComponentV2
export struct CardAllView {
  vm: CardListVM = CardListVM.instance;
  @Param @Require index: number;
  @Param @Require nfcType: number;
  @Param @Require editMode: boolean;
  @Param @Require isShowTitle: boolean;
  @Param @Require clonePage: boolean = false;
  @Event changeEditMode: (isEdit: boolean) => void = (isEdit: boolean) => {
  };

  aboutToAppear(): void {
    this.loadData();
    this.getUIContext().getHostContext()!.eventHub.on(OnNfcChanged.name, (result: OnNfcChanged) => {
      if (result.mine && this.nfcType === result.nfcType) {
        this.loadData();
      }
    });
  }

  onEditModeChange(changedPropertyName: string) {
    if (!this.editMode) {
      this.vm.checked = new HashSet();
      this.vm.allCheck = false;
    }
  }

  loadData() {
    nfcCardInfo.findAllWithMine(this.nfcType).then(result => {
      this.vm.data = result;
      if (this.vm.data && this.vm.data.length > 0) {
        if (!this.editMode) {
          this.changeEditMode(false);
        }
      } else {
        this.changeEditMode(false);
      }
    }).catch((e: Error) => {
      this.vm.data = [];
      this.changeEditMode(false);
    });
  }

  private delAll() {
    if (this.vm.checked.isEmpty()) {
      this.getUIContext().getPromptAction().showToast({
        message: '请先选择记录！',
      });
      return;
    }
    let params = new DelDialogParams();
    params.cancel = () => {
      PromptActionUtil.closeDialog(delContentNode);
    }
    params.confirm = () => {
      nfcCardInfo.deleteNfcInfoByIds(this.vm.checked, false)
        .then(result => {
          this.getUIContext().getPromptAction().showToast({
            message: '删除成功！',
          });
          PromptActionUtil.closeDialog(delContentNode);
          this.loadData();
        }).catch((e: Error) => {
        this.getUIContext().getPromptAction().showToast({
          message: '删除失败！',
        });
      });
    };
    let uiContext = this.getUIContext();
    let delContentNode: ComponentContent<Object> =
      new ComponentContent(this.getUIContext(), wrapBuilder<[DelDialogParams]>(delDialog), params);
    PromptActionUtil.setContext(uiContext);
    PromptActionUtil.setContentNode(delContentNode);
    PromptActionUtil.setOptions({
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'MobileNFC', JSON.stringify(dismissDialogAction.reason));
      },
    });

    PromptActionUtil.openDialog();
  }

  build() {
    Column() {
      if (this.isShowTitle) {
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.chevron_left')).size({ width: 40, height: 40 }).onClick(() => {
              getNavPathStack().pop();
            });
            Text(getMyNfcName(this.nfcType)).fontSize(20).fontWeight(FontWeight.Bold).opacity(0.9);
          };

          if (this.vm.data.length) {
            Image(this.editMode ? $r('app.media.ic_edit_cancel') : $r('app.media.ic_edit_card'))
              .size({ width: 40, height: 40 })
              .onClick(() => {
                this.changeEditMode(!this.editMode);
              });
          }
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 });
      }

      Column() {
        if (this.vm.data && this.vm.data.length > 0) {
          Column() {
            List({ space: 16 }) {
              ForEach(this.vm.data, (item: NfcInfo) => {
                ListItem() {
                  Stack({ alignContent: Alignment.TopStart }) {
                    Image(getNfcItemImg(item.type)).size({ width: '100%', height: 186 }).fitOriginalSize(true);
                    Row() {
                      Text(item.name)
                        .fontSize(20)
                        .fontColor($r('sys.color.font_emphasize'))
                        .fontWeight(FontWeight.Medium);

                      Checkbox()
                        .select(this.vm.checked.has(item.id))
                        .onClick(() => {
                          if (this.vm.checked.has(item.id)) {
                            this.vm.checked.remove(item.id);
                          } else {
                            this.vm.checked.add(item.id);
                          }
                          this.vm.updateCheckAllState();
                        })
                        .visibility(this.editMode ? Visibility.Visible : Visibility.None);
                    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(12);
                  }
                  .borderRadius(16)
                  .onClick(() => {
                    if (this.editMode) {
                      if (this.vm.checked.has(item.id)) {
                        this.vm.checked.remove(item.id);
                      } else {
                        this.vm.checked.add(item.id);
                      }
                      let checked: HashSet<number> = new HashSet();
                      for (let valuesElement of this.vm.checked.values()) {
                        checked.add(valuesElement);
                      }
                      this.vm.checked = checked;
                      this.vm.updateCheckAllState();
                    } else {
                      getNavPathStack()
                        .pushPathByName('DetailPage', new DetailModel(PAGE_TYPES.PAGE_TYPE_HISTORY, item));
                    }
                  });
                }.width('100%');
              }, (item: NfcInfo) => item.name);
            }.width('100%').height('calc(100% - 80vp)')
            .scrollBar(BarState.Off);

            if (!this.clonePage) {
              if (this.editMode) {
                Row() {
                  Column({ space: 4 }) {
                    Image($r('app.media.ic_select_all')).size({ width: 24, height: 24 });
                    Text('全选').fontSize(10).fontColor($r('sys.color.font_secondary'));
                  }.width('50%').alignItems(HorizontalAlign.Center).onClick(() => this.vm.checkAll());


                  Column({ space: 4 }) {
                    Image($r('app.media.ic_delete_card')).size({ width: 24, height: 24 });
                    Text('删除').fontSize(10).fontColor($r('sys.color.font_secondary'));
                  }.width('50%').alignItems(HorizontalAlign.Center).onClick(() => this.delAll());
                };
              } else {
                Button('读取卡片')
                  .width('100%')
                  .height(40)
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('sys.color.background_emphasize'))
                  .onClick(() => {
                    getNavPathStack()
                      .pushPathByName('ActionPage', new ActionModel(ACTION_TYPE.ACTION_READ, this.nfcType!));
                  });
              }
            }
          }.height('100%').justifyContent(FlexAlign.SpaceBetween);
        } else {
          Column() {
            Image($r('app.media.ic_nonecard')).size({ width: 120, height: 120 })
              .fitOriginalSize(true).margin({ bottom: 10 });
            Text('暂无卡片').fontColor($r('sys.color.font_secondary')).opacity(0.6).margin({ bottom: 8 });
            if (this.clonePage) {
              Text('如需克隆卡片，请先读取卡片并添加至我的卡包')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ bottom: 16 });
            } else {
              Text('可以先去添加自己的' + getNfcName(this.nfcType))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ bottom: 16 });
            }
            Button('去读取')
              .borderRadius(14)
              .size({ width: 72, height: 28 })
              .padding({
                left: 8,
                right: 8,
                top: 4,
                bottom: 4,
              })
              .margin({ top: 6 })
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .onClick(() => {
                getNavPathStack().pushPathByName('ActionPage', new ActionModel(ACTION_TYPE.ACTION_READ, this.nfcType!));
              });
          }.width('100%')
          .height('100%')
          .margin({ top: 80 });
        }
      }.width('100%').padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 28,
      })
      .height('100%')
      .justifyContent(FlexAlign.Start);
    };
  }
}