import { EasyEditor } from '../components/EasyEditor';
import { COL_OFFSET, COL_SPAN, Constants, GRID_ROW_OPTIONS } from '../constants/Constants';
import { EasyEditorController } from '../utils/Controller';

@ComponentV2
export struct ArticlePost {
  @Param fontSizeRatio: number = 1
  @Param darkMode: boolean = false
  @Param customPadding: Padding = {};
  @Event onTitleChange: (value: string) => void = () => {
  }
  @Event onContentChange: (value: string) => void = () => {
  }
  private editorController: EasyEditorController = new EasyEditorController()
  @Local content: string = ''
  @Local hideRichOperation: boolean = false
  @Local title: string = ''
  @Local isValidate: boolean = false

  @Builder
  contentArea() {
    List({ space: 12 }) {
      ListItem() {
        TextArea({
          placeholder: '请输入标题（2-30个字）',
        })
          .defaultFocus(true)
          .placeholderFont({ size: 18 * this.fontSizeRatio, weight: FontWeight.Bold })
          .fontSize(16 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .onFocus(() => {
            this.hideRichOperation = true
          })
          .onBlur(() => {
            this.hideRichOperation = false
            this.isValidate = true
          })
          .onChange((value: string) => {
            this.title = value;
            if (this.title.trim().length >= 2) {
              this.isValidate = false
            }
            this.onTitleChange(this.title)
          })
          .placeholderColor($r('sys.color.font_tertiary'))
          .backgroundColor(Color.Transparent)
          .maxLength(Constants.MAX_BODY_WORD_LIMIT)
          .padding(0)
          .borderRadius(0)
      }

      ListItem() {
        Text('标题不得少于2个字')
          .fontSize(12 * this.fontSizeRatio)
          .fontColor($r('sys.color.warning'))
      }
      .visibility(this.isValidate && this.title.trim().length < 2 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('auto')
    .padding({
      left: this.customPadding.left,
      right: this.customPadding.right,
    })
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.comp_divider'),
    })
  }

  build() {
    Column() {
      GridRow(GRID_ROW_OPTIONS) {
        GridCol({
          span: COL_SPAN,
          offset: COL_OFFSET,
        }) {
          Scroll() {
            Column({ space: 16 }) {
              this.contentArea()
              EasyEditor({
                controller: this.editorController,
                darkMode: this.darkMode,
                hideRichOperation: this.hideRichOperation,
                config: {
                  before_init: {
                    type: 'defined',
                    definedBody: `(config)=>{}`,
                  },
                  init_instance_callback: {
                    type: 'defined',
                    definedBody: `
                        (editor) => {}`,
                  },
                },
                content: '',
                onContentChange: txt => {
                  this.content = txt
                  this.onContentChange(this.content)
                },
              }).layoutWeight(1)
            }
            .width(Constants.FULL_PERCENT)
            .height(Constants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Start)
          }
          .width(Constants.FULL_PERCENT)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .margin({ top: 16 })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
      }
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
  }
}
