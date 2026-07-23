import { PersistenceV2 } from '@kit.ArkUI';
import { LoginSheetUtils } from 'lib_account';
import { CommonConfirmDialog, GlobalContextUtils, UserInfoModel } from 'lib_common';
import { AuthorModel, MineServiceApi } from 'lib_news_api';
import { Constants } from '../common/Constants';

@ComponentV2
export struct WatchButton {
  @Require @Param author: AuthorModel;
  @Event refreshAuthorInfo: () => void = () => {
  };
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  build() {
    Button(this.btnLabel)
      .fontColor(this.isCustomFg)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.isCustomBg)
      .width(Constants.SMALL_BTN_W)
      .height(Constants.SMALL_BTN_H)
      .padding(0)
      .onClick(() => {
        this.btnClick();
      })
  }

  btnClick() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open();
      return;
    }
    if (this.author?.authorId === this.userInfoModel.authorId) {
      GlobalContextUtils.showToast({ message: '不可关注自己' });
      return;
    }
    if (this.isWatchByMe) {
      CommonConfirmDialog.show({
        content: '确定不再关注TA？',
        confirm: () => {
          MineServiceApi.cancelWatch(this.author?.authorId).then(() => {
            this.refreshUserInfo();
            this.refreshAuthorInfo();
          });
        },
      })
    } else {
      MineServiceApi.addWatch(this.author?.authorId).then(() => {
        this.refreshUserInfo();
        this.refreshAuthorInfo();
      });
    }
  }

  async refreshUserInfo() {
    const mine = await MineServiceApi.queryAuthorInfo()
    this.userInfoModel.watchers = mine?.watchers || [];
    this.userInfoModel.watchersCount = mine?.watchersCount || 0;
    this.userInfoModel.followersCount = mine?.followersCount || 0;
  }

  // 我有没有关注他
  @Computed
  get isWatchByMe() {
    return this.userInfoModel.watchers.includes(this.author?.authorId);
  }

  // 他有没有关注我
  @Computed
  get isWatchByHim() {
    return this.userInfoModel.followers.includes(this.author?.authorId);
  }

  @Computed
  get btnLabel() {
    if (this.isWatchByMe && this.isWatchByHim) {
      return '互相关注';
    }
    if (this.isWatchByMe && !this.isWatchByHim) {
      return '已关注';
    }
    if (!this.isWatchByMe && this.isWatchByHim) {
      return '回关';
    }
    return '关注';
  }

  @Computed
  get isCustomFg() {
    if (this.isWatchByMe) {
      return $r('app.color.app_theme');
    }
    return $r('sys.color.font_on_primary');
  }

  @Computed
  get isCustomBg() {
    if (this.isWatchByMe) {
      return $r('sys.color.comp_background_tertiary');
    }
    return $r('app.color.app_theme');
  }
}