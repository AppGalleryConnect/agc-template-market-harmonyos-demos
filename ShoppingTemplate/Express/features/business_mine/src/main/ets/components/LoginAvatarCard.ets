import { RouterModule, CommonUtil, RouterMap } from 'lib_foundation'
import { MinePageVM } from '../viewModels/MinePageVM'
import { CircleShape } from '@kit.ArkUI'

@ComponentV2
export struct LoginAvatarCard {
  vm: MinePageVM = MinePageVM.instance;

  @Computed
  get isLogin() {
    return this.vm.userInfoModel.isLogin;
  }

  @Computed
  get userAvatar() {
    return this.vm.userInfoModel.avatar || $r('app.media.ic_default_avatar');
  }

  @Computed
  get userName() {
    return this.vm.userInfoModel.nickname ?? '华为用户';
  }

  @Computed
  get isClaimBenefit() {
    // 是否领取会员权益礼包
    return this.vm.userInfoModel.isClaimBenefit;
  }

  @Computed
  get isVip() {
    return this.vm.userInfoModel.isVip;
  }

  @Computed
  get vipIconColor() {
    return this.vm.userInfoModel.isVip ? $r('sys.color.icon_emphasize') : $r('sys.color.icon_tertiary');
  }

  @Computed
  get vipText() {
    return this.vm.userInfoModel.isVip ? '已有会员' : '未开通会员';
  }

  @Computed
  get vipTextColor() {
    return this.vm.userInfoModel.isVip ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary');
  }

  @Computed
  get userPhone() {
    return CommonUtil.encryptPhoneNo(this.vm.userInfoModel.phone ?? '');
  }


  build() {
    Column() {
      Row() {
        Image(this.userAvatar)
          .width(48)
          .height(48)
          .clipShape(new CircleShape({ width: 48, height: 48 }))
          .margin({ right: 16 })
        if (this.isLogin) {
          Column({ space: 4 }) {
            Row() {
              Text(this.userName)
                .fontSize(18)
                .fontWeight(500)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: 150 })

              SymbolGlyph($r('sys.symbol.v_diamond_fill'))
                .fontSize(16)
                .fontColor([this.vipIconColor])
                .margin({ left: 8 })

              Text(this.vipText)
                .fontSize(12)
                .fontColor(this.vipTextColor)
                .lineHeight(16)
                .margin({ left: 2 })
            }
            Row({ space: 8 }) {
              Image($r('app.media.ic_public_phone'))
                .width(16)
                .height(16)
              Text(this.userPhone)
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        } else {
          Row() {
            Column() {
              Text('点击登录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 2 })
              Text('登录后享受更多服务')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .alignItems(HorizontalAlign.Start)

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_tertiary')])
              .fontSize(24)
          }
          .flexGrow(1)
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .onClick(() => {
        if (this.vm.userInfoModel.isLogin) {
          RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE })
        } else {
          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
        }
      })

      Divider().visibility(this.isLogin ? Visibility.Visible : Visibility.Hidden)

      if (this.isLogin) {
        Row() {
          if (!this.isClaimBenefit) {
            Row() {
              Text('开通会员可领788优惠礼包')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.VIP_BENEFIT_PAGE })
                })

              Circle()
                .width(6)
                .height(6)
                .fill('#E84026')

              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontColor([$r('sys.color.icon_tertiary')])
                .fontSize(24)
            }
          }

          Blank()

          Button(this.isVip ? '会员中心' : '立即开通')
            .controlSize(ControlSize.SMALL)
            .onClick(() => {
              if (this.isLogin) {
                RouterModule.push({ url: RouterMap.PURCHASE_PAGE })
              } else {
                RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              }
            })
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}