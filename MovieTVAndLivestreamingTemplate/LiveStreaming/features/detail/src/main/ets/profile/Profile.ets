import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { Audience } from 'live_interaction'
import { addFollowing, deleteFollowing } from '../models/AudienceData'
import { jumpFollowersPage } from './FollowersPage'
import { jumpFollowingPage } from './FollowingPage'
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit'

@Preview
@ComponentV2
export struct Profile {
  @Param audience: Audience = new Audience()
  @Param isMyself: boolean = false
  @Local likesDialogShow: boolean = false
  @Param mutualFollow: string[] = []
  @Event popCall: () => void

  formatToTenThousand(num: number): string {
    const formattedNumber = (num / 10000).toFixed(1)
    return `${formattedNumber}万`
  }

  @Builder
  likesDialog() {
    Column() {
      Column() {
        Text(this.audience.nickName)
          .fontWeight(700)
          .fontSize(20)
          .lineHeight(27)
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 8, top: 24 })

        Text() {
          Span('共获得')
          Span(`${this.audience.likesCount}`)
            .fontColor($r('sys.color.multi_color_08'))
          Span('个赞')
        }
        .fontSize(18)
        .margin({ bottom: 24 })
        .fontWeight(500)
        .fontColor($r('sys.color.font_primary'))

        Image($r('app.media.profile_likesdialog_pic'))
          .width(156)
          .aspectRatio(1)
          .margin({ bottom: 24 })

        Button('好的')
          .width(202)
          .height(40)
          .backgroundColor('#EE5D1A')
          .onClick(() => {
            this.likesDialogShow = false
          })
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .width(328)
      .height(352)
      .borderRadius(32)
      .margin({ left: 16, right: 16 })
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.2)')
    .width('100%')
    .height('100%')
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Row() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.audience?.avatar)
              .width(48)
              .aspectRatio(1)
              .borderRadius(24)

            Image(this.audience?.gender === 0 ? $r('app.media.profile_female') :
              $r('app.media.profile_male'))
              .width(16)
          }
          .margin({ right: 12 })

          Column() {
            Text(this.audience?.nickName)
              .fontSize(18)
              .fontWeight(500)
              .margin({ bottom: 2 })
              .fontColor($r('sys.color.font_primary'))

            Text(`ID：${this.audience?.id}`)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }

        Blank()

        if (!this.isMyself) {
          Button(this.audience?.isFocused ? '已关注' : '关注')
            .fontColor(this.audience?.isFocused ? '#EE5D1A' : $r('sys.color.background_primary'))
            .fontSize('sys.float.Body_M')
            .fontWeight(500)
            .height(28)
            .backgroundColor(this.audience?.isFocused ? $r('sys.color.comp_background_tertiary') : '#EE5D1A')
            .onClick(() => {
              this.audience!.isFocused = !this.audience?.isFocused
              if (this.audience?.isFocused) {
                addFollowing(this.audience?.id)
              } else {
                deleteFollowing(this.audience?.id)
              }
            })
        }
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .onClick(() => {
        if (this.isMyself) {
          RouterModule.push({ url: RouterMap.PERSONAL_CENTER_PAGE })
        }
      })

      Text(this.audience?.bio || '暂无简介')
        .width('100%')
        .fontWeight(400)
        .fontSize(14)
        .lineHeight(19)
        .fontColor($r('sys.color.font_primary'))

      Row({ space: 16 }) {
        Row() {
          Text(this.audience?.followingList.length.toString())
            .fontSize(14)
            .fontWeight(700)
            .fontColor($r('sys.color.font_primary'))
            .margin({ right: 4 })

          Text('关注')
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          jumpFollowingPage({
            idList: this.audience.followingList,
            isMyself: this.isMyself,
            mutualFollow: this.mutualFollow
          }, () => {
            if (this.isMyself) {
              this.popCall()
            }
          })
        })

        Row() {
          Text(this.audience?.followersList.length.toString())
            .fontSize(14)
            .fontWeight(700)
            .fontColor($r('sys.color.font_primary'))
            .margin({ right: 4 })

          Text('粉丝')
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          jumpFollowersPage({
            idList: this.audience.followersList,
            isMyself: this.isMyself,
            mutualFollow: this.mutualFollow
          }, () => {
            if (this.isMyself) {
              this.popCall()
            }
          })
        })

        if (deviceInfo.deviceType === 'phone' && display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
          Row() {
            Text(this.audience!.likesCount < 10000 ? this.audience?.likesCount.toString() :
              this.formatToTenThousand(this.audience?.likesCount))
              .fontSize(14)
              .fontWeight(700)
              .fontColor($r('sys.color.font_primary'))
              .margin({ right: 4 })

            Text('获赞')
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
          }
          .onClick(() => {
            this.likesDialogShow = !this.likesDialogShow
          })
          .bindContentCover($$this.likesDialogShow, this.likesDialog(), ModalTransition.ALPHA)
        } else {
          Row() {
            Text(this.audience!.likesCount < 10000 ? this.audience?.likesCount.toString() :
              this.formatToTenThousand(this.audience?.likesCount))
              .fontSize(14)
              .fontWeight(700)
              .fontColor($r('sys.color.font_primary'))
              .margin({ right: 4 })

            Text('获赞')
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
          }
          .onClick(() => {
            this.likesDialogShow = !this.likesDialogShow
          })
          .bindSheet($$this.likesDialogShow, this.likesDialog(), {
            preferType: SheetType.CENTER,
            showClose: false,
            width: 328,
            height: 352
          })
        }

      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
  }
}


export enum ProfileSection {
  Fans = 0, // 粉丝
  Following = 1 // 关注
}
