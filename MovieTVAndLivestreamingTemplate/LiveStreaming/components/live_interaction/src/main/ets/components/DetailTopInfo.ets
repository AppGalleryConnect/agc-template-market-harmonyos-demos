import { Audience } from '../models/Audience'
import { Report } from './Report'
import { deviceInfo } from '@kit.BasicServicesKit'
import { display } from '@kit.ArkUI';

@ComponentV2
export struct DetailTopInfo {
  @Param showControl: boolean = true
  @Local isShowUserInfoSheet: boolean = false
  @Local isShowUserInfoPopup: boolean = false
  @Local isShowAudienceSheet: boolean = false
  @Local isShowAudiencePopup: boolean = false
  @Local isShowReportSheet: boolean = false
  @Param @Require presenter: Audience
  @Param @Require audienceList: Array<Audience>
  @Param screenDirection: number = 0
  @Event setToVertical: Function = () => {
  }
  @Event onCheckLogin: Function = () => {
  }
  @Event onLogin: Function = () => {
  }
  @Event onGetLoginUserInfo: Function = () => {
  }
  @Event onDeleteFollowingClick: Function = (id: string) => {
  }
  @Event onAddFollowingClick: Function = (id: string) => {
  }
  @Event onProfileClick: Function = (id: string) => {
  }
  @Event onExit: Function = () => {
  }
  @Event onReport: Function = () => {
  }
  @Event sheetHide: () => void

  aboutToAppear(): void {
  }

  @Builder
  reportSheet() {
    Column() {
      Report({
        setDisappear: () => {
          this.isShowReportSheet = !this.isShowReportSheet
        },
        onReport: this.onReport
      })
    }
    .height(665)
  }

  @Builder
  userInfoSheetBuilder() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .margin({ right: 12 })
        .bindSheet($$this.isShowReportSheet, this.reportSheet(), {
          height: 665,
          showClose: false,
          preferType: SheetType.CENTER,
          onWillDisappear: () => {
            this.sheetHide()
          }
        })
        .onClick(() => {
          this.isShowReportSheet = !this.isShowReportSheet
        })

        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .margin({ right: 16 })
        .onClick(() => {
          if (deviceInfo.deviceType === 'phone' &&
            display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
            this.isShowUserInfoSheet = false
          } else {
            this.isShowUserInfoPopup = false
          }
        })
      }
      .width('100%')
      .height(56)
      .margin({ top: 8 })
      .justifyContent(FlexAlign.End)

      Column() {
        Row() {
          Column({ space: 24 }) {
            Image(this.presenter.avatar)
              .width(48)
              .height(48)
              .borderRadius(24)
              .onClick(() => {
                // 点击进入主播主页，即个人主页
                if (!this.onCheckLogin()) {
                  if (!this.onLogin()) {
                    this.isShowUserInfoSheet = false
                    this.isShowUserInfoPopup = false
                    return
                  }
                }
                this.isShowUserInfoSheet = false
                this.isShowUserInfoPopup = false
                this.onProfileClick(this.presenter)
              })
            Text(this.presenter.nickName)
              .height(26)
              .fontSize(18)
              .fontWeight(500)
          }
        }
        .width(328)
        .justifyContent(FlexAlign.Center)

        Column() {
          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Text(this.presenter.followingList.length.toString())
                .fontSize(14)
                .fontWeight(700)
                .textAlign(TextAlign.Start)
              Text('关注')
                .fontSize(12)
                .fontWeight(400)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.font_secondary'))
            }

            Row({ space: 4 }) {
              Text(this.presenter.followersList.length.toString())
                .fontSize(14)
                .fontWeight(700)
                .textAlign(TextAlign.Start)
              Text('粉丝')
                .fontSize(12)
                .fontWeight(400)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.font_secondary'))
            }

            Row({ space: 4 }) {
              Text(this.presenter.likesCount.toString())
                .fontSize(14)
                .fontWeight(700)
                .textAlign(TextAlign.Start)
              Text('获赞')
                .fontSize(12)
                .fontWeight(400)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .height(19)

          Row() {
            Text(this.presenter.bio)
              .fontSize(14)
              .fontWeight(400)
              .lineHeight(19)
              .textAlign(TextAlign.Start)
          }
          .width(328)
          .margin({ top: 13 })
        }
        .width(328)
        .margin({ top: 5 })

        Blank()
        Row() {
          if (this.presenter.isFocused) {
            Text('已关注')
              .fontSize(16)
              .fontWeight(500)
              .lineHeight(21)
              .textAlign(TextAlign.Start)
              .fontColor('#fff')
          } else {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(18)
              .fontWeight(500)
              .fontColor(['#fff'])
            Text('关注')
              .fontSize(16)
              .fontWeight(500)
              .lineHeight(21)
              .textAlign(TextAlign.Start)
              .fontColor('#fff')
              .margin({ left: 8 })
          }
        }
        .width(328)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#EE5D1A')
        .margin({ bottom: 35 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (!this.onCheckLogin()) {
            if (!this.onLogin()) {
              this.isShowUserInfoSheet = !this.isShowUserInfoSheet
              return
            }
          }
          this.presenter.isFocused = !this.presenter.isFocused
          if (this.presenter.isFocused) {
            this.onAddFollowingClick(this.presenter.id)
          } else {
            this.onDeleteFollowingClick(this.presenter.id)
          }
        })
      }
      .layoutWeight(1)
    }
    .height(this.isShowUserInfoPopup ? 400 : 343)
    .opacity(0.9)
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  audienceSheetBuilder() {

    Column() {
      Row() {
        Text('房间观众')
          .fontSize(20)
          .fontWeight(700)
          .lineHeight(27)
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          if (deviceInfo.deviceType === 'phone' &&
            display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
            this.isShowAudienceSheet = false
          } else {
            this.isShowAudiencePopup = false
          }
        })
      }
      .width('95%')
      .height(56)
      .margin({ top: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      List() {
        ForEach(
          this.audienceList,
          (item: Audience, index: number) => {
            ListItem() {
              Row() {
                Row() {
                  Image(item.avatar)
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                  Text(item.nickName)
                    .height(21)
                    .fontSize(16)
                    .fontWeight(400)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 8 })
                }
                .height(40)
                .onClick(() => {
                  this.onProfileClick(item)
                  this.isShowAudienceSheet = !this.isShowAudienceSheet
                })

                Text(item.isFocused ? '已关注' : '关注')
                  .width(72)
                  .height(28)
                  .borderRadius(14)
                  .backgroundColor(item.isFocused ? $r('sys.color.comp_background_tertiary') : '#EE5D1A')
                  .textAlign(TextAlign.Center)
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor(item.isFocused ? '#EE5D1A' : '#fff')
                  .onClick(() => {
                    item.isFocused = !item.isFocused
                    if (item.isFocused) {
                      this.onAddFollowingClick(item.id)
                    } else {
                      this.onDeleteFollowingClick(item.id)
                    }
                  })
              }
              .width('100%')
              .height(64)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .height(64)
          },(item: Audience, index: number) => { return index + '__' + JSON.stringify(item); }
        )
        ListItem() {
          Row()
            .width('100%')
            .height(80)
        }
      }
      .width('95%')
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('(display.getDefaultDisplaySync().availableHeight*0.65)px')
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  build() {
    if (this.screenDirection === 0) {
      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          Row()
            .width(this.presenter.isFocused ? 152 : 140)
            .height(32)
            .borderRadius(20)
            .backgroundColor('#000')
            .opacity(0.4)
          Image(this.presenter.avatar)
            .width(28)
            .height(28)
            .margin(2)
            .borderRadius(12)
            .onClick(() => {
              if (deviceInfo.deviceType === 'phone' &&
                display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
                this.isShowUserInfoSheet = true
              } else {
                this.isShowUserInfoPopup = true
              }
            })
            .bindSheet($$this.isShowUserInfoSheet, this.userInfoSheetBuilder(), {
              height: 343,
              showClose: false,
              preferType: SheetType.POPUP
            })
            .bindPopup(this.isShowUserInfoPopup, {
              builder: this.userInfoSheetBuilder(),
              placement: Placement.BottomLeft,
              width: 400,
              onStateChange: (e) => {
                if (!e.isVisible) {
                  this.isShowUserInfoPopup = false
                }
              }
            })
          Text(this.presenter.nickName)
            .width(50)
            .height(14)
            .margin({ left: 34, top: 2 })
            .fontSize(10)
            .fontWeight(500)
            .fontColor('#fff')
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Image($r('app.media.illustration'))
            .width(6.5)
            .height(9)
            .margin({ top: 18.5, left: 37 })
            .opacity(0.6)
          Text('1.8w')
            .height(14)
            .margin({ top: 16, left: 48 })
            .fontSize(8)
            .fontWeight(400)
            .textAlign(TextAlign.Start)
            .fontColor('#fff')
            .opacity(0.6)
          Text(this.presenter.isFocused ? '已关注' : '关注')
            .width(this.presenter.isFocused ? 52 : 40)
            .height(24)
            .borderRadius(14)
            .textAlign(TextAlign.Center)
            .margin({
              left: 96,
              top: 4,
              right: 4,
              bottom: 4
            })
            .fontSize(12)
            .fontWeight(500)
            .fontColor('#fff')
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#ff3333', 0], ['#e444bd', 1]]
            })
            .onClick(() => {
              if (!this.onCheckLogin()) {
                if (!this.onLogin()) {
                  return
                }
              }
              this.presenter.isFocused = !this.presenter.isFocused
              if (this.presenter.isFocused) {
                this.onAddFollowingClick(this.presenter.id)
              } else {
                this.onDeleteFollowingClick(this.presenter.id)
              }
            })
        }
        .height(32)
        .borderRadius(20)
        .margin({ left: 16 })

        Row() {
          ForEach([1, 2, 3], (index: number) => {
            Image(this.audienceList[index - 1]?.avatar)
              .width(24)
              .height(24)
              .borderRadius(12)
              .margin({ right: 4 })
              .onClick(() => {
                if (!this.onCheckLogin()) {
                  if (!this.onLogin()) {
                    return
                  }
                }
                this.onProfileClick(this.audienceList[index - 1])
              })
          },(item: number, index: number) => { return index + '__' + JSON.stringify(item); })
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(40)
              .height(24)
              .borderRadius(18)
              .backgroundColor('#000')
              .opacity(0.4)
            Text(this.audienceList.length + '')
              .height(14)
              .fontSize(10)
              .fontWeight(500)
              .fontColor('#fff')
              .textAlign(TextAlign.Start)
              .onClick(() => {
                if (!this.onCheckLogin()) {
                  if (!this.onLogin()) {
                    return
                  }
                }
                if (deviceInfo.deviceType === 'phone' &&
                  display.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
                  this.isShowAudienceSheet = true
                } else {
                  this.isShowAudiencePopup = true
                }
              })
              .bindSheet($$this.isShowAudienceSheet, this.audienceSheetBuilder(), {
                height: 748,
                showClose: false,
                preferType: SheetType.BOTTOM,
              })
              .bindPopup(this.isShowAudiencePopup, {
                builder: this.audienceSheetBuilder(),
                placement: Placement.BottomRight,
                enableArrow: false,
                offset: { x: 18 },
                width: 400,
                onStateChange: (e) => {
                  if (!e.isVisible) {
                    this.isShowAudiencePopup = false
                  }
                }
              })
          }
          .width(40)
          .height(24)
          .borderRadius(18)
          .margin({ right: 4 })

          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(24)
              .height(24)
              .borderRadius(12)
              .backgroundColor('#000')
              .opacity(0.4)
            Image($r('app.media.ic_cancel'))
              .width(14.4)
              .height(14.4)
              .onClick(() => {
                this.onExit()
              })
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .margin({ right: 16 })
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
        .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
      }
      .width('100%')
      .height(32)
      .position({ top: 12 })
    } else {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.setToVertical()
          })
        Stack({ alignContent: Alignment.TopStart }) {
          Row()
            .width(this.presenter.isFocused ? 152 : 140)
            .height(32)
            .borderRadius(20)
            .backgroundColor('#000')
            .opacity(0.4)
          Image(this.presenter.avatar)
            .width(28)
            .height(28)
            .margin(2)
            .borderRadius(12)

          Text(this.presenter.nickName)
            .width(50)
            .height(14)
            .margin({ left: 34, top: 2 })
            .fontSize(10)
            .fontWeight(500)
            .fontColor('#fff')
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Image($r('app.media.illustration'))
            .width(6.5)
            .height(9)
            .margin({ top: 18.5, left: 37 })
            .opacity(0.6)
          Text('1.8w')
            .height(14)
            .margin({ top: 16, left: 48 })
            .fontSize(8)
            .fontWeight(400)
            .textAlign(TextAlign.Start)
            .fontColor('#fff')
            .opacity(0.6)
          Text(this.presenter.isFocused ? '已关注' : '关注')
            .width(this.presenter.isFocused ? 52 : 40)
            .height(24)
            .borderRadius(14)
            .textAlign(TextAlign.Center)
            .margin({
              left: 96,
              top: 4,
              right: 4,
              bottom: 4
            })
            .fontSize(12)
            .fontWeight(500)
            .fontColor('#fff')
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#ff3333', 0], ['#e444bd', 1]]
            })
            .onClick(() => {
              if (!this.onCheckLogin()) {
                if (!this.onLogin()) {
                  return
                }
              }
              this.presenter.isFocused = !this.presenter.isFocused
              if (this.presenter.isFocused) {
                this.onAddFollowingClick(this.presenter.id)
              } else {
                this.onDeleteFollowingClick(this.presenter.id)
              }
            })
        }
        .height(32)
        .borderRadius(20)
        .margin({ left: 8 })

        Blank()
        ForEach([1, 2, 3], (index: number) => {
          Image(this.audienceList[index - 1]?.avatar)
            .width(24)
            .height(24)
            .borderRadius(12)
            .margin({ right: 4 })
        },(item: number, index: number) => { return index + '__' + JSON.stringify(item); })
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(40)
            .height(24)
            .borderRadius(18)
            .backgroundColor('#000')
            .opacity(0.4)
          Text(this.audienceList.length + '')
            .height(14)
            .fontSize(10)
            .fontWeight(500)
            .fontColor('#fff')
            .textAlign(TextAlign.Start)
        }
        .width(40)
        .height(24)
        .borderRadius(18)
      }
      .width('100%')
      .height(32)
      .position({ top: 24 })
      .padding({ left: 16, right: 16 })
    }
  }
}