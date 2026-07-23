import { CircleShape, PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, CommonUtil, RouterMap, RouterModule, UserInfo } from 'commonlib';


@ComponentV2
export struct UserCard {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Computed
  get isLogin() {
    return this.userInfo.isLogin;
  }

  @Computed
  get userAvatar() {
    return this.userInfo.avatar || $r('app.media.ic_user_default');
  }

  @Computed
  get userName() {
    return this.userInfo.nickname ?? '华为用户';
  }

  @Computed
  get userPhone() {
    return CommonUtil.encryptPhoneNo(this.userInfo.phone ?? '');
  }

  @Computed
  get isVip() {
    return this.userInfo.isVip;
  }

  @Computed
  get vipIconColor() {
    return this.userInfo.isVip ? $r('sys.color.icon_emphasize') : $r('sys.color.icon_tertiary');
  }

  @Computed
  get vipText() {
    return this.userInfo.isVip ? '已有会员' : '未开通会员';
  }

  @Computed
  get vipTextColor() {
    return this.userInfo.isVip ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary');
  }

  @Computed
  get vipTipText() {
    if (this.isLogin && this.isVip) {
      return '请查看您的会员权益';
    }
    return '现在订阅低至0.8元/天';
  }

  // 跳转会员中心页
  jumpToVipPage() {
    if (this.isLogin) {
      RouterModule.push({ url: RouterMap.VIP_PAGE })
    } else {
      RouterModule.push({
        url: RouterMap.LOGIN_PAGE,
        onPop: () => {
          RouterModule.push({ url: RouterMap.VIP_PAGE })
        }
      })
    }
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
      .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })
      .onClick(() => {
        if (this.isLogin) {
          RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE })
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        }
      })

      Divider()

      Row() {
        Row() {
          Text(this.vipTipText)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))

          Circle()
            .width(6)
            .height(6)
            .fill($r('sys.color.warning'))

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_tertiary')])
            .fontSize(24)
        }
        .onClick(() => {
          this.jumpToVipPage();
        })

        Blank()

        Button(this.isVip ? '会员中心' : '立即开通')
          .controlSize(ControlSize.SMALL)
          .onClick(() => {
            this.jumpToVipPage();
          })
      }
      .width('100%')
      .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })
    }
    .width('100%')
    .padding({ left: CommonConstants.PADDING_M, right: CommonConstants.PADDING_M })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
