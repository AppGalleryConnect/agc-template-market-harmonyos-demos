import { Constants } from 'common';

@ComponentV2
export struct DeleteBottomCard {
  @Param isShelf: boolean = true
  @Param isGroupManage: boolean = false
  @Consumer('isSelectAll') isSelectAll: boolean = false;
  @Event selectAll: (select: boolean) => void = () => {
  };
  @Event changeGroup: () => void = () => {
  };
  @Event delete: () => void = () => {
  };
  @Event download: () => void = () => {
  };
  @Event pin: () => void = () => {
  };

  build() {
    Row() {
      Row() {
        Column({ space: 5 }) {
          SymbolGlyph($r('sys.symbol.checkmark_square_on_square'))
            .fontSize(24)
            .fontColor(this.isSelectAll ? [$r('sys.color.multi_color_08')] : [$r('sys.color.icon_primary')])
          Row() {
            Text($r('app.string.select_all'))
              .fontSize(10)
              .fontColor(this.isSelectAll ? $r('sys.color.multi_color_08') : $r('sys.color.font_primary'))
          }
        }
        .justifyContent(FlexAlign.Center)
        .size({ height: 56, width: 56 })
        .onClick(() => {
          this.selectAll(this.isSelectAll)
          this.isSelectAll = !this.isSelectAll
        })

        if (this.isShelf) {
          Column({ space: 5 }) {
            SymbolGlyph($r('sys.symbol.arrow_right_folder_circle'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(24)
            Row() {
              Text($r('app.string.change_group'))
                .fontSize(10)
            }
          }
          .justifyContent(FlexAlign.Center)
          .size({ height: 56, width: 56 })
          .onClick(() => {
            this.changeGroup();
            this.isSelectAll = false;
          })

          Column({ space: 5 }) {
            SymbolGlyph($r('sys.symbol.download'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(24)
            Row() {
              Text($r('app.string.download'))
                .fontSize(10)
            }
          }
          .justifyContent(FlexAlign.Center)
          .size({ height: 56, width: 56 })
          .onClick(() => {
            this.download()
          })

          if (!this.isGroupManage) {
            Column({ space: 5 }) {
              SymbolGlyph($r('sys.symbol.arrowshape_up_to_line'))
                .fontColor([$r('sys.color.icon_primary')])
                .fontSize(24)
              Row() {
                Text($r('app.string.pin'))
                  .fontSize(10)
              }
            }
            .justifyContent(FlexAlign.Center)
            .size({ height: 56, width: 56 })
            .onClick(() => {
              this.pin()
            })
          }
        }

        Column({ space: 5 }) {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize(24)
          Row() {
            Text($r('app.string.delete'))
              .fontSize(10)
          }
        }
        .justifyContent(FlexAlign.Center)
        .size({ height: 56, width: 56 })
        .onClick(() => {
          this.delete();
        })
      }
      .width(this.isGroupManage ? 248 : this.isShelf ? 304 : 136)
      .borderRadius(28)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .justifyContent(FlexAlign.Center)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.Center)
  }
}