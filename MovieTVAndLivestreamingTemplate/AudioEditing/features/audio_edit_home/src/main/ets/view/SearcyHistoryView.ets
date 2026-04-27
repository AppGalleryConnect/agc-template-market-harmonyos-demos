import { PersistenceV2Util } from 'audio_common'

export class HistoryController {
  addData = (val: string) => {
  }
}

@ComponentV2
export struct SearcyHistoryView {
  @Param historyContrller: HistoryController = new HistoryController()
  persistenceV2Util: PersistenceV2Util = new PersistenceV2Util()
  @Local historyData: string[] = []
  @Param historyOnclick: (val: string) => void = (val: string) => {
  }
  addData = (val: string) => {
    let tempData = this.persistenceV2Util.getHistory()
    let tempArr: string[] = []
    if (tempData) {
      tempArr = JSON.parse(tempData)
      if (tempArr.indexOf(val) > -1) {
        return
      }
    }
    tempArr.unshift(val)
    if(!this.persistenceV2Util.setHistory(JSON.stringify(tempArr))){
      this.getUIContext().getPromptAction().showToast({ message: '历史记录数据太多无法存储啦' })
    }
    this.historyData = tempArr
  }

  aboutToAppear(): void {
    let tempData = this.persistenceV2Util.getHistory()
    if (tempData) {
      this.historyData = JSON.parse(tempData) as string[]
    }
    this.historyContrller.addData = this.addData
  }

  build() {
    Column() {
      Row() {
        Text('历史搜索').fontSize(14).fontColor('#99FFFFFF')
        Text() {
          ImageSpan($r('app.media.ic_history_del')).width(18).height(18)
            .verticalAlign(ImageSpanAlignment.CENTER)
          Span('清空').fontSize(14).fontColor('#99FFFFFF')
        }
        .onClick(() => {
          this.historyData = []
          this.persistenceV2Util.setHistory('')
        })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 25 })

      if (!this.historyData.length) {
        Text('暂无历史搜索').fontSize(14).fontColor('#99FFFFFF')
          .margin({ top: 12 })
      }
      if (this.historyData.length) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.historyData, (item: string, index: number) => {
            Text(item)
              .fontSize(14)
              .fontColor('#C9FFFFFF')
              .height(28)
              .halfLeading(true)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#66FFFFFF')
              .borderRadius(14)
              .margin({ right: 8, bottom: 10 })
              .onClick(() => {
                this.historyOnclick(item)
              })
          }, (item: string, index: number) => item)
        }
        .margin({ top: 15 })
      }
    }
  }
}