@ComponentV2
export struct BulletSettingPanel {
  // 当前值（受控）
  @Param @Require rowsNum: number;
  @Param @Require notOpacity: number;
  @Param @Require danMuSpeed: string;
  @Param @Require danMuSize: string;
  // 回调（用于非自动保存场景）
  @Event onRowsNumChange: (value: number) => void = () => {
  };
  @Event onNotOpacityChange: (value: number) => void = () => {
  };
  @Event onDanMuSpeedChange: (value: string) => void = () => {
  };
  @Event onDanMuSizeChange: (value: string) => void = () => {
  };
  // 是否启用“自动保存”模式（true 表示内部处理，false 表示只触发回调）
  @Param @Require autoSave: boolean;
  // 仅在 autoSave=true 时使用（例如 FullScreenBulletSetting）
  @Event onSave?: () => void;

  build() {
    Column({ space: 16 }) {
      // 显示行数
      Row() {
        Text('显示行数')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontColor(this.autoSave ? '#fff' : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            [1, 2, 3, 4, 5, 6],
            (item: number) => {
              Text(`${item}`)
                .width(43)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.rowsNum === item ? (this.autoSave ? '#E5FFFFFF' : $r('sys.color.font_primary')) :
                  (this.autoSave ? '#99FFFFFF' : $r('sys.color.font_secondary')))
                .backgroundColor(this.rowsNum === item ?
                  (this.autoSave ? '#666666' : $r('sys.color.comp_background_list_card')) : 'transparent')
                .shadow(this.rowsNum === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  this.onRowsNumChange(item)
                  if (this.autoSave) {
                    this.onSave?.()
                  }
                })
            }, (item: number, index: number) => {
            return index + '__' + JSON.stringify(item);
          }
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor(this.autoSave ? '#333333' : $r('sys.color.comp_background_tertiary'))
      }
      .width(328)
      .height(48)

      // 不透明度
      Row() {
        Text('不透明度')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontColor(this.autoSave ? '#fff' : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            [20, 40, 60, 80, 100],
            (item: number) => {
              Text(item === 0 ? '' : `${item}%`)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.notOpacity === item ? (this.autoSave ? '#E5FFFFFF' : $r('sys.color.font_primary')) :
                  (this.autoSave ? '#99FFFFFF' : $r('sys.color.font_secondary')))
                .backgroundColor(this.notOpacity === item ?
                  (this.autoSave ? '#666666' : $r('sys.color.comp_background_list_card')) : 'transparent')
                .shadow(this.notOpacity === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  this.onNotOpacityChange(item)
                  if (this.autoSave) {
                    this.onSave?.()
                  }
                })
            }, (item: number, index: number) => {
            return index + '__' + JSON.stringify(item);
          }
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor(this.autoSave ? '#333333' : $r('sys.color.comp_background_tertiary'))
      }
      .width(328)
      .height(48)

      // 弹幕速度
      Row() {
        Text('弹幕速度')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontColor(this.autoSave ? '#fff' : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['慢', '', '适中', '', '快'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSpeed === item ? (this.autoSave ? '#E5FFFFFF' : $r('sys.color.font_primary')) :
                  (this.autoSave ? '#99FFFFFF' : $r('sys.color.font_secondary')))
                .backgroundColor(this.danMuSpeed === item ?
                  (this.autoSave ? '#666666' : $r('sys.color.comp_background_list_card')) : 'transparent')
                .shadow(this.danMuSpeed === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.onDanMuSpeedChange(item)
                    if (this.autoSave) {
                      this.onSave?.()
                    }
                  }
                })
            }, (item: string, index: number) => {
            return index + '__' + JSON.stringify(item);
          }
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor(this.autoSave ? '#333333' : $r('sys.color.comp_background_tertiary'))
      }
      .width(328)
      .height(48)

      // 弹幕字号
      Row() {
        Text('弹幕字号')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontColor(this.autoSave ? '#fff' : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['小', '', '适中', '', '大'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSize === item ? (this.autoSave ? '#E5FFFFFF' : $r('sys.color.font_primary')) :
                  (this.autoSave ? '#99FFFFFF' : $r('sys.color.font_secondary')))
                .backgroundColor(this.danMuSize === item ?
                  (this.autoSave ? '#666666' : $r('sys.color.comp_background_list_card')) : 'transparent')
                .shadow(this.danMuSize === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.onDanMuSizeChange(item)
                    if (this.autoSave) {
                      this.onSave?.()
                    }
                  }
                })
            }, (item: string, index: number) => {
            return index + '__' + JSON.stringify(item);
          }
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor(this.autoSave ? '#333333' : $r('sys.color.comp_background_tertiary'))
      }
      .width(328)
      .height(48)
    }
  }
}