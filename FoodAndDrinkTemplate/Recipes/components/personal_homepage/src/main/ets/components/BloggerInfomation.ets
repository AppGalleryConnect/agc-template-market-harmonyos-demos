import { BloggerInfo } from '../types/Index';
import { CircleShape } from '@kit.ArkUI';
import { CommonConstants } from '../common/CommonConstants';

@ComponentV2
export struct BloggerInfomation {
  @Param bloggerInfo: BloggerInfo = new BloggerInfo();
  @Param isSelf: boolean = false;
  @Param isLogin: boolean = false;
  @Param isFollower: boolean = false;
  @Event jumpFollowers: () => void = () => {
  }
  @Event login: () => void = () => {
  }
  @Event followCb: (isFollower: boolean) => void = () => {
  }
  @Event jumpMemberCenter: () => void = () => {
  }

  build() {
    Column() {
      Column() {
        if (this.isSelf) {
          if (this.isLogin) {
            Column() {
              Row({ space: CommonConstants.SPACE_L }) {
                Image(this.bloggerInfo.avatar)
                  .width($r('app.float.user_icon_width'))
                  .clipShape(new CircleShape({ width: 48, height: 48 }))
                  .draggable(false)
                Column({ space: CommonConstants.SPACE_XXS }) {
                  Row() {
                    Text(this.bloggerInfo.name)
                      .fontSize(18)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                    SymbolGlyph($r('sys.symbol.v_diamond_fill'))
                      .fontColor([this.bloggerInfo.isMembership ? $r('app.color.membership') :
                        $r('sys.color.font_tertiary')])
                      .fontWeight(FontWeight.Normal)
                      .fontSize(16)
                      .margin({
                        left: CommonConstants.PADDING_S,
                      })
                    Text('会员')
                      .fontSize(12)
                      .fontColor(this.bloggerInfo.isMembership ? $r('sys.color.font_primary') :
                        $r('sys.color.font_tertiary'))
                      .fontWeight(FontWeight.Regular)
                      .margin({
                        left: CommonConstants.PADDING_XXS,
                      })
                  }

                  Row({ space: CommonConstants.SPACE_XS }) {
                    Image($r('app.media.ic_phone'))
                      .width($r('app.float.medium_img_width'))
                      .draggable(false)
                      .fillColor($r('sys.color.icon_secondary'))
                    Text(this.bloggerInfo.phoneNumber)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Image($r('app.media.ic_right'))
                  .width($r('app.float.arrow_right_w'))
                  .draggable(false)
              }
              .borderRadius($r('app.float.large_radius'))
              .padding(CommonConstants.PADDING_S)
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles,
              })
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.login()
              })

              Divider().width(CommonConstants.FULL_PERCENT).margin({
                left: CommonConstants.PADDING_S,
                right: CommonConstants.PADDING_S,
                top: CommonConstants.PADDING_XS,
                bottom: CommonConstants.PADDING_XS,
              }).backgroundColor($r('sys.color.comp_divider'))

              Row() {
                Text(this.bloggerInfo.isMembership ? '请查看您的会员权益' : '开通会员享受更多权益')
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Regular)
                Button('会员中心')
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .backgroundColor($r('app.color.membership'))
                  .height(28)
                  .onClick(() => {
                    this.jumpMemberCenter()
                  })
              }
              .width(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                left: CommonConstants.PADDING_S,
                right: CommonConstants.PADDING_S,
                top: CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S,
              })
            }
          } else {
            Row({ space: CommonConstants.SPACE_L }) {
              Image($r('app.media.ic_user_unlogin'))
                .width($r('app.float.user_icon_width'))
                .draggable(false)
              Column({ space: CommonConstants.SPACE_XXS }) {
                Text('点击登录')
                  .fontSize(18)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                Text('登录后享受更多服务')
                  .fontSize(12)
                  .fontColor($r('sys.color.font_primary'))
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Image($r('app.media.ic_right'))
                .width($r('app.float.arrow_right_w'))
                .draggable(false)
            }
            .borderRadius($r('app.float.large_radius'))
            .padding(CommonConstants.PADDING_S)
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles,
            })
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.login()
            })
          }
        } else {
          Row({ space: CommonConstants.SPACE_L }) {
            Image(this.bloggerInfo.avatar)
              .width($r('app.float.user_icon_width'))
              .clipShape(new CircleShape({ width: 48, height: 48 }))
              .draggable(false)
            Column({ space: CommonConstants.SPACE_XXS }) {
              Text(this.bloggerInfo.name)
                .fontSize(18)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .borderRadius($r('app.float.large_radius'))
          .padding(CommonConstants.PADDING_S)
          .backgroundColor(Color.Transparent)
        }
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(CommonConstants.PADDING_XS)
      .borderRadius($r('app.float.large_radius'))

      Column({ space: 12 }) {
        Column() {
          Row() {
            Text(this.bloggerInfo.sex).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.icon_primary'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.createdAccount).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.icon_primary'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.ipLocation).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.icon_primary'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.bloggerType).fontSize(12).fontColor($r('sys.color.font_primary'))
          }.width('100%')

          Column() {
            Text('简介：').fontSize(12).fontColor($r('sys.color.font_primary'))
            Text(this.bloggerInfo.profile).fontSize(12).fontColor($r('sys.color.font_primary'))
          }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: 12 })
        }.padding(12)
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .margin({ top: 12 })
      .borderRadius($r('app.float.large_radius'))

      Row() {
        Row() {
          Column() {
            Text(this.bloggerInfo.getFollowers()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('关注').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }
          .onClick(() => {
            this.jumpFollowers()
          })

          Blank()
          Column() {
            Text(this.bloggerInfo.getFans()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('粉丝').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }

          Blank()
          Column() {
            Text(this.bloggerInfo.getBeFavorite()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被收藏').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }

          Blank()
          Column() {
            Text(this.bloggerInfo.getBeFollowed()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被跟做').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }
        }
        .width(this.isSelf ? '100%' : '80%')
        .padding({ left: 16, right: 16 })

        Button(this.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isFollower ? '#33FD4238' : '#FD4238')
          .visibility(this.isSelf ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            this.followCb(!this.isFollower)
          })
      }
      .width('100%')
      .height(60)
      .margin({ top: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.float.large_radius'))
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}
