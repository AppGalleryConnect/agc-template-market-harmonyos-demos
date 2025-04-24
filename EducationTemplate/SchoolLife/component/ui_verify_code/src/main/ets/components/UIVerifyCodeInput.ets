import { ComponentConst } from '../constance/ComponentConst';
import { NumberUtil } from 'commonlib';
import { componentUtils } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

export enum VerifyCodeType {
  NUMBER_AND_CHAR, // 数字+字母
  NUMBER, // 纯数字
}

export enum VerifyEventType {
  CODE_ERROR = 'UIVerifyCodeInput_CODE_ERROR', // 验证码错误
}

@ComponentV2
export struct UIVerifyCodeInput {
  @Param @Require codeCount: number; // 签到码长度
  @Param @Require codeType: VerifyCodeType; // 签到码类别
  @Param @Require onFinishInput: (code: string) => void; // 输入完成回调
  @Param inputSpace: number = 12; // 签到码之间间隔，默认12vp
  @Param inputHeight: Length = 40; // 输入框高度，默认40vp
  @Param bottomLineColor: ResourceColor = '#ED6F21'; // 底部亮标颜色，默认#ED6F21
  @Param cursorColor?: ResourceColor = undefined; // 竖直亮标颜色，无则不显示
  @Param inputBgColor: ResourceColor = '#F1F3F5'; // 签到码背景色，默认#F1F3F5
  @Param bgRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 8; // 签到码背景圆角大小，默认四角8vp
  @Param onCodeChange?: (code: string) => void = undefined; // 输入变化回调
  @Param verifyEnable: boolean = true; // 是否允许继续输入

  @Local verticalGuidelines: GuideLineStyle[] = []; // 验证码guideline，用于定位底部亮标、光标和输入
  @Local codeBgWidth: number = 0; // 验证码背景宽度
  @Local bottomLineHeight: number = 2; // 底部亮标粗细
  @Local bottomLineMargin: number = 8; // 底部亮标margin
  @Local curFocusIndex: number = 0; // 当前焦点下标，-1代表输入完成，底部亮标、光标均不显示
  @Local codeBgBorderColor: ResourceColor = Color.Transparent; // 验证码背景框

  @Local textInputContents: string[] = [];
  @Local textInputControllers: TextInputController[] = [];
  @Local flashFlag: boolean = false;
  @Local springTranslationX: number = 0;

  private readonly _CODE_BG_SUFFIX = 'code_bg_';
  private readonly _GUIDELINE_SUFFIX = 'guideline_';
  private readonly _TEXT_INPUT_SUFFIX = 'text_input_';

  private _context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    NumberUtil.range(this.codeCount).forEach(() => {
      this.textInputContents.push('');
      this.textInputControllers.push(new TextInputController());
    });

