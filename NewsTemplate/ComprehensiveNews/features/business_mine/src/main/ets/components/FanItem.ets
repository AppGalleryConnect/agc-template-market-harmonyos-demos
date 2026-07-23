import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConfirmDialog, CommonConstants, RouterMap, RouterUtils, SettingModel, UserInfoModel } from 'lib_common'
import { AuthorModel, MineServiceApi } from 'lib_news_api';
import { Constants } from '../constants/Constants';

@ComponentV2
export struct FanItem {
  @Require @Param author: AuthorModel;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image($r('app.media.ic_user_default'))
        .width($r('app.float.head_icon_width'))
        .aspectRatio(1)
      Column({ space: CommonConstants.SPACE_XXS }) {
        Text(this.author.authorNickName)
          .fontSize(16 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text() {
          Span('11:06')
          Span(' ').letterSpacing(4)
          Span('关注了你')
        }
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

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
    .onClick(() => {
      RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.author.authorId);
    })
  }

  btnClick() {
    if (this.isWatchByMe) {
      CommonConfirmDialog.show({
        content: '确定不再关注TA？',
        confirm: () => {
          MineServiceApi.cancelWatch(this.author.authorId).then(() => {
            this.refreshUserInfo();
          });
        },
      })
    } else {
      MineServiceApi.addWatch(this.author.authorId).then(() => {
        this.refreshUserInfo();
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
    return this.userInfoModel.watchers.includes(this.author.authorId);
  }

  // 他有没有关注我
  @Computed
  get isWatchByHim() {
    return this.userInfoModel.followers.includes(this.author.authorId);
  }

  @Computed
  get btnLabel() {
    if (this.isWatchByMe && this.isWatchByHim) {
      return '互相关注';
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