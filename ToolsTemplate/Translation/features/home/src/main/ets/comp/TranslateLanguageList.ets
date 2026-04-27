import { Language, VipUpgradeDialog } from 'choose_language'

/**
 * 语言选择列表组件
 */
@ComponentV2
export struct TranslateLanguageList {
  @Param @Require languages: Language[]
  @Param @Require selectedLanguageCode: string
  @Param @Require onLanguageSelect: (language: Language) => void
  @Param isVipUser: boolean = false
  @Param onVipUpgrade?: () => void = undefined
  @Param onShowVipDialog?: () => void = undefined
  @Local showVipDialog: boolean = false

  build() {
    Stack() {
      Column() {
        // 常用语言标题
        Text('常用语言')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('sys.color.font_primary'))
          .width('100%')
          .margin({ top: 16, bottom: 12, left: 16 })

        // 语言列表
        List({ space: 0 }) {
          ForEach(this.languages, (language: Language) => {
            ListItem() {
              Row() {
                // 语言名称和VIP图标
                Row({ space: 8 }) {
                  Text(language.name)
                    .fontSize(16)
                    .fontColor($r('sys.color.font_primary'))

                  // VIP标识
                  if (language.isVip) {
                    Image($r('app.media.VIP'))
                      .width(16)
                      .height(16)
                      .objectFit(ImageFit.Contain)
                  }
                }
                .layoutWeight(1)

                // 选中状态
                if (this.selectedLanguageCode === language.code) {
                  SymbolGlyph($r('sys.symbol.checkmark'))
                    .fontSize(20)
                    .fontColor([$r('sys.color.icon_emphasize')])
                }
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                if (language.isVip && !this.isVipUser) {
                  // 优先使用外部回调
                  if (this.onShowVipDialog) {
                    this.onShowVipDialog()
                  } else {
                    // 否则在内部显示VIP升级弹窗
                    this.showVipDialog = true
                  }
                  return
                }
                this.onLanguageSelect(language)
              })
            }
          })
          // 底部占位
          ListItem() {
            Column().height(40)
          }
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .layoutWeight(1)
        .divider({
          strokeWidth: 1,
          color: '#F0F0F0',
          startMargin: 16,
          endMargin: 16
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      // VIP升级弹窗
      if (this.showVipDialog && !this.onShowVipDialog) {
        VipUpgradeDialog({
          visible: this.showVipDialog,
          onClose: () => {
            this.showVipDialog = false
          },
          onUpgrade: () => {
            this.showVipDialog = false
            if (this.onVipUpgrade) {
              this.onVipUpgrade()
            }
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
