import { BulletVM } from '../../viewModels/BulletVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { BulletSettingItem } from '../../models/BulletSettingData';
import { BulletSettingPanel } from '../../models/BulletSettingPanel'

@ComponentV2
export struct FullScreenBulletSetting {

  @Local rowsNum: number = 2;
  @Local notOpacity: number = 80;
  @Local danMuSpeed: string = '适中';
  @Local danMuSize: string = '适中';
  @Local bulletVM: BulletVM = AppStorageV2.connect(BulletVM, 'bulletVM', () => new BulletVM())!
  @Event setHide: () => void
  @Event closeAll: () => void

  aboutToAppear(): void {
    if (!this.bulletVM.storage.setting.has('setting')) {
      this.bulletVM.storage.setting.set('setting', new BulletSettingItem())
    }
    this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
    this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
    this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
    this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
  }

  saveSettings() {
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
  }


  build() {
    Row() {
      Column()
        .height('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.closeAll()
        })
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .margin({ left: 24 })
            .onClick(() => {
              this.setHide()
            })
          Text('弹幕设置')
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .fontColor('#fff')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(56)
        .margin({ top: 22 })

        BulletSettingPanel({
          rowsNum: this.rowsNum,
          notOpacity: this.notOpacity,
          danMuSpeed: this.danMuSpeed,
          danMuSize: this.danMuSize,
          autoSave: true,
          onRowsNumChange: (v) => { this.rowsNum = v; },
          onNotOpacityChange: (v) => { this.notOpacity = v; },
          onDanMuSpeedChange: (v) => { this.danMuSpeed = v; },
          onDanMuSizeChange: (v) => { this.danMuSize = v; },
          onSave: () => {this.saveSettings()}
        })
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .width('100%')
    .height('100%')
  }
}