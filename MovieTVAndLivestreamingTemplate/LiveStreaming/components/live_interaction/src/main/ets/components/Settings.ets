import { BulletSettingItem } from '../models/BulletSettingData';
import { BulletVM } from '../viewModels/BulletVM';
import { BulletSetting } from './FullScreenComponents/BulletSetting';
import { promptAction } from '@kit.ArkUI';
import { Report } from './Report';
import { Share } from 'module_share';
import { Audience } from '../models/Audience';
import { ShareInfo } from '../manager/LiveInteractionMgr';

@Preview
@ComponentV2
export struct Settings {
  @Param @Require bulletVM: BulletVM
  @Param @Require defaultResolution: string
  @Param @Require shareInfo: ShareInfo
  @Event sheetHide: () => void
  @Event clearScreen: () => void
  @Event onPip: Function = () => {
  }
  @Local rowsNum: number = 2;
  @Local notOpacity: number = 80;
  @Local danMuSpeed: string = '适中';
  @Local danMuSize: string = '适中';
  @Local isShowBulletSettingSheet: boolean = false
  @Event onChangeResolution: Function = () => {
  }
  @Event onReport: Function = () => {
  }

  @Monitor('isShowBulletSettingSheet')
  resetBulletSetting() {
    if (this.isShowBulletSettingSheet) {
      this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
      this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
      this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
      this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
    }
  }

  @Local isShowShareSheet: boolean = false
  @Local isShowReportSheet: boolean = false
  @Local isShowResolutionSheet: boolean = false

  aboutToAppear(): void {
    if (!this.bulletVM.storage.setting.has('setting')) {
      this.bulletVM.storage.setting.set('setting', new BulletSettingItem())
    }
    this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
    this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
    this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
    this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
  }

  @Builder
  settingItem(name: string, icon: Resource) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(32)
        .fontColor([$r('sys.color.icon_primary')])
        .margin({ bottom: 2, top: 4 })

      Text(name)
        .width(74)
        .height(16)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })
    }
    .width(82)
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  bulletSettingSheet() {
    Column() {
      Row() {
        Image($r('app.media.handle'))
          .width(48)
          .height(4)
          .margin({ top: 8, left: 24 })
          .onClick(() => {
            this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
          })
      }
      .width(96)
      .height(16)

      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
        })

        Text('弹幕设置')
          .width(232)
          .height(27)
          .fontSize(20)
          .fontWeight(700)
          .margin({ left: 8, right: 8 })
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          if (this.bulletVM.storage.setting.get('setting')?.rowsNum! === this.rowsNum) {
            this.bulletVM.bulletComments.forEach((item) => {
              item.opacity = this.notOpacity / 100
              item.size = this.danMuSize === '小' ? 12 : (this.danMuSize === '适中' ? 16 : 20)
              item.speed = this.danMuSpeed === '慢' ? 3 : (this.danMuSpeed === '适中' ? 6 : 12)
            })
          } else {
            this.bulletVM.bulletComments = []
            this.bulletVM.xTrans = []
          }
          let bulletSettingItem: BulletSettingItem = new BulletSettingItem()
          bulletSettingItem.rowsNum = this.rowsNum
          bulletSettingItem.notOpacity = this.notOpacity
          bulletSettingItem.danMuSpeed = this.danMuSpeed
          bulletSettingItem.danMuSize = this.danMuSize
          this.bulletVM.storage.setting.set('setting', bulletSettingItem)
          this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
        })
      }
      .width(328)
      .height(56)
      .margin({ bottom: 16 })

      BulletSetting({
        rowsNum: this.rowsNum,
        notOpacity: this.notOpacity,
        danMuSpeed: this.danMuSpeed,
        danMuSize: this.danMuSize,
        setRowsNum: (set: number) => {
          this.rowsNum = set
        },
        setNotOpacity: (set: number) => {
          this.notOpacity = set
        },
        setDanMuSpeed: (set: string) => {
          this.danMuSpeed = set
        },
        setDanMuSize: (set: string) => {
          this.danMuSize = set
        }
      })
    }
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  shareBuilder() {
    this.settingItem('分享', $r('sys.symbol.share'))
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
  resolutionSheet() {
    Column() {
      Resolution({
        defaultResolution: this.defaultResolution,
        setHide: () => {
          this.isShowResolutionSheet = !this.isShowResolutionSheet
          this.sheetHide()
        },
        onChangeResolution: this.onChangeResolution
      })
    }
    .width(328)
    .height(243)
  }

  build() {
    Grid() {
      GridItem() {
        Share({
          qrCodeInfo: { id: this.shareInfo.id },
          coverUrl: this.shareInfo.cover as string,
          title: this.shareInfo.title,
          articleFrom: this.shareInfo.articleFrom,
          createTime: '',
          shareRenderBuilder: () => {
            this.shareBuilder()
          }
        })
      }

      GridItem() {
        this.settingItem('弹幕设置', $r('sys.symbol.keyboard_badge_gearshape'))
      }
      .bindSheet($$this.isShowBulletSettingSheet, this.bulletSettingSheet(), {
        height: 372,
        showClose: false,
        preferType: SheetType.CENTER,
      })
      .onClick(() => {
        this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
      })

      GridItem() {
        this.settingItem('画中画', $r('sys.symbol.smal_window_playback'))
      }
      .onClick(() => {
        this.onPip()
        this.sheetHide()
      })

      GridItem() {
        this.settingItem('清晰度', $r('sys.symbol.hd_plus_rectangle'))
      }
      .bindSheet($$this.isShowResolutionSheet, this.resolutionSheet(), {
        height: 363,
        showClose: false,
        preferType: SheetType.CENTER,
      })
      .onClick(() => {
        this.isShowResolutionSheet = !this.isShowResolutionSheet
      })

      GridItem() {
        this.settingItem('举报', $r('sys.symbol.exclamationmark_triangle'))
      }
      .bindSheet($$this.isShowReportSheet, this.reportSheet(), {
        height: 665,
        showClose: false,
        preferType: SheetType.CENTER,
      })
      .onClick(() => {
        this.isShowReportSheet = !this.isShowReportSheet
      })

      GridItem() {
        this.settingItem('清屏', $r('sys.symbol.square_slash'))
      }
      .onClick(() => {
        this.sheetHide()
        this.clearScreen()
      })
    }
    .height(135)
    .width(328)
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(8)
  }
}


