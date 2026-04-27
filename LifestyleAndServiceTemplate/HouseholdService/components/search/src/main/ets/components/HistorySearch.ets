import { LengthMetrics, MeasureUtils } from '@kit.ArkUI';
import { Constants } from '../common/Constant';
import { SearchWordItem } from '../types/Type';
import { GridRowColSetting } from '../common/GridRowColSetting';

const TAG: string = '[HistorySearch]';

@ComponentV2
export struct HistorySearch {
  @Param historyList: SearchWordItem[] = [];
  @Param breakpoint: string = 'sm';
  @Param columnWidth: number = 0;
  @Param maxLen: number = 0;
  @Event selectHistoryItem: (item: SearchWordItem, index?: number) => void = () => {
  }
  @Event deleteHistoryList: () => void = () => {
  };
  @Local containerWidth: number = 0;
  // 胶囊词折叠状态。
  @Local showAll: boolean = false;
  // 胶囊词是否溢出，需要折叠展开
  @Local isOverflow: boolean = false;
  // 折叠时能展示的最后一个历史词的下标
  @Local foldedLastIndex: number = 0;
  @Local uiContextMeasure: MeasureUtils = this.getUIContext().getMeasureUtils();

  @Monitor('historyList.0')
  onListChange() {
    this.setFoldState(this.historyList, this.uiContextMeasure, this.columnWidth, this.maxLen);
  }

  @Monitor('columnWidth')
  onColumnWidthChange() {
    this.setFoldState(this.historyList, this.uiContextMeasure, this.columnWidth, this.maxLen);
  }

  build() {
    if (this.historyList.length) {
      Column() {
        Row() {
          Text('搜索历史')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontFamily('HarmonyHeiTi')

          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(Constants.CHEVRON_WIDTH)
            .fontColor([$r('sys.color.icon_primary')])
            .onClick(() => {
              this.deleteHistoryList();
            })
        }
        .width(Constants.FULL_PERCENT)
        .height(Constants.HISTORY_HEIGHT)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          top: Constants.PADDING_XL,
          bottom: Constants.PADDING_S,
        })
        .margin({ bottom: Constants.SPACE_S })

        Row() {
          Flex({
            wrap: FlexWrap.Wrap,
            space: {
              main: LengthMetrics.vp(GridRowColSetting.getGuessLikeSpace(this.breakpoint)),
              cross: LengthMetrics.vp(GridRowColSetting.getGuessLikeSpace(this.breakpoint))
            }
          }) {
            ForEach(this.historyList, (item: SearchWordItem, index: number) => {
              // 三种情况下会展示这个词
              if (!this.isOverflow || (index !== undefined && index <= this.foldedLastIndex) ||
                (this.showAll === true)) {
                this.buttonBuilder(item, index);
              }
            }, (item: SearchWordItem) => JSON.stringify(item.content));

            Blank()
              .height(Constants.FOLD_BUTTON_DIAMETER)
              .visibility(this.isOverflow ? Visibility.Visible : Visibility.None)

            this.showAllIconBuilder()
          }
        }
        .onSizeChange((oldSize, newSize) => {
          this.containerWidth = newSize.width as number
        })
        .padding({
          top: Constants.PADDING_M,
          bottom: Constants.PADDING_M
        })
        .onAppear(() => {
          this.setFoldState(this.historyList, this.uiContextMeasure, this.columnWidth, this.maxLen);
        })
      }
      .width(Constants.FULL_PERCENT)
    }
  }

  @Builder
  buttonBuilder(item: SearchWordItem, index?: number) {
    Button(item.content, { type: ButtonType.Capsule, controlSize: ControlSize.SMALL })
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .fontFamily('HarmonyHeiTi')
      .fontColor($r('sys.color.font_primary'))
      .focusable(true)
      .id('flowRowText')
      .padding({
        top: Constants.PADDING_XXS,
        bottom: Constants.PADDING_XXS,
        left: Constants.PADDING_M,
        right: Constants.PADDING_M
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .constraintSize({ minWidth: this.columnWidth, maxWidth: this.maxLen })
      .onClick(() => {
        this.selectHistoryItem(item, index)
      })
  }

  @Builder
  showAllIconBuilder() {
    Button({ type: ButtonType.Circle }) {
      if (this.showAll) {
        SymbolGlyph($r('sys.symbol.chevron_up'))
          .fontSize(Constants.SHOW_ALL_SIZE)
          .fontColor([$r('sys.color.icon_secondary')])
      } else {
        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(Constants.SHOW_ALL_SIZE)
          .fontColor([$r('sys.color.icon_secondary')])
      }
    }
    .width(Constants.FOLD_BUTTON_DIAMETER)
    .height(Constants.FOLD_BUTTON_DIAMETER)
    .visibility(this.isOverflow ? Visibility.Visible : Visibility.None)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ right: -GridRowColSetting.getGuessLikeSpace(this.breakpoint) })
    .onClick(() => {
      this.showAll = !this.showAll
    })
  }

  /**
   * 计算搜索历史词的宽度
   */
  calculateWordWidth(word: string, measure: MeasureUtils, minLength: number, maxLength: number): number {
    let wordWidth = 0
    let textSize: SizeOptions = measure.measureTextSize({
      textContent: word,
      fontSize: 14
    })
    if (textSize) {
      wordWidth += Math.max(minLength,
        Math.min(this.getUIContext().px2vp(textSize.width as number) + 2 * 12, maxLength));
    }
    return wordWidth
  }

  /**
   * 设置折叠状态
   */
  setFoldState(historyList: SearchWordItem[], measure: MeasureUtils, minLength: number, maxLength: number) {
    // 历史词总宽度
    let wordsWidth = 0
    for (let i = 0; i < historyList.length; i++) {
      wordsWidth += this.calculateWordWidth(historyList[i].content, measure, minLength, maxLength)

      // 如果当前遍历的历史词宽度已经大于容器宽度，判定为overflow，直接返回，不需要遍历全部历史词。
      if (wordsWidth > this.containerWidth) {
        console.log(TAG + ' Overflow happens at word ' + i);
        this.isOverflow = true;
        // 找到当历史词折叠时，第一行显示到第几个单词
        this.findLastShownWord(historyList, measure, minLength, maxLength);
        return
      }

      // 各词条间距
      if (i !== historyList.length - 1) {
        wordsWidth += GridRowColSetting.getGuessLikeSpace(this.breakpoint);
      }
    }
    this.isOverflow = false;
  }

  /**
   * 找到折叠时显示的最后一个历史词
   */
  findLastShownWord(historyList: SearchWordItem[], measure: MeasureUtils, minLength: number, maxLength: number) {
    let wordsWidth = 0;
    for (let i = 0; i < historyList.length; i++) {
      wordsWidth += this.calculateWordWidth(historyList[i].content, measure, minLength, maxLength)

      // 如果历史词超长折叠，则能显示历史词的区域=containerWidth-[折叠按钮直径再减去]-[spacing]。
      if (wordsWidth >
        this.containerWidth - Constants.FOLD_BUTTON_DIAMETER - GridRowColSetting.getGuessLikeSpace(this.breakpoint)) {
        this.foldedLastIndex = i - 1;
        console.log(TAG + ' When folded, the words are truncated at ' + i);
        return;
      }
      if (i !== historyList.length - 1) {
        wordsWidth += GridRowColSetting.getGuessLikeSpace(this.breakpoint)
      }
    }
  }
}