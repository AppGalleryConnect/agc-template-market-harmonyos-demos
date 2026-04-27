import { BulletSettingItem } from '../models/BulletSettingData';
import { BulletView } from './BulletView';
import { BulletVM } from '../viewModels/BulletVM';

@ComponentV2
export struct BulletLayer {

  @Param @Require bulletVM: BulletVM
  @Param screenDirection: number = 0
  createBullet: number = -1
  timer: number = -1

  aboutToAppear(): void {
    if (!this.bulletVM.storage.setting.has('setting')) {
      this.bulletVM.storage.setting.set('setting', new BulletSettingItem())
    }

    // 生成弹幕
    this.createBullet = setInterval(() => {
      this.bulletVM.createBulletComment(this.getUIContext())
    }, 1500)

    // 弹幕移动
    this.timer = setInterval(() => {
      this.bulletVM.bulletMove(this.getUIContext())
    }, 100)
  }

  aboutToDisappear(): void {
    clearInterval(this.createBullet)
    clearInterval(this.timer)
    this.bulletVM.bulletComments = []
    this.bulletVM.xTrans = []
  }

  build() {
    // 视频上方弹幕
    BulletView({ bulletComments: this.bulletVM.bulletComments, xTrans: this.bulletVM.xTrans })
      .position({ top: this.screenDirection === 0 ? 124 : 12 })
  }
}