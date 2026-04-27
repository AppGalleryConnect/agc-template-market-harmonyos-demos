/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { RouterModule } from '@agctemplate/router_module';
import { promptAction, window } from '@kit.ArkUI';
import { User, RichEditorSpan } from 'live_interaction';
import { NavigationDialog } from './NavigationDialog';

@ObservedV2
export class TextInput {
  private static _instance: TextInput;

  public static get instance() {
    if (!TextInput._instance) {
      TextInput._instance = new TextInput();
    }
    return TextInput._instance;
  }

  @Trace spansRemain: Array<RichEditorTextSpanResult | RichEditorImageSpanResult> = []
}

interface OperateButton {
  icon: Resource
  onClick?: (event: ClickEvent) => void
}

@ComponentV2
export struct CommentKeyboard {
  private richEditorController = new RichEditorController();
  private frequentEmojiListHeight = 60;
  private builderSpans: RichEditorSpan[] = [];
  @Local keyboardHeight: number = 0;
  @Local isEmojiKeyboardVisible: boolean = false;
  private context = this.getUIContext().getHostContext();

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.context).then(win => {
        this.addKeyboardHeightListener(win);
      });
    } catch (e) {
    }

  }

  aboutToDisappear(): void {
    try {
      window.getLastWindow(this.context).then(win => {
        this.removeKeyboardHeightListener(win);
      });
    } catch (e) {
    }
  }

  getResourceString(resource: Resource, context: Context): string {
    return context.resourceManager.getStringSync(resource.id);
  }

  addKeyboardHeightListener(win: window.Window) {
    win.on('keyboardHeightChange', height => {
      console.info('keyboard height has changed', this.getUIContext().px2vp(height));
      if (height !== 0 && !this.isEmojiKeyboardVisible) {
        this.keyboardHeight = this.getUIContext().px2vp(height);
        return;
      } else if (this.isEmojiKeyboardVisible) {
        this.keyboardHeight = 300
        console.info('click soft keyboard close button');
        // RouterModule.pop();
      } else {
        this.keyboardHeight = 0
      }
    });
  }

  removeKeyboardHeightListener(win: window.Window) {
    win.off('keyboardHeightChange');
  }

  getOperateButtons(): OperateButton[] {
    return [
      {
        icon: this.isEmojiKeyboardVisible ? $r('sys.symbol.keyboard_circle') : $r('sys.symbol.face'),
        onClick: this.onEmojiButtonClick
      },
      { icon: $r('sys.symbol.paperplane'), onClick: this.onSendComment }
    ];
  }

  onReady: () => void = () => {
    if (TextInput.instance.spansRemain.length > 0) {
      TextInput.instance.spansRemain.forEach((span) => {
        const textSpan = span as RichEditorTextSpanResult;
        const imageSpan = span as RichEditorImageSpanResult;
        if (textSpan.value) {
          this.richEditorController.addTextSpan(textSpan.value) ;
        } else {
          this.richEditorController.addImageSpan(imageSpan.valueResourceStr, { imageStyle: { size: [20, 20] } })
        }
      })
    }
  }

  onEmojiButtonClick: (event: ClickEvent) => void = event => {
    this.isEmojiKeyboardVisible = !this.isEmojiKeyboardVisible;
  }
  onRichEditorClick: (event: ClickEvent) => void = event => {
    this.isEmojiKeyboardVisible = false;
  }
  onEmojiClick: (icon: Resource) => void = icon => {
    this.richEditorController.addImageSpan(icon, {
      offset: this.richEditorController.getCaretOffset(),
      imageStyle: { size: [20, 20] }
    });
  }
  onSendComment: () => void = () => {
    let builderSpanIndex = 0;
    let richEditorSpan: RichEditorSpan;
    const richEditorSpans: RichEditorSpan[] = [];
    this.richEditorController.getSpans().forEach((span, index) => {
      const textSpan = span as RichEditorTextSpanResult;
      const imageSpan = span as RichEditorImageSpanResult;
      if (textSpan.value) {
        richEditorSpan = { value: textSpan.value, type: 'text' };
      } else if (this.isBuilderSpan(span)) {
        richEditorSpan = this.builderSpans[builderSpanIndex];
        builderSpanIndex += 1;
      } else {
        richEditorSpan = { resourceValue: imageSpan.valueResourceStr, type: 'image' };
      }
      richEditorSpans.push(richEditorSpan);
    });
    console.info('richEditorContent', JSON.stringify(richEditorSpans));
    TextInput.instance.spansRemain = []
    RouterModule.pop(richEditorSpans);
  }

  setBuilderSpans(controller: RichEditorController, friend: User) {
    const builderSpan: RichEditorSpan = {
      value: `@${friend.nickname}`,
      data: friend,
      type: 'builder'
    };
    const range: RichEditorRange = { end: controller.getCaretOffset() };
    const index = this.getBuilderSpanCount(controller, range) - 1;
    this.builderSpans.splice(index, 0, builderSpan);
  }

  getBuilderSpanCount(controller: RichEditorController, range: RichEditorRange) {
    return controller.getSpans(range).reduce((count: number, span) => {
      return this.isBuilderSpan(span) ? count + 1 : count;
    }, 0);
  }

  aboutToDelete: (value: RichEditorDeleteValue) => boolean = value => {
    const controller = this.richEditorController;
    const span = value.richEditorDeleteSpans[0];
    if (span && this.isBuilderSpan(span)) {
      if (this.hasSelection(controller)) {
        this.deleteBuilderSpan();
        return true;
      }
      controller.setSelection(value.offset, value.offset + 1);
      return false;
    }
    return true;
  }

  deleteBuilderSpan() {
    const controller = this.richEditorController;
    const range: RichEditorRange = { end: controller.getCaretOffset() };
    const index = this.getBuilderSpanCount(controller, range) - 1;
    this.builderSpans.splice(index, 1);
  }

  isBuilderSpan(span: RichEditorImageSpanResult | RichEditorTextSpanResult): boolean {
    return !(span as RichEditorTextSpanResult).value &&
      !(span as RichEditorImageSpanResult).valueResourceStr?.toString().replaceAll(' ', '');
  }

  hasSelection(controller: RichEditorController) {
    const selection = controller.getSelection().selection;
    return selection[0] !== selection[1];
  }

  onIMEInputComplete: (result: RichEditorTextSpanResult) => void = result => {
  }
  aboutToIMEInput: (value: RichEditorInsertValue) => boolean = value => {
    return true
  }
  onDeleteComplete: () => void = () => {
    const controller = this.richEditorController;
    const offset = controller.getCaretOffset();
    const span = controller.getSpans({ start: offset - 1, end: offset });
  }
  onDidChange: (beRange: TextRange, afRange: TextRange) => void = (b, a) => {
    TextInput.instance.spansRemain = []
    TextInput.instance.spansRemain.push(...this.richEditorController.getSpans())
  }

  getEmojiIcons(): Resource[] {
    const getRandomNum = () => Math.floor(Math.random() * 2) + 1;
    return Array(40).fill(1).map(() => $r(`app.media.emoji_${getRandomNum()}`));
  }

  getFrequentEmojiIcons(): Resource[] {
    const getRandomNum = () => Math.floor(Math.random() * 2) + 3;
    return Array(10).fill(1).map(() => $r(`app.media.emoji_${getRandomNum()}`));
  }

  @Builder
  ToolBar() {
    Row() {
      Row() {
        RichEditor({ controller: this.richEditorController })
          .caretColor('#EE5D1A')
          .selectedBackgroundColor('#EE5D1A')
          .width('70%')
          .onReady(this.onReady)
          .customKeyboard(this.isEmojiKeyboardVisible ? this.EmojiKeyboard() : undefined)
          .constraintSize({ maxHeight: 60 })
          .placeholder('写评论',{fontColor:$r('sys.color.font_secondary')})
          .defaultFocus(true)
          .onClick(this.onRichEditorClick)
          .aboutToDelete(this.aboutToDelete)
          .onDeleteComplete(this.onDeleteComplete)
          .onIMEInputComplete(this.onIMEInputComplete)
          .aboutToIMEInput(this.aboutToIMEInput)
          .onWillChange((change) => {
            let index: number = change.rangeBefore.end ?? 0;
            change.replacedSpans.forEach((span) => {
              index++
            })
            change.replacedImageSpans.forEach(() => {
              index++;
            })
            if (index > 20) {
              this.getUIContext().getPromptAction().showToast({ message: '只能输入20个字符，请重新编辑' })
              return false
            } else {
              return true;
            }
          })
          .onDidChange(this.onDidChange)
      }
      Row({ space: 15 }) {
        ForEach(this.getOperateButtons(), (operateButton: OperateButton) => {
          SymbolGlyph(operateButton.icon)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .onClick(operateButton.onClick)
        }, (operateButton: OperateButton) => JSON.stringify(operateButton))
      }
      .justifyContent(FlexAlign.End)
    }
    .width('90%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin(10)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(20)
  }

  @Builder
  EmojiKeyboard() {
    Grid() {
      ForEach(this.getEmojiIcons(), (icon: Resource) => {
        GridItem() {
          Image(icon)
            .width(45)
            .onClick(() => {
              this.onEmojiClick(icon)
            })
        }
      },(item: Resource, index: number) => { return index + '__' + JSON.stringify(item); })
    }
    .width('100%')
    .height(this.keyboardHeight + this.frequentEmojiListHeight)
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(15)
    .padding(10)
    .scrollBar(BarState.Off)
  }

  @Builder
  FrequentEmojiList() {
    List({ space: 12 }) {
      ForEach(this.getFrequentEmojiIcons(), (icon: Resource) => {
        ListItem() {
          Image(icon)
            .width(40)
            .onClick(() => {
              this.onEmojiClick(icon)
            })
        }
      },(item: Resource, index: number) => { return index + '__' + JSON.stringify(item); })
    }
    .width('100%')
    .height(this.frequentEmojiListHeight)
    .padding({ left: 15, bottom: 15 })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .alignListItem(ListItemAlign.Center)
    .align(Alignment.Start)
  }

  build() {
    NavigationDialog({ maskBackgroundColor: 'rgba(0, 0, 0, 0.1)' }) {
      Column() {
        this.ToolBar()
        Divider()
        if (!this.isEmojiKeyboardVisible) {
          this.FrequentEmojiList()
        }
        Column()
          .height(
            this.isEmojiKeyboardVisible ?
              this.keyboardHeight + this.frequentEmojiListHeight :
            this.keyboardHeight
          )
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
  }
}

@Builder
export function CommentKeyboardBuild() {
  CommentKeyboard()
}