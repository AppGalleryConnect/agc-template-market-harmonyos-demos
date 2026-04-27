import {
  ToolsItem,
  canvasToolsList,
} from '../constants/StyleConstants'
import { BackgroundColor } from '../tools/BackgroundColor'
import { PaintContent } from '../tools/PaintContent'
import { RubbersContent } from '../tools/RubbersContent'
import { ShapeContent } from '../tools/ShapeContent'
import { DrawBoardVM } from '../viewmodel/DrawVM'
import { baseActionSheet } from './ActionSheet'


@ComponentV2
export struct BottomMenuBar {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance
  @BuilderParam toolsContent: CustomBuilder;

  @Builder
  PaintContent() {
    Column() {
      PaintContent()
    }
  }

  @Builder
  RubbersContent() {
    Column() {
      RubbersContent()
    }
  }

  @Builder
  ShapeContentContent() {
    Column() {
      ShapeContent()
    }
  }

  @Builder
  BackgroundColor() {
    Column() {
      BackgroundColor()
    }
  }

  build() {
    Row() {
      ForEach(canvasToolsList, (item: ToolsItem, index: number) => {
        Column({ space: 5 }) {
          Image(this.drawBoardVM.tabCurrentIndex === index ? item.selected : item.unSelected)
            .height(24)
            .width(24)
          Text(item.name)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.drawBoardVM.tabCurrentIndex === index ? $r('app.color.theme_color') :
            $r('sys.color.font_primary'))
        }
        .onClick(() => {
          this.drawBoardVM.tabCurrentIndex = index
          this.drawBoardVM.index = -1;
          switch (item.id) {
            case 'pen':
              this.toolsContent = this.PaintContent
              break
            case 'rubbers':
              this.toolsContent = this.RubbersContent
              break
            case 'pattern':
              this.toolsContent = this.ShapeContentContent
              break
            case 'mipmap':
              this.toolsContent = this.ShapeContentContent
              break
            case 'background':
              this.toolsContent = this.BackgroundColor
              break
            default:
              this.toolsContent = this.PaintContent
              break
          }
          baseActionSheet.show({
            id: 'canvasTools',
            height: SheetSize.FIT_CONTENT,
            showClose: false,
            customContent: this.toolsContent,
            onWillAppear: ()=> {
              if (this.drawBoardVM.tabCurrentIndex === 3) {
                this.drawBoardVM.tabCurrentIndex = 0
              }
            }
          },this.getUIContext())
        })
      }, (item: ToolsItem) => item.id)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin({
      top: 16,
    })
  }
}
