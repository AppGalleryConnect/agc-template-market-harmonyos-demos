import { DialogConfig } from './DialogConfig';
import { LogUtil } from '../LogUtil';
import { CustomContentDialog, promptAction, window } from '@kit.ArkUI';
import { ToastOptions } from './ToastOptions';
import { ObjectUtil } from '../../../../../Index';

export class DialogUtils {
  private static defaultConfig: DialogConfig = new DialogConfig(); //默认样式
  private static mainUIContext: UIContext | undefined; //MainWindow的UIContext

  /**
   * 选择器弹框
   */
  static textPickerDialog(paramArray: Resource, sexCallback: Function) {
    if (ObjectUtil.isNull(paramArray)) {
      LogUtil.error('DialogUtils', 'paramArray is null');
      return;
    }
    TextPickerDialog.show({
      range: paramArray,
      canLoop: false,
      selected: 0,
      onAccept: (result: TextPickerResult) => {
        sexCallback(result.value);
      },
      onCancel: () => {
        LogUtil.info('DialogUtils', 'TextPickerDialog onCancel');
      },
    });
  }

  static showDatePicker(options: DatePickerDialogOptions) {
    options.alignment = options.alignment ?? DialogUtils.defaultConfig.alignment;
    options.offset = options.offset ?? DialogUtils.defaultConfig.offset;
    options.maskRect = options.maskRect ?? DialogUtils.defaultConfig.maskRect;
    options.backgroundColor = options.backgroundColor ?? DialogUtils.defaultConfig.backgroundColor;
    options.backgroundBlurStyle = options.backgroundBlurStyle ?? DialogUtils.defaultConfig.backgroundBlurStyle;
    options.shadow = options.shadow ?? DialogUtils.defaultConfig.shadow;
    DatePickerDialog.show(options);
  }

  static showTimePicker(options: TimePickerDialogOptions) {
    options.alignment = options.alignment ?? DialogUtils.defaultConfig.alignment;
    options.offset = options.offset ?? DialogUtils.defaultConfig.offset;
    options.maskRect = options.maskRect ?? DialogUtils.defaultConfig.maskRect;
    options.backgroundColor = options.backgroundColor ?? DialogUtils.defaultConfig.backgroundColor;
    options.backgroundBlurStyle = options.backgroundBlurStyle ?? DialogUtils.defaultConfig.backgroundBlurStyle;
    options.shadow = options.shadow ?? DialogUtils.defaultConfig.shadow;
    TimePickerDialog.show(options);
  }

  /**
   * 获取MainWindow的UIContext
   * @returns
   */
  static getMainUIContext(): UIContext | undefined {
    if (DialogUtils.mainUIContext) {
      return DialogUtils.mainUIContext;
    }
    return DialogUtils.defaultConfig?.uiAbilityContext?.windowStage?.getMainWindowSync()?.getUIContext();
  }

  /**
   * 显示吐司
   * @param message 吐司内容
   * @param options
   */
  static showToast(message: string | Resource, options?: ToastOptions) {
    options = options ?? {};
    options.message = message;
    options.duration = options.duration ?? DialogUtils.defaultConfig.toastDuration;
    DialogUtils.initToastDefault(options);
    DialogUtils.showToastDetail(options);
  }


  /**
   * 创建并弹出dialogContent对应的自定义弹窗
   * @param contentView 自定义弹窗中显示的组件内容。
   * @param options 弹窗样式。
   */
  private static showToastDetail(options: ToastOptions) {
    const showToastOptions: promptAction.ShowToastOptions = {
      message: options.message ?? '',
      duration: options.duration, //默认值1500ms，取值区间：1500ms-10000ms。若小于1500ms则取默认值，若大于10000ms则取上限值10000ms。
      textColor: options.fontColor ?? Color.Black, // 文本提示框文本颜色。默认值：Color.Black
      bottom: options.bottom ?? '80vp', //设置弹窗底部边框距离导航条的高度。默认值：80vp。
      alignment: options.alignment, //对齐方式。默认值：undefined，默认底部偏上位置。
      offset: options.offset ??
        { dx: 0, dy: 0 }, //在对齐方式上的偏移。默认值：{ dx: 0, dy: 0 }，默认没有偏移。说明： 只支持设置px类型的数值，如需设置vp，可以将vp改成px传入。
      backgroundColor: options.backgroundColor, //文本提示框背板颜色，建议八位色值前两位为透明度。默认值：Color.Transparent。
      backgroundBlurStyle: options.backgroundBlurStyle ??
      BlurStyle.COMPONENT_ULTRA_THICK, //文本提示框背板模糊材质。默认值：BlurStyle.COMPONENT_ULTRA_THICK。
      shadow: options.shadow ?? ShadowStyle.OUTER_DEFAULT_MD, //文本提示框背板阴影。默认值：ShadowStyle.OUTER_DEFAULT_MD
      showMode: options.showMode, //设置弹窗是否显示在应用之上。默认值：ToastShowMode.DEFAULT，默认显示在应用内。
    };
    if (options.uiContext) {
      options.uiContext.getPromptAction().showToast(showToastOptions);
    } else {
      window.getLastWindow(getContext()).then((result: window.Window) => {
        result.getUIContext().getPromptAction().showToast(showToastOptions);
      });
    }
  }

  /**
   * 初始化ToastOptions参数
   * @param options
   */
  private static initToastDefault(options: ToastOptions) {
    options.uiContext = options.uiContext ?? DialogUtils.getMainUIContext();
    if (options.fontColor || DialogUtils.defaultConfig.toastFontColor) {
      options.fontColor = options.fontColor ?? DialogUtils.defaultConfig.toastFontColor; //文字颜色。
    }
    if (options.backgroundColor || DialogUtils.defaultConfig.toastBackgroundColor) {
      options.backgroundColor = options.backgroundColor ?? DialogUtils.defaultConfig.toastBackgroundColor;
    }
    options.backgroundBlurStyle = options.backgroundBlurStyle ?? BlurStyle.NONE;
    options.shadow = options.shadow ?? ShadowStyle.OUTER_DEFAULT_MD;
    options.showMode = options.showMode ?? promptAction.ToastShowMode.DEFAULT;
    options.bottom = options.bottom ?? '80vp';
    options.offset = options.offset ?? { dx: 0, dy: 0 };
    if (DialogUtils.defaultConfig.toastAlignment) {
      options.alignment = options.alignment ?? DialogUtils.defaultConfig.toastAlignment; //对齐方式。
    } else {
      options.alignment = options.alignment ?? DialogUtils.convertAlignment(DialogUtils.defaultConfig.alignment);
    }
  }

  /**
   * 将DialogAlignment值转化为Alignment值
   */
  private static convertAlignment(dialogAlignment: DialogAlignment): Alignment | undefined {
    switch (dialogAlignment) {
      case DialogAlignment.Top:
        return Alignment.Top;
      case DialogAlignment.Center:
        return Alignment.Center;
      case DialogAlignment.Bottom:
        return Alignment.Bottom;
      case DialogAlignment.TopStart:
        return Alignment.TopStart;
      case DialogAlignment.TopEnd:
        return Alignment.TopEnd;
      case DialogAlignment.CenterStart:
        return Alignment.Start;
      case DialogAlignment.CenterEnd:
        return Alignment.End;
      case DialogAlignment.BottomStart:
        return Alignment.BottomStart;
      case DialogAlignment.BottomEnd:
        return Alignment.BottomEnd;
      case DialogAlignment.Default:
        return undefined;
    }
    return undefined;
  }
}