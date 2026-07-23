import { GuideService } from '../model/GuideService'
import { DRIVE_STAGE, LICENSE_TYPE, LICENSE_LIST_ONE, LICENSE_LIST_TWO, LICENSE_CARD } from '../model/model'
import { SelectCard } from './SelectCard'
import { CommonConstants } from '../constants/CommonContants'
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'

@ComponentV2
export struct GuideView {
  @Local activeId: DRIVE_STAGE = 0
  @Local bottomRectHeight: number = 0
  @Local topRectHeight: number = 0
  @Event goCitySelectPage: VoidCallback
  @Event completed: VoidCallback
  guideService: GuideService = GuideService.instance
  vm: CommonModel = CommonModel.instance
  layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index === 0) {
        return [0, 0, 1, 3]
      }
      return [0, 0, 1, 2]
    }
  }

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0
    this.topRectHeight = AppStorage.get('topRectHeight') || 0
  }

  @Builder
  titleView(title: Resource) {
    Text(title)
      .width(CommonConstants.FULL_WIDTH)
      .fontColor($r('sys.color.font_primary'))
      .fontSize(14)
      .maxFontScale(1)
      .margin({
        bottom: 12,
        top: 24
      })
  }

  @Builder
  selectButton(buttonName: Resource, id: DRIVE_STAGE) {
    Text(buttonName)
      .layoutWeight(1)
      .backgroundColor(id === this.activeId ? '#64BB5C' : $r('sys.color.comp_background_primary'))
      .height(36)
      .borderRadius(16)
      .fontColor(id === this.activeId ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
      .fontSize(14)
      .textAlign(TextAlign.Center)
      .maxFontScale(1)
      .onClick(() => {
        this.activeId = id
        this.guideService.updateDriveStage(id)
      })
  }

  @Builder
  selectCity() {
    Row() {
      Row() {
        Image($r('app.media.locations'))
          .width(16)
          .height(16)
          .margin({
            right: 4
          })
        Text(this.guideService.getGuideData().city || $r('app.string.please_select_city'))
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .maxFontScale(1)
      }

      Row() {
        Text($r('app.string.go_select'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({
            right: 4
          })
          .maxFontScale(1)
        Image($r('app.media.ic_right_arrow_lined'))
          .height(16)
          .width(16)
      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(40)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12
    })
    .onClick(() => {
      this.goCitySelectPage()
    })
  }

  @Builder
  licenseTypeSelection() {
    this.titleView($r('app.string.select_license_type'))
    if (this.vm.isLargeDevice) {
      this.largeDeviceBuilder()
    } else {
      this.smDeviceBuilder()
    }
  }

  @Builder
  largeDeviceBuilder() {
    Grid(undefined, this.layoutOptions) {
      ForEach(LICENSE_LIST_ONE, (item: LICENSE_CARD) => {
        GridItem() {
          SelectCard({
            value: item.value,
            contentWidth: 0
          }) {
            Column() {
              Image(item.icon)
                .height(29)
                .margin({
                  bottom: 14,
                  top: 31
                })

              Row() {
                Text(item.name)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize(12)
                  .maxFontScale(1)

                Text(item.description)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize(12)
                  .maxFontScale(1)
                  .margin({
                    left: 10
                  })
              }
            }
            .borderRadius(20)
            .width(CommonConstants.FULL_WIDTH)
            .height(CommonConstants.FULL_HEIGHT)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onClick(() => {
              this.guideService.updateLicenseType(item.value)
            })
          }
        }
      }, (item: LICENSE_CARD) => JSON.stringify(item))

      ForEach(LICENSE_LIST_TWO, (item: LICENSE_CARD) => {
        GridItem() {
          SelectCard({
            value: item.value
          }) {
            Column() {
              Image(item.icon)
                .height(34)
                .margin({
                  top: 16,
                  bottom: 4
                })

              Text(item.name)
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .maxFontScale(1)
                .margin({
                  bottom: 4
                })

              Text(item.description)
                .fontSize(12)
                .maxFontScale(1)
                .fontColor($r('sys.color.font_secondary'))
            }
            .borderRadius(20)
            .width(CommonConstants.FULL_WIDTH)
            .height(CommonConstants.FULL_HEIGHT)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onClick(() => {
              this.guideService.updateLicenseType(item.value)
            })
          }
        }
      }, (item: LICENSE_CARD) => JSON.stringify(item))
    }
    .columnsTemplate('1fr '.repeat(11))
    .rowsTemplate('1fr')
    .columnsGap(18)
    .height(102)
    .width(CommonConstants.FULL_WIDTH)
  }

  @Builder
  smDeviceBuilder() {
    Row({ space: 12 }) {
      ForEach(LICENSE_LIST_ONE, (item: LICENSE_CARD) => {
        SelectCard({
          value: item.value,
          contentWidth: item.width || 0
        }) {
          Column() {
            Image(item.icon)
              .height(29)
              .margin({
                bottom: 14,
                top: 31
              })

            Row() {
              Text(item.name)
                .fontColor($r('sys.color.font_primary'))
                .fontSize(12)
                .maxFontScale(1)

              Text(item.description)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(12)
                .maxFontScale(1)
                .margin({
                  left: 10
                })
            }
          }
          .borderRadius(20)
          .width(CommonConstants.FULL_WIDTH)
          .height(CommonConstants.FULL_HEIGHT)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onClick(() => {
            this.guideService.updateLicenseType(item.value)
          })
        }
      }, (item: LICENSE_CARD) => JSON.stringify(item))
    }
    .height(102)
    .width(CommonConstants.FULL_WIDTH)
    .margin({
      bottom: 12
    })

    Row({ space: 12 }) {
      ForEach(LICENSE_LIST_TWO, (item: LICENSE_CARD) => {
        SelectCard({
          value: item.value
        }) {
          Column() {
            Image(item.icon)
              .height(34)
              .margin({
                top: 16,
                bottom: 4
              })

            Text(item.name)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .maxFontScale(1)
              .margin({
                bottom: 4
              })

            Text(item.description)
              .fontSize(12)
              .maxFontScale(1)
              .fontColor($r('sys.color.font_secondary'))
          }
          .borderRadius(20)
          .width(CommonConstants.FULL_WIDTH)
          .height(CommonConstants.FULL_HEIGHT)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onClick(() => {
            this.guideService.updateLicenseType(item.value)
          })
        }
      }, (item: LICENSE_CARD) => JSON.stringify(item))
    }
    .height(102)
    .width(CommonConstants.FULL_WIDTH)
  }

  build() {
    Stack() {
      Image($r('app.media.guide_bg'))
        .width(CommonConstants.FULL_WIDTH)
        .height(268)
      Scroll() {
        Column() {
          Column() {
            Text($r('app.string.guide_title'))
              .height(32)
              .width(CommonConstants.FULL_WIDTH)
              .fontSize(24)
              .fontColor($r('sys.color.font_primary'))
              .maxFontScale(1)
              .margin({
                top: this.getUIContext().px2vp(this.topRectHeight) + 12
              })
            this.titleView($r('app.string.select_city'))
            this.selectCity()

            this.licenseTypeSelection()

            this.titleView($r('app.string.select_drive_stage'))
            Row({ space: 12 }) {
              this.selectButton($r('app.string.subject_one'), DRIVE_STAGE.SUBJECT_ONE)
              this.selectButton($r('app.string.subject_two'), DRIVE_STAGE.SUBJECT_TWO)
              this.selectButton($r('app.string.subject_three'), DRIVE_STAGE.SUBJECT_THREE)
              this.selectButton($r('app.string.subject_four'), DRIVE_STAGE.SUBJECT_FOUR)
            }
          }
          .width(CommonConstants.FULL_WIDTH)

          Text($r('app.string.finished'))
            .width(CommonConstants.FULL_WIDTH)
            .height(40)
            .borderRadius(20)
            .fontColor(Color.White)
            .backgroundColor('#64BB5C')
            .textAlign(TextAlign.Center)
            .maxFontScale(1)
            .onClick(() => {
              this.guideService.changeGuidanceStatus(this.getUIContext())
              if (this.guideService.isCompleteGuidance()) {
                this.completed()
              }
            })
            .margin({
              bottom: this.getUIContext().px2vp(this.bottomRectHeight)
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 16,
          right: 16
        })
      }
    }
    .height(CommonConstants.FULL_WIDTH)
    .width(CommonConstants.FULL_WIDTH)
    .alignContent(Alignment.Top)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}