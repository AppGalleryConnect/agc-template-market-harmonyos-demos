import { BulletItem } from '../models/BulletItem'
import { BulletSettingStorage } from '../models/BulletSettingData';

const comments: Array<string> = [
  '我来组成弹幕大军', '第一次发有点小激动哦', '战争的确太残酷了', '说真的看不懂现在的电影了',
  '希望世界和平', '真的是笑死我了', '这个主播怎么这么会搞节目效果', '哈哈哈哈哈哈！！！'
]

@ObservedV2
export class BulletVM {
  @Trace bulletComments: Array<BulletItem> = []
  @Trace xTrans: Array<number> = []
  @Trace storage: BulletSettingStorage = BulletSettingStorage.instance();
  @Trace direction: number = 0 // 屏幕方向 0表示当前为竖屏

  // 生成弹幕
  createBulletComment(uiContext: UIContext) {
    if (this.bulletComments.length < 4 * this.storage.setting.get('setting')?.rowsNum!) {
      for (let i = 0; i < this.storage.setting.get('setting')?.rowsNum!; i++) {
        let index: number = Math.floor(Math.random() * 8)
        this.bulletComments = [...this.bulletComments, new BulletItem(
          comments[index],
          false,
          this.storage.setting.get('setting')?.rowsNum!,
          this.storage.setting.get('setting')?.notOpacity!,
          this.storage.setting.get('setting')?.danMuSpeed!,
          this.storage.setting.get('setting')?.danMuSize!
        )]
        this.xTrans = [...this.xTrans, this.bulletComments.length < this.storage.setting.get('setting')?.rowsNum! ?
          (this.direction === 0 ? 400 : 700) +
            10 * Math.floor((Math.random() * 60) % this.storage.setting.get('setting')?.rowsNum!) :
          (this.xTrans[this.bulletComments.length -
            this.storage.setting.get('setting')?.rowsNum!] + 30 +
          uiContext.px2vp(uiContext.getMeasureUtils().measureText({
            textContent: this.bulletComments[this.bulletComments.length -
              this.storage.setting.get('setting')?.rowsNum!].content,
            fontSize: `20vp`
          })))]
      }
    }
  }

  // 弹幕移动
  bulletMove(uiContext: UIContext) {
    uiContext.animateTo({ duration: 100, curve: Curve.Linear }, () => {
      this.xTrans.forEach((item, index) => {
        this.xTrans[index] = item - this.bulletComments[index].speed
      })
    })
    // 移除超出屏幕的弹幕并触发更新
    this.bulletComments = this.bulletComments.filter((item, index) => this.xTrans[index] > -300)
    this.xTrans = this.xTrans.filter(item => item > -300)
  }
}