import { PrivacyPwdBuilderParams } from '../commons/Interface';
import { privacyPasswordSettingDialogBuilder } from '../components/PrivacyPasswordSettingDialog';
import { privacyPwdInputDialogBuilder } from '../components/PrivacyPwdInputDialog';
import { PopViewUtils } from './PopViewUtils';


@ObservedV2
export class DiaryUtil {
  private static _instance: DiaryUtil;

  public static get instance() {
    if (!DiaryUtil._instance) {
      DiaryUtil._instance = new DiaryUtil();
    }
    return DiaryUtil._instance;
  }
  // 打开设置隐私密码弹框
  openPrivacyPasswordDialog(callback: (password: string) => void) {
    let builderParams: PrivacyPwdBuilderParams = {
      confirm: (password: string = '') => {
        callback?.(password)
        PopViewUtils.closePopView()
      },
      cancel: () => {
        PopViewUtils.closePopView()
      }
    }
    PopViewUtils.showPopView<PrivacyPwdBuilderParams>(wrapBuilder(privacyPasswordSettingDialogBuilder), {
      autoCancel: false,
      alignment: DialogAlignment.Center,
    }, builderParams)
  }

  // 打开输入隐私密码弹框
  openPrivacyPwdInputDialog(callback: () => void) {
    let builderParams: PrivacyPwdBuilderParams = {
      confirm: () => {
        callback?.()
        PopViewUtils.closePopView()
      },
      cancel: () => {
        PopViewUtils.closePopView()
      }
    }
    PopViewUtils.showPopView<PrivacyPwdBuilderParams>(wrapBuilder(privacyPwdInputDialogBuilder), {
      autoCancel: false,
      alignment: DialogAlignment.Center,
    }, builderParams)
  }

  // 删除日记弹框
  openDeleteDiaryDialog(uiContext: UIContext | undefined, callback: () => void) {
    uiContext?.getPromptAction().showDialog({
      title: '删除日记',
      message: '确定删除该篇日记吗？',
      alignment: 	DialogAlignment.Center,
      buttons: [
        {
          text: '取消',
          color: $r('sys.color.icon_emphasize')
        },
        {
          text: '确定',
          color: $r('sys.color.icon_emphasize')
        }
      ]
    }, (err, data) => {
      if (err) {
        return;
      }
      if (data.index === 1) {
        callback?.()
      }
    });
  }
}