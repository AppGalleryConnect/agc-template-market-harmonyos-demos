import { titleBuilder } from 'live_interaction/src/main/ets/components/Common'
import { Gifts } from 'live_interaction/src/main/ets/components/VerticalScreenComponents/Gifts'
import { GiftModel } from 'live_interaction/src/main/ets/models/GiftGroup'
import { ChangeScreen } from 'live_interaction/src/main/ets/view/ChangeScreen'
import { BulletVM } from 'live_interaction/src/main/ets/viewModels/BulletVM'
import { MeasureText } from '@kit.ArkUI'
import { BulletItem } from 'live_interaction/src/main/ets/models/BulletItem'
import { ShareInfo } from 'live_interaction/src/main/ets/manager/LiveInteractionMgr'
import { AudienceRes } from '@agctemplate/server'
import { LiveInteractionMgr } from 'live_interaction'

@ObservedV2
class BarArg {
  @Trace title: string = ''
  @Trace index: number = 0
  @Trace currentIndex: number = 0
}

@ComponentV2
export struct BottomLineLayer {
  @Param @Require shareInfo: ShareInfo
  @Param @Require defaultResolution: string
  @Param @Require bulletVM: BulletVM
  @Param @Require liveInteractionMgr: LiveInteractionMgr
  @Local isShowPlaySettingSheet: boolean = false
  @Local isShowGiftSheet: boolean = false
  @Local myBullet: string = ''
  @Local isBulletOpen: boolean = true
  @Param screenDirection: number = 0
  @Param @Require audienceList: Array<AudienceRes>
  @Require @Param giftData: Array<GiftModel>
  @Local userName: string = ''
  @Event openMore: () => void
  @Event openGift: () => void
  @Event toComment: () => void
  @Event openBulletSetting: () => void
  @Event hideBullet: () => void
  @Event onPip: Function = () => {
  }
  @Event onChangeResolution: Function = () => {
  }
  @Event onReport: Function = () => {
  }
  @Event onCheckAndLogin: Function = () => {
  }
  @Event onGetUserInfo: Function = () => {
  }
  @Param userAvatar: Resource | string = $r('app.media.person')
  @Event onPay: Function = (item: GiftModel) => {

  }
  @Event onChangeScreen: Function = () => {
  }
  @Local currentIndex: number = 0
  @Local searchName: string = ''
  @Local totalModerator: number = this.getTotalModerator()
  @Local totalMute: number = this.getTotalMute()

  getTotalModerator(): number {
    let num = 0
    this.audienceList.forEach((item: AudienceRes) => {
      if (item.isModerator === true) {
        num++
      }
    })
    return num
  }

  getTotalMute(): number {
    let num = 0
    this.audienceList.forEach((item: AudienceRes) => {
      if (item.isMute === true) {
        num++
      }
    })
    return num
  }

  @Builder
  tabBarStyle(barSet: BarArg) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        if (barSet.currentIndex === barSet.index) {
          Column()
            .width('98%')
            .height(36)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(18)
            .shadow({ radius: 3, color: 'rgba(0, 0, 0, 0.2)' })
        }

        Text(barSet.title)
          .fontWeight(500)
          .fontSize(14)
          .fontColor(barSet.index === barSet.currentIndex ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
      }

    }
    .width('100%')
    .height(40)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .justifyContent(FlexAlign.Center)
    .borderRadius({
      topLeft: barSet.index ? 0 : 20,
      bottomLeft: barSet.index ? 0 : 20,
      topRight: barSet.index ? 20 : 0,
      bottomRight: barSet.index ? 20 : 0
    })

  }

  @Builder
  setModeratorOrMute() {
    Column() {
      Tabs({ index: $$this.currentIndex }) {
        TabContent() {
          Column({ space: 12 }) {
            Search({ placeholder: '请输入昵称/ID' })
              .width('100%')
              .caretStyle({width: 1.5,color: '#EE5D1A'})
              .onSubmit((value: string) => {
                this.searchName = value
              })
              .onChange((value: string) => {
                if (value === '') {
                  this.searchName = ''
                }
              })
            Text(`当前房管数  ${this.totalModerator}/${this.audienceList.length}`)
              .fontWeight(500)
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)
            List({ space: 12 }) {
              ForEach(this.audienceList, (item: AudienceRes) => {
                if (item.isModerator === true && item.nickName.includes(this.searchName)) {
                  ListItem() {
                    Row() {
                      Image($r(item.avatar))
                        .width(40)
                        .height(40)
                        .borderRadius(20)
                      Text(item.nickName)
                        .fontWeight(400)
                        .fontSize(16)
                        .margin({ left: 8 })
                      Blank()
                      Toggle({ type: ToggleType.Switch, isOn: item.isModerator })
                        .onChange((isOn: boolean) => {
                          item.isModerator = isOn
                          this.totalModerator = this.getTotalModerator()
                          if (isOn) {
                            this.liveInteractionMgr.addSystemChat(`${item.nickName} 已成为管理员！`)
                          } else {
                            this.liveInteractionMgr.addSystemChat(`${item.nickName} 已不是管理员！`)
                          }
                        })
                    }
                    .width('100%')
                  }
                }
              }, (item: AudienceRes) => item.id)
            }
            .scrollBar(BarState.Off)
            .layoutWeight(1)
          }
          .height('100%')
          .justifyContent(FlexAlign.Start)

        }
        .tabBar(this.tabBarStyle({ title: '房管', index: 0, currentIndex: this.currentIndex }))

        TabContent() {
          Column({ space: 12 }) {
            Search({ placeholder: '请输入昵称/ID' })
              .width('100%')
              .caretStyle({width: 1.5,color: '#EE5D1A'})
              .onSubmit((value: string) => {
                this.searchName = value
              })
              .onChange((value: string) => {
                if (value === '') {
                  this.searchName = ''
                }
              })
            Text(`当前禁言数  ${this.totalMute}/${this.audienceList.length}`)
              .fontWeight(500)
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)
            List({ space: 12 }) {
              ForEach(this.audienceList, (item: AudienceRes) => {
                if (item.isMute === true && item.nickName.includes(this.searchName)) {
                  ListItem() {
                    Row() {
                      Image($r(item.avatar))
                        .width(40)
                        .height(40)
                        .borderRadius(20)
                      Text(item.nickName)
                        .fontWeight(400)
                        .fontSize(16)
                        .margin({ left: 8 })
                      Blank()
                      Toggle({ type: ToggleType.Switch, isOn: item.isMute })
                        .onChange((isOn: boolean) => {
                          item.isMute = isOn
                          this.totalMute = this.getTotalMute()
                          if (isOn) {
                            this.liveInteractionMgr.addSystemChat(`${item.nickName} 已被禁言！`)
                          } else {
                            this.liveInteractionMgr.addSystemChat(`${item.nickName} 已解除禁言！`)
                          }
                        })
                    }
                    .width('100%')
                  }
                }
              }, (item: AudienceRes) => item.id)
            }
            .scrollBar(BarState.Off)
            .layoutWeight(1)
          }
          .height('100%')
          .justifyContent(FlexAlign.Start)
        }
        .tabBar(this.tabBarStyle({ title: '禁言', index: 1, currentIndex: this.currentIndex }))
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .height(340)
    .width('90%')
    .padding({ left: 12, right: 12, top: 12 })
  }

  @Builder
  giftSheetBuilder() {
    Gifts({ giftData: this.giftData, onPay: this.onPay })
      .height(240)
  }

  build() {
    Stack() {
      Row() {
        Row() {
          Image(this.userAvatar)
            .width(32)
            .height(32)
            .backgroundColor(Color.White)
            .borderRadius(32)
            .margin({ left: 4 })
          Text('聊一聊吧')
            .fontSize(14)
            .lineHeight(19)
            .fontWeight(500)
            .margin({ left: 8 })
            .fontColor('rgba(255, 255, 255, 0.6)')
            .onClick(() => {
              if (this.onCheckAndLogin()) {
                this.toComment()
              }
            })
            .layoutWeight(1)
        }
        .height(40)
        .backgroundColor('rgba(0,0,0,0.4)')
        .borderRadius(999)
        .margin({ left: 16, right: 8 })
        .layoutWeight(1)


        Blank()
        Image($r('app.media.more'))
          .padding(8)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .onClick(() => {
            this.totalModerator = this.getTotalModerator()
            this.totalMute = this.getTotalMute()
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
          })
          .bindSheet($$this.isShowPlaySettingSheet, this.setModeratorOrMute(), {
            backgroundColor: $r('sys.color.comp_background_tertiary'),
            blurStyle: BlurStyle.COMPONENT_THICK,
            height: 448,
            preferType: SheetType.CENTER,
            title: titleBuilder('设置')
          })
      }
      .width('100%')
      .height(40)
    }
    .position({ bottom: 16 })
  }
}

