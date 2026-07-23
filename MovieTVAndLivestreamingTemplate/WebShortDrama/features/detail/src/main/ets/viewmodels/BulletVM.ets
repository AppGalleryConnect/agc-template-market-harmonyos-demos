import { BulletItem } from '../models/BulletItem'
import { BulletSettingItem, BulletSettingStorage } from '../models/BulletSettingData';
import { MeasureText, window } from '@kit.ArkUI';

const comments: Array<string> = [
  '我来组成弹幕大军', '第一次发有点小激动哦', '战争的确太残酷了', '说真的看不懂现在的电影了',
  '希望世界和平', '真的是笑死我了', '这个主播怎么这么会搞节目效果', '哈哈哈哈哈哈！！！'
]

@ObservedV2
export class BulletVM {
  @Trace bulletComments: Array<BulletItem> = []
  @Trace xTrans: Array<number> = []
  @Trace storage: BulletSettingStorage = BulletSettingStorage.instance();
  @Trace isPause: boolean = false
  private createBullet: number = -1
  private timer: number = -1
  windowStage: window.WindowStage = AppStorage.get('windowStage')!

  // 生成弹幕
  createBulletComment() {
    if (this.bulletComments.length <= 4 * this.storage.setting.get('setting')?.rowsNum!) {
      for (let i = 0; i < this.storage.setting.get('setting')?.rowsNum!; i++) {
        this.bulletComments = [...this.bulletComments, new BulletItem(
          comments[this.bulletComments.length % 8],
          false,
          this.storage.setting.get('setting')?.rowsNum!,
          this.storage.setting.get('setting')?.notOpacity!,
          this.storage.setting.get('setting')?.danMuSpeed!,
          this.storage.setting.get('setting')?.danMuSize!
        )]
        this.xTrans = [...this.xTrans, this.xTrans.length < this.storage.setting.get('setting')?.rowsNum! ?
          400 + 10 * (this.xTrans.length % this.storage.setting.get('setting')?.rowsNum!) :
          (this.xTrans[this.xTrans.length -
            this.storage.setting.get('setting')?.rowsNum!] + 30 + this.windowStage.getMainWindowSync()
            .getUIContext()
            .px2vp(this.windowStage.getMainWindowSync()
              .getUIContext()
              .getMeasureUtils()
              .measureText({
                textContent: this.bulletComments[this.bulletComments.length - 1 -
                  this.storage.setting.get('setting')?.rowsNum!].content,
                fontSize: `20vp`
              })))]
      }
    }
  }

  // 弹幕移动
  bulletMove() {
    this.xTrans.forEach((item, index) => {
      this.xTrans[index] = item - this.bulletComments[index].speed
    })
    // 移除超出屏幕的弹幕并触发更新
    this.bulletComments = this.bulletComments.filter((item, index) => this.xTrans[index] > -300)
    this.xTrans = this.xTrans.filter(item => item > -300)
  }

  // 开启弹幕
  startBullet() {
    if (!this.storage.setting.has('setting')) {
      this.storage.setting.set('setting', new BulletSettingItem())
    }

    // 生成弹幕
    this.createBullet = setInterval(() => {
      this.createBulletComment()
    }, 1500)

    // 弹幕移动
    this.timer = setInterval(() => {
      this.bulletMove()
    }, 16)

    this.isPause = false
  }

  // 关闭弹幕
  closeBullet() {
    clearInterval(this.createBullet)
    clearInterval(this.timer)
    this.bulletComments = []
    this.xTrans = []
  }

  // 暂停弹幕
  pauseBullet() {
    clearInterval(this.timer)
    this.isPause = true
  }
}