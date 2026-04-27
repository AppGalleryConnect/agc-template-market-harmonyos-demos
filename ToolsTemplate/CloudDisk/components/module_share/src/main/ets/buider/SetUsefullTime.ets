import { PopViewUtils } from '../utils/PopViewUtils'
import { RowType } from '../componts/RowType'
import { TopHeader } from '../componts/TopHeader'
import { ShareUsefullTimeParam } from '../model/Model'
import { FileInfo } from 'common'

@Builder
export function SetUseFullTimeBuilder(param: ShareUsefullTimeParam) {
  SetUseFullTime({
    params: param,
  })
}

@ComponentV2
struct SetUseFullTime {
  @Require @Param params: ShareUsefullTimeParam

  aboutToAppear(): void {
    if (this.params.fileInfo === undefined) {
      return
    }

    if (this.params.fileInfo.expireTime === -1) {
      this.params.blockUsefullTimeId = 4
    } else {
      let expireTime: string = ''
      if (this.params.fileInfo instanceof FileInfo) {
        expireTime = this.params.fileInfo.checkExpireTime()
      } else {
        expireTime = this.params.fileInfo.checkShareExpireTime()
      }

      if (expireTime === '7天后过期') {
        this.params.blockUsefullTimeId = 1
      } else if (expireTime === '14天后过期') {
        this.params.blockUsefullTimeId = 2
      } else if (expireTime === '30天后过期') {
        this.params.blockUsefullTimeId = 3
      }
    }

  }

  build() {
    Column() {
      TopHeader({ title: $r('app.string.set_usefull_time') })
      RowType({ title: $r('app.string.seven_day'), isSelect: this.params.blockUsefullTimeId === 1 ? true : false })
        .margin({ top: 24 })
        .onClick(() => {
          this.done(1, $r('app.string.seven_day'))
        })
      RowType({ title: $r('app.string.forty_day'), isSelect: this.params.blockUsefullTimeId === 2 ? true : false })
        .onClick(() => {
          this.done(2, $r('app.string.forty_day'))
        })
      RowType({ title: $r('app.string.one_month'), isSelect: this.params.blockUsefullTimeId === 3 ? true : false })
        .onClick(() => {
          this.done(3, $r('app.string.one_month'))
        })
      RowType({ title: $r('app.string.for_every'), isSelect: this.params.blockUsefullTimeId === 4 ? true : false })
        .onClick(() => {
          this.done(4, $r('app.string.for_every'))
        })
    }
    .backgroundColor(Color.White)
    .padding(24)
  }

  done(status: number, content: string | Resource) {
    if (this.params.blockUsefullTime) {
      this.params.blockUsefullTime(status, content)
    }
    PopViewUtils.closeSheet()
  }
}