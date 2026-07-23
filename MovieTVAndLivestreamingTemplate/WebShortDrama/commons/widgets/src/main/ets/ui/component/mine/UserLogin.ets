import { getColor, getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { appRouter, Logger } from '@agctemplate/utils'
import { RowModifier } from '../../AttributeModifiers'
import { AssociateUtil } from '../../../util/Utils'
import { MinePageVM } from '../../viewmodel/MinePageVM'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'
import { MinorsMode } from '../../../models/MinorsModel'
import { AppStorageV2 } from '@kit.ArkUI'
import { MinorsProtectionUtils } from '../../../push/minorsProtectionUtils'
import { FontModel } from '../../../models/FontModel'
import { fp2pxUtil } from '../../../util/FontUtils'

const fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

@Extend(Image)
function profileImageStyles() {
  .width(48)
  .height(48)
  .borderRadius(24)
  .draggable(false)
  .autoResize(false)
  .objectFit(ImageFit.Cover)
  .interpolation(ImageInterpolation.High)
}

@Extend(Text)
function userNameStyles() {
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .fontSize(fontModel.getFg(18))
  .textOverflow({
    overflow: TextOverflow.Ellipsis
  })
  .maxLines(1)
}

const TAG = 'UserLogin';
const minorsMode: MinorsMode =
  AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

@ComponentV2
export struct UserLogin {
  @Local vm: MinePageVM = MinePageVM.instance;
  @Param userInfoHandler?: Function = undefined
  rowModifier: RowModifier = new RowModifier();
  @Local isVip: boolean = false

  build() {
    Column() {
      Row({ space: 16 }) {
        Row({ space: 16 }) {
          this.profileImage()
          this.userName()
        }
        .height(64)
        .padding(8)
        .layoutWeight(1)
        .borderRadius(12)
        .attributeModifier(this.rowModifier)
        .onClick(() => {
          if (this.userInfoHandler && this.vm.userInfo.isPhoneAssociated) {
            this.userInfoHandler();
          } else {
            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name })
          }
        })
      }

      if (this.vm.userInfo.isPhoneAssociated && !minorsMode.isMinorsMode) {
        Divider().height(0.5).padding({ left: 12, right: 12 })
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center}) {
          Text(this.vm.userInfo.isVip ? getString('app.string.VIP_information') :
            getString('app.string.Non_VIP_information'))
            .fontSize(fontModel.getFg(14))
            .fontColor($r('sys.color.font_primary'))

          Blank()
          Button(this.vm.userInfo.isVip ? getString('app.string.VIP_button') : getString('app.string.Non_VIP_button'))
            .fontSize(fp2pxUtil(14))
            .fontWeight(500)
            .height(28)
            .backgroundColor('#BD9164')
            .onClick(() => {
              appRouter.push({ builderName: NAV_PAGE_NAME.VIPCenterPage.name })
            })
        }
        .width('100%')
        .padding({ top: 14, bottom: 14, left: 12, right: 12 })
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding(4)

  }

  // 头像
  @Builder
  profileImage() {
    Image((this.vm.userInfo.isPhoneAssociated) ?
      this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
        this.vm.userInfo.avatar : getMedia('app.media.user_login_img'))
      .accessibilityText('账号头像')
      .profileImageStyles()
      .onError((error: ImageError) => {
        Logger.warn(TAG, 'image error')
      })
  }

  // 昵称
  @Builder
  userName() {
    Column() {
      if (this.vm.userInfo.isPhoneAssociated) {
        Text(this.vm.localInfo.nickname ? this.vm.localInfo.nickname : this.vm.userInfo.nickname)
          .userNameStyles()
          .accessibilityText(`账号昵称${this.vm.localInfo.nickname ? this.vm.localInfo.nickname :
            this.vm.userInfo.nickname}`)
      } else {
        Text('点击登录')
          .userNameStyles()
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height(48)
    .layoutWeight(1)
  }

  @Builder
  accountLink() {
    if (this.vm.userInfo.isPhoneAssociated) {
      Row({ space: 4 }) {
        Image(getMedia('app.media.linked'))
          .height(16)
          .width(16)
        Text(getString('app.string.unlink'))
          .fontWeight(FontWeight.Medium)
          .fontSize(fontModel.getFg(14))
          .fontColor($r('sys.color.font_primary'))
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .margin({ right: 8 })
      .height(28)
      .borderRadius(14)
      .onClick(async () => {
        await AssociateUtil.disassociateAccount(this.getUIContext().getHostContext()!);
      })
    } else {
      Stack() {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
            label: '',
            styleOption: {
              plain: true,
              styleConfig: new functionalButtonComponentManager
                .ButtonConfig()
                .height(28)
                .width(92)
                .backgroundColor($r('sys.color.comp_background_tertiary')),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController()
            .onGetPhoneNumber((err, data) => {
            }),
        })
          .zIndex(1)

        Row({ space: 4 }) {
          Image(getMedia('app.media.to_link'))
            .height(16)
            .width(16)
          Text(getString('app.string.to_link'))
            .fontWeight(FontWeight.Medium)
            .fontSize(fontModel.getFg(14))
            .fontColor(getColor('app.color.orange'))
        }
      }
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius(14)
    }
  }
}