    // 设置底部亮标闪烁
    setInterval(() => {
      animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
        this.flashFlag = !this.flashFlag;
      });
    }, 500);

    // 事件监听注册
    this._context.eventHub.on(VerifyEventType.CODE_ERROR, this.verifyCodeError.bind(this));
  }

  aboutToDisappear(): void {
    this._context.eventHub.off(VerifyEventType.CODE_ERROR);
  }

  build() {
    RelativeContainer() {
      // 验证码背景
      Row({ space: this.inputSpace }) {
        ForEach(NumberUtil.range(this.codeCount), (index: number) => {
          Column()
            .height(ComponentConst.FULL_PARENT)
            .borderRadius(this.bgRadius)
            .borderWidth(1)
            .borderColor(this.codeBgBorderColor)
            .backgroundColor(this.inputBgColor)
            .layoutWeight(1)
            .onAppear(() => {
              if (index === this.codeCount - 1) {
                this.computeGuidelineAndSize();
              }
            })
            .id(`${this._CODE_BG_SUFFIX}${index}`)
        }, (item: number) => `${item}`)
      }

      if (this.verticalGuidelines.length !== 0) {
        // 编辑组件
        this.textInputArrayBuilder();
        // 底部亮标
        this.bottomLineBuilder();
      }
    }
    .enabled(this.verifyEnable)
    .focusOnTouch(true)
    .translate({ x: this.springTranslationX })
    .width(ComponentConst.FULL_PARENT)
    .height(this.inputHeight)
    .guideLine(this.verticalGuidelines)
  }

  @Builder textInputArrayBuilder() {
    ForEach(NumberUtil.range(this.codeCount), (index: number) => {
      TextInput({
        text: this.textInputContents[index],
        controller: this.textInputControllers[index],
      })
        .enabled(this.verifyEnable)
        .fontSize(14)
        .maxLines(1)
        .maxLength(1)
        .fontWeight(FontWeight.Bold)
        .caretColor(Color.Transparent)
        .width(this.codeBgWidth)
        .textAlign(TextAlign.Center)
        .selectionMenuHidden(true)
        .backgroundColor(Color.Transparent)
        .focusOnTouch(false)
        .type(this.codeType === VerifyCodeType.NUMBER ? InputType.NUMBER_DECIMAL : InputType.Normal)
        .alignRules({
          middle: ComponentConst.bindHorizontalCenter(this.verticalGuidelines[index].id),
          center: ComponentConst.bindVerticalCenter(),
        })
        .onTextSelectionChange((selectionStart: number) => {
          // 输入框不为空时，光标一直保持在末尾
          if (this.textInputContents[index] !== '' && selectionStart === 0) {
            this.textInputControllers[index].caretPosition(1);
          }
        })
        .onWillInsert((insertValue: InsertValue) => {
          if (!this.checkInsertValidation(insertValue)) {
            return false;
          }

          this.focusOnIndex(index + 1);
          return true;
        })
        .onWillDelete((deleteValue: DeleteValue) => {
          if (deleteValue.deleteValue === '') {
            this.focusOnIndex(index - 1);
            this.textInputContents[Math.max(index - 1, 0)] = '';
          } else {
            this.focusOnIndex(index);
          }
          return true;
        })
        .onChange((value: string) => {
          this.textInputContents[index] = value;
          // 输入最后一位后触发onFinishInput
          if (index === this.codeCount - 1 && value !== '') {
            this.codeBgBorderColor = Color.Transparent;
            this.onFinishInput(this.textInputContents.join(''));
          } else {
            this.onCodeChange?.(this.textInputContents.join(''));
          }
        })
        .padding(0)
        .id(`${this._TEXT_INPUT_SUFFIX}${index}`)
    }, (item: number) => `${item}`)
  }

  @Builder bottomLineBuilder() {
    if (this.curFocusIndex !== -1 && this.verifyEnable) {
      Column()
        .backgroundColor(this.bottomLineColor)
        .height(this.bottomLineHeight)
        .borderRadius(this.bottomLineHeight / 2)
        .width(this.codeBgWidth - 2 * this.bottomLineMargin)
        .alignRules({
          bottom: ComponentConst.bindBottom(),
          middle: ComponentConst.bindHorizontalCenter(this.verticalGuidelines[this.curFocusIndex].id),
        })
        .margin({ bottom: 4 })
        .opacity(this.flashFlag ? 1 : 0)
    }
  }

  // 初始化验证码宽高及定位
  computeGuidelineAndSize() {
    const codeBgInfo = componentUtils.getRectangleById(`${this._CODE_BG_SUFFIX}0`);
    this.codeBgWidth = px2vp(codeBgInfo.size.width);
    NumberUtil.range(this.codeCount).forEach((index: number) => {
      this.verticalGuidelines.push({
        id: `${this._GUIDELINE_SUFFIX}${index}`,
        direction: Axis.Vertical,
        position: { start: this.codeBgWidth / 2 + index * (this.codeBgWidth + this.inputSpace) },
      });
    });
  }

  // 校验输入字符合法性
  checkInsertValidation(insertValue: InsertValue): boolean {
    if (this.codeType === VerifyCodeType.NUMBER) {
      return !isNaN(Number(insertValue.insertValue));
    }
    return true;
  }

  // 验证码状态错误
  verifyCodeError() {
    this.focusOnIndex(0);
    for (let i = 0; i < this.codeCount; i++) {
      this.textInputContents[i] = '';
    }
    // 背景红框
    this.codeBgBorderColor = $r('app.color.warning_red');
    setTimeout(() => {
      // 晃动动画
      this.springTranslationX = -2;
      ComponentConst.startSpringAnimation(() => {
        this.springTranslationX = 2;
      });
      this.springTranslationX = 0;
    }, 0);
  }

  // 控制焦点到指定输入框
  focusOnIndex(textInputIndex: number) {
    if (textInputIndex === -1) {
      return;
    } else if (textInputIndex === this.codeCount) {
      this.curFocusIndex = -1;
      this.getUIContext().getFocusController().clearFocus();
      return;
    }
    focusControl.requestFocus(`${this._TEXT_INPUT_SUFFIX}${textInputIndex}`);
    this.curFocusIndex = textInputIndex;
  }
}