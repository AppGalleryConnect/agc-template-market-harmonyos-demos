import { componentUtils, ComponentUtils, MeasureOptions } from '@kit.ArkUI'
import { TopicResponse } from 'lib_news_api';
import { Logger, RouterMap, RouterUtils, TextSpanInfo } from 'lib_common';
import { ComInfoType } from 'module_imagepreview'
import { Highlight } from 'module_highlight'

const TAG = '[ArticleTextEllipsis]';

@ComponentV2
export struct ArticleTextEllipsis {
  @Param isAll: boolean = true
  @Param text: string = ''
  @Param omitContent: string = '…'
  @Param fontSizeRatio: number = 1
  @Param searchKey: string = ''
  @Local textSpanList: TextSpanInfo[] = [];
  @Local showTextSpanList: TextSpanInfo[] = [];
  @Local rows: number = 3
  @Local isExpand: boolean = false
  @Local textWidth: number = 0
  @Local textHeight: number = 0
  @Local maxLineHeight: number = 0
  private uiContext = this.getUIContext()
  private timeId: number = 0;

  @Monitor('rows', 'text')
  onStrChange() {
    this.handleTextClip();
  }

  @Monitor('showTextSpanList.length')
  onShowTextSpanListChange() {
    Logger.debug(TAG, 'Monitor showTextSpanList: ' + JSON.stringify(this.showTextSpanList));
  }

  aboutToAppear(): void {
    this.handleTextClip();
  }

  aboutToDisappear(): void {
    clearTimeout(this.timeId);
  }

  /**
   * 测量文字尺寸
   */
  measureTextSize = (context: UIContext, option: MeasureOptions): Size => {
    let measureUtils = context.getMeasureUtils()
    return {
      width: context.px2vp(measureUtils.measureTextSize(option).width as number),
      height: context.px2vp(measureUtils.measureTextSize(option).height as number),
    }
  }
  /**
   * 获取组件信息
   * @param {context} UIContext
   * @param {key} 组件id
   * */
  getComponentsInfo = (context: UIContext, key: string): ComInfoType => {
    let comUtils: ComponentUtils = context.getComponentUtils()
    let info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
    return {
      width: context.px2vp(info.size.width),
      height: context.px2vp(info.size.height),
      localLeft: context.px2vp(info.localOffset.x),
      localTop: context.px2vp(info.localOffset.y),
      screenLeft: context.px2vp(info.screenOffset.x),
      screenTop: context.px2vp(info.screenOffset.y),
      windowLeft: context.px2vp(info.windowOffset.x),
      windowTop: context.px2vp(info.windowOffset.y),
    }
  }

  getTextSpanList() {
    try {
      this.textSpanList = JSON.parse(this.text);
    } catch (e) {
      this.textSpanList = [{ text: this.text, type: 'default' }];
    }
  }

  handleTextClip() {
    this.getTextSpanList();
    this.textWidth = this.getComponentsInfo(this.uiContext, 'essay').width;
    if (this.textWidth > 0) {
      this.formatText();
      return;
    }
    this.timeId = setTimeout(() => {
      this.handleTextClip();
    }, 100);
  }

  formatText() {
    const text = this.textSpanList.map(v => v.text).join('');
    this.textHeight = this.measureText(text);
    this.maxLineHeight = this.measureText(text, this.rows);
    Logger.debug(TAG,
      'this.textWidth: ' + this.textWidth + ', this.textHeight: ' + this.textHeight + ', this.maxLineHeight' +
        this.maxLineHeight + ', text' + text);
    if (this.textHeight > this.maxLineHeight && this.isAll) {
      this.getTextByWidth();
    } else {
      this.showTextSpanList = this.textSpanList;
    }
  }

  getTextByWidth() {
    this.showTextSpanList = JSON.parse(JSON.stringify(this.textSpanList))
    let clipText = this.showTextSpanList.map(v => v.text).join('');
    let textHeight = this.textHeight
    while (textHeight > this.maxLineHeight) {
      let end = this.showTextSpanList[this.showTextSpanList.length - 1];
      if (end.type === 'default') {
        end.text = end.text.substring(0, end.text.length - (this.rows * 2))
      } else {
        end.text = '';
      }
      if (!end.text) {
        this.showTextSpanList.pop();
      }
      clipText = this.showTextSpanList.map(v => v.text).join('');
      textHeight = this.measureText(clipText + (this.textHeight > this.maxLineHeight ? this.omitContent : ''))
    }
  }

  measureText(text: string, rows?: number): number {
    return this.measureTextSize(this.uiContext, {
      textContent: text,
      constraintWidth: this.textWidth,
      fontSize: 16,
      maxLines: rows,
    }).height
  }

  @Computed
  get textString() {
    return this.textSpanList.map(v => v.text).join('');
  }

  @Computed
  get showTextString() {
    return this.showTextSpanList.map(v => v.text).join('');
  }

  build() {
    Row() {
      if (this.searchKey) {
        Highlight({
          keywords: [this.searchKey as string],
          sourceString: this.isExpand ? this.textString : this.showTextString,
          highLightColor: '#E84026',
          textColor: $r('sys.color.font_primary'),
        })
      } else {
        Text() {
          ForEach(this.isExpand ? this.textSpanList : this.showTextSpanList, (v: TextSpanInfo) => {
            if (v.type === 'topic') {
              Span(v.text)
                .fontColor($r('app.color.app_theme'))
                .fontWeight(FontWeight.Medium)
                .fontSize(16 * this.fontSizeRatio)
                .onClick(() => {
                  const params: Record<string, Object | TopicResponse> = {
                    'topic': { id: '', title: v.text } as TopicResponse,
                  }
                  RouterUtils.pushPathByName(RouterMap.TOPIC_RESULT_PAGE, params);
                })
            } else {
              Span(v.text)
                .fontColor(v.type === 'default' ? $r('sys.color.font_primary') : $r('app.color.app_theme'))
                .fontWeight(FontWeight.Medium)
                .fontSize(16 * this.fontSizeRatio)
            }
          }, (v: TextSpanInfo) => v.text + v.type)
          if (this.textHeight > this.maxLineHeight && !this.isExpand && this.isAll) {
            Span(this.omitContent)
              .fontSize(16 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span('全文')
              .fontColor($r('app.color.app_theme'))
              .fontSize(16 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
          }
        }
      }
    }
    .id('essay')
    .width('100%')
  }
}