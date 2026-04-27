import { ComponentContent } from '@kit.ArkUI';
import { LevelMode } from '@ohos.promptAction';
import { UtilLog } from '@hw-agconnect/util-log';
import { OnNfcChanged } from '../common/nfc/Nfc';
import { getNavPathStack } from '../common/Route';
import { addMineDialog } from '../components/AddMineDialog';
import { renameDialog } from '../components/RenameDialog';
import { nfcCardInfo, NfcInfo } from '../db/NfcCardInfo';
import { AddMineDialogParams, DetailModel, RenameDialogParams } from '../model/Index';
import Util from '../common/Util';
import { PromptActionUtil } from '../common/PromptActionUtil';

@ObservedV2
export class DetailVM {
  private static _instance: DetailVM;
  @Trace data: DetailModel = new DetailModel(0, new NfcInfo());
  @Trace nfcInfo: NfcInfo = new NfcInfo();

  public static get instance() {
    if (!DetailVM._instance) {
      DetailVM._instance = new DetailVM();
    }
    return DetailVM._instance;
  }

  private loadData(uiContext: UIContext) {
    nfcCardInfo.findById(this.data.nfcInfo.id!)
      .then(result => {
        this.nfcInfo = result;
      }).catch((e: Error) => {
      uiContext.getPromptAction().showToast({
        message: '加载失败！',
      });
      getNavPathStack().pop();
    });
  }

  rename(uiContext: UIContext) {
    let params = new RenameDialogParams();
    params.name = this.nfcInfo!.name;
    params.cancel = () => {
      PromptActionUtil.closeDialog(renameContentNode);
    };
    params.confirm = (name: string) => {
      if (Util.isEmpty(name)) {
        uiContext.getPromptAction().showToast({
          message: '请先输入名称',
        });
      } else if (name === this.nfcInfo!.name) {
        PromptActionUtil.closeDialog(renameContentNode);
      } else {
        nfcCardInfo.findByName(name).then(result => {
          if (result) {
            uiContext.getPromptAction().showToast({
              message: '名称重复！',
            });
          } else {
            this.nfcInfo!.name = name;
            nfcCardInfo.updateNfcInfo(this.nfcInfo!).then(result => {
              uiContext.getHostContext()!
                .eventHub
                .emit(OnNfcChanged.name,
                  new OnNfcChanged(this.nfcInfo.type, !this.nfcInfo.dealHistory, this.nfcInfo.isMine));
              uiContext.getPromptAction().showToast({
                message: '修改成功！',
              });
              PromptActionUtil.closeDialog(renameContentNode);
              this.loadData(uiContext);
            }).catch((e: Error) => {
              uiContext.getPromptAction().showToast({
                message: '修改失败！',
              });
            });
          }
        }).catch((e: Error) => {
          uiContext.getPromptAction().showToast({
            message: '修改失败！',
          });
        });
      }
    };
    let renameContentNode: ComponentContent<Object> =
      new ComponentContent(uiContext, wrapBuilder<[RenameDialogParams]>(renameDialog), params);
    PromptActionUtil.setContext(uiContext);
    PromptActionUtil.setContentNode(renameContentNode);
    PromptActionUtil.setOptions({
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'MobileNFC', JSON.stringify(dismissDialogAction.reason));
      },
    });

    PromptActionUtil.openDialog();
  }

  addMine(cardId: string, type: number, uiContext: UIContext) {
    nfcCardInfo.findAllWithMine(type).then(result => {
      if (result.length && result.find(item => item.cardId === cardId)) {
        uiContext.getPromptAction().showToast({
          message: '您已添加过此卡片，请勿重复添加！',
        });
      } else {
        this.nfcInfo!.isMine = true;
        nfcCardInfo.updateNfcInfo(this.nfcInfo!).then(result => {
          uiContext.getHostContext()!
            .eventHub
            .emit(OnNfcChanged.name, new OnNfcChanged(this.nfcInfo.type, true, this.nfcInfo.isMine));


          let params = new AddMineDialogParams();
          params.confirm = () => {
            PromptActionUtil.closeDialog(addMineContentNode);
          };

          let addMineContentNode: ComponentContent<Object> =
            new ComponentContent(uiContext, wrapBuilder<[AddMineDialogParams]>(addMineDialog), params);
          PromptActionUtil.setContext(uiContext);
          PromptActionUtil.setContentNode(addMineContentNode);
          PromptActionUtil.setOptions({
            levelMode: LevelMode.EMBEDDED,
            onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
              UtilLog.info(0xFF00, 'MobileNFC', JSON.stringify(dismissDialogAction.reason));
            },
          });

          PromptActionUtil.openDialog();
          this.loadData(uiContext);
        }).catch((e: Error) => {
          uiContext.getPromptAction().showToast({
            message: '添加失败！',
          });
        });
      }
    }).catch((e: Error) => {
      uiContext.getPromptAction().showToast({
        message: '添加失败！',
      });
    });
  }
}