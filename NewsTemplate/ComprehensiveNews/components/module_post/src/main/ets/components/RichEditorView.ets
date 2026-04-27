import { Constants } from '../constants/Constants';
import { RichEditorViewController } from '../controller/RichEditorViewController';
import { TextSpanInfo, Topic, User } from '../types/Types';

/**
 * 富文本编辑器组件
 * 支持话题和联系人的高亮显示与整体删除
 */
@ComponentV2
export struct RichEditorView {
  // RichEditor控制器
  @Param controller: RichEditorController = new RichEditorController();
  // 富文本视图控制器
  @Param viewController: RichEditorViewController = new RichEditorViewController();
  // 初始化是携带的话题
  @Param attachedTopic: Topic = { id: '', title: '' };
  // 字体大小比例
  @Param fontRatio: number = 1;
  // 主题色
  @Param themeColor: ResourceColor = '#5C79D9';
  // 打开选择联系人的半模态弹窗
  @Event showContactSheet: () => void = () => {
  };
  // 打开选择话题的半模态弹窗
  @Event showTopicSheet: () => void = () => {
  };
  // 文本变化回调
  @Event onChange: (text: string) => void = () => {
  };

  aboutToAppear(): void {
    this.viewController.insertTopic = (topic) => this.insertTopic(topic);
    this.viewController.insertContact = (user) => this.insertContact(user);
  }

  /**
   * 插入话题
   * @param topic 话题对象
   */
  insertTopic(topic: Topic): void {
    this.deleteExtraSymbol();
    const topicText = topic.title;
    this.controller.addTextSpan(topicText, {
      offset: this.getSafeInsertOffset(),
      style: {
        fontColor: this.themeColor,
        fontSize: 16 * this.fontRatio,
      },
    });
    // 插入后追加空格
    this.controller.addTextSpan(' ', {
      offset: this.controller.getCaretOffset(),
      style: {
        fontColor: $r('sys.color.font_primary'),
        fontSize: 16 * this.fontRatio,
      },
    });
  }

  /**
   * 插入联系人
   * @param user 用户对象
   */
  insertContact(user: User): void {
    this.deleteExtraSymbol();
    const contactText = `@${user.authorNickName}`;
    this.controller.addTextSpan(contactText, {
      offset: this.getSafeInsertOffset(),
      style: {
        fontColor: this.themeColor,
        fontSize: 16 * this.fontRatio,
      },
    });
    // 插入后追加空格
    this.controller.addTextSpan(' ', {
      offset: this.controller.getCaretOffset(),
      style: {
        fontColor: $r('sys.color.font_primary'),
        fontSize: 16 * this.fontRatio,
      },
    });
  }

  deleteExtraSymbol() {
    const spans = this.controller.getSelection().spans as RichEditorTextSpanResult[];
    const caretSpan = spans[0];
    if (!caretSpan) {
      return;
    }
    const lastChar = caretSpan.value[caretSpan.value.length - 1];
    const isLastCharSymbol = lastChar === '@' || lastChar === '#';
    if (isLastCharSymbol) {
      this.controller.deleteSpans({
        start: caretSpan.spanPosition.spanRange[1] - 1,
        end: caretSpan.spanPosition.spanRange[1],
      })
    }
  }

  /**
   * 获取安全的插入位置
   * 如果光标在高亮 span（联系人或话题）中间，则返回富文本末尾位置
   * @returns 安全的插入位置偏移量
   */
  getSafeInsertOffset(): number {
    const spans = this.controller.getSelection().spans as RichEditorTextSpanResult[];
    const relativeSpan = spans[0];
    if (!relativeSpan) {
      return this.controller.getCaretOffset();
    }

    const isIncludeSymbol = this.isHighLightSpan(relativeSpan);
    const isInsertMiddle =
      this.controller.getCaretOffset() > relativeSpan.spanPosition.spanRange[0] &&
      this.controller.getCaretOffset() < relativeSpan.spanPosition.spanRange[1];

    if (isIncludeSymbol && isInsertMiddle) {
      // 光标在高亮 span 中间，返回富文本末尾位置
      const allSpans = this.controller.getSpans() as RichEditorTextSpanResult[];
      if (allSpans.length > 0) {
        const lastSpan = allSpans[allSpans.length - 1];
        return lastSpan.spanPosition.spanRange[1];
      }
    }

    return this.controller.getCaretOffset();
  }

  isHighLightSpan(span: RichEditorTextSpanResult): boolean {
    return span.textStyle.fontColor !== '#E5000000' && span.textStyle.fontColor !== '#DBFFFFFF';
  }

  onReady() {
    if (this.attachedTopic.title) {
      this.insertTopic(this.attachedTopic);
    }
  }

  aboutToIMEInput(value: RichEditorInsertValue): boolean {
    if (value.insertValue === '@') {
      this.showContactSheet();
    } else if (value.insertValue === '#') {
      this.showTopicSheet();
    }

    const spans = this.controller.getSelection().spans as RichEditorTextSpanResult[];
    const relativeSpan = spans[0];
    if (relativeSpan) {
      const isIncludeSymbol = this.isHighLightSpan(relativeSpan);
      const isInsertMiddle =
        value.insertOffset > relativeSpan.spanPosition.spanRange[0] &&
          value.insertOffset < relativeSpan.spanPosition.spanRange[1]
      if (isIncludeSymbol && isInsertMiddle) {
        return false;
      }

      if (isIncludeSymbol && value.insertOffset === relativeSpan.spanPosition.spanRange[1]) {
        this.controller.addTextSpan(value.insertValue, {
          offset: this.controller.getCaretOffset(),
          style: {
            fontColor: $r('sys.color.font_primary'),
            fontSize: 16 * this.fontRatio,
          },
        });
        return false;
      }
    }
    return true
  }

  aboutToDelete(value: RichEditorDeleteValue) {
    const list = (value.richEditorDeleteSpans as RichEditorTextSpanResult[])
      .filter(v => this.isHighLightSpan(v));

    if (list.length) {
      list.forEach((v) => {
        this.controller.deleteSpans({
          start: v.spanPosition.spanRange[0],
          end: v.spanPosition.spanRange[1],
        })
      })
      return false;
    }

    return true
  }

  onDidChange() {
    const spans = this.controller.getSpans() as RichEditorTextSpanResult[]
    const list = spans.map(v => {
      const isHighlight = this.isHighLightSpan(v);
      return {
        text: v.value,
        type: isHighlight && v.value.includes('@') ? 'contact' :
          (isHighlight && v.value.includes('#') ? 'topic' : 'default'),
      } as TextSpanInfo
    })
    this.onChange(JSON.stringify(list));
  }

  build() {
    RichEditor({
      controller: this.controller,
    })
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .padding(0)
      .borderRadius(0)
      .placeholder('畅所欲言，发表你的想法')
      .onReady(() => this.onReady())
      .aboutToIMEInput((value: RichEditorInsertValue) => this.aboutToIMEInput(value))
      .aboutToDelete((value: RichEditorDeleteValue) => this.aboutToDelete(value))
      .onDidChange(() => this.onDidChange())
  }
}
