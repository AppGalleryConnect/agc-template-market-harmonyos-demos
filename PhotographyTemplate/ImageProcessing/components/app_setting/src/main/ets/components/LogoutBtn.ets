import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { FontModel } from '../models/FontModel';
import { CommonConfirmDialog } from './CommonConfirmDialog';

@ComponentV2
export struct LogoutBtn {
  // 是否可见
  @Once @Param visible: boolean = false;
  // 退出登录api
  @Event signOutApi: () => Promise<void> = () => new Promise((resolve) => resolve());
  // 标记是否正在退出
  @Local isLoading: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Button() {
        Row({ space: CommonConstants.SPACE_XS }) {
          LoadingProgress()
            .width(16)
            .aspectRatio(1)
            .color($r('sys.color.icon_secondary'))
            .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
          Text(this.signOutBtnLabel)
            .fontSize(this.fontModel.getFg(16))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })
      .enabled(!this.isLoading)
      .onClick(() => {
        this.onSignOutBtnClick();
      })
    }
    .visibility(this.visible ? Visibility.Visible : Visibility.None)
    .margin({ top: CommonConstants.PADDING_L })
  }

  onSignOutBtnClick() {
    CommonConfirmDialog.show({
      content: '确定退出登录吗？',
      confirm: () => {
        this.isLoading = true;
        this.signOutApi()
          .then(() => {
            this.visible = false;
            this.getUIContext().getPromptAction().showToast({ message: '已退出登录' });
          })
          .catch(() => {
            this.getUIContext().getPromptAction().showToast({ message: '未正常退出登录' });
          })
          .finally(() => {
            this.isLoading = false;
          });
      },
    })
  }

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }
}