@ObservedV2
export class ResolutionStorage {
  static singleton: ResolutionStorage;

  static instance() {
    if (!ResolutionStorage.singleton) {
      ResolutionStorage.singleton = new ResolutionStorage();
    }
    ;
    return ResolutionStorage.singleton;
  }

  @Trace defaultSetting: string = ''
  @Trace nowSetting: string = ''
}


@ComponentV2
struct Resolution {
  @Param @Require defaultResolution: string
  private resolution: string[] = ['1080P 原画（高帧率）', '1080P 蓝光', '720P超清', '480P高清']
  private uiContext: UIContext = this.getUIContext()
  @Local nowResolution: string = '1080P 原画（高帧率）'
  @Local resolutionStorage: ResolutionStorage = ResolutionStorage.instance()
  @Event setHide: () => void
  @Event onChangeResolution: Function = () => {
  }


  aboutToAppear(): void {
    if (this.resolutionStorage.defaultSetting !== this.defaultResolution) {
      this.resolutionStorage.defaultSetting = this.defaultResolution
      this.resolutionStorage.nowSetting = this.defaultResolution
      this.nowResolution = this.defaultResolution
    } else {
      this.nowResolution = this.resolutionStorage.nowSetting
    }
  }

  build() {
    Column() {
      Row() {
        Text('清晰度')
          .width(232)
          .height(27)
          .fontSize(20)
          .fontWeight(700)
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          this.resolutionStorage.nowSetting = this.nowResolution
          this.onChangeResolution(this.nowResolution)
          this.setHide()
          this.uiContext.getPromptAction().showToast({ message: '清晰度切换成功' })
        })
      }
      .width(328)
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      Column() {
        ForEach(
          this.resolution,
          (item: string) => {
            Row() {
              Text(item)
                .fontSize(16)
                .fontWeight(500)
                .fontColor(this.nowResolution === item ? '#EE5D1A' : $r('sys.color.font_primary'))
            }
            .width(304)
            .height(48)
            .onClick(() => {
              this.nowResolution = item
            })
            .margin({ top: 16 })

            Divider()
              .strokeWidth('1px')
          },
          (item: string) => item
        )
      }
    }
  }
}

