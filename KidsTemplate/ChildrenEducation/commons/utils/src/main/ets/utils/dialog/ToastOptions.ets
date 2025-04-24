import { promptAction } from '@kit.ArkUI';

export interface ToastOptions {
  uiContext?: UIContext; //UIContext上下文
  message?: string | Resource; //显示的文本信息。默认字体为'Harmony Sans'，不支持设置其他字体。
  duration?: number //默认值1500ms，取值区间：1500ms-10000ms。若小于1500ms则取默认值，若大于10000ms则取上限值10000ms。
  fontColor?: ResourceColor; // 文本提示框文本颜色。默认值：Color.Black
  bottom?: string | number;
  alignment?: Alignment; //对齐方式。默认值：undefined，默认底部偏上位置。
  offset?: Offset;
  backgroundColor?: ResourceColor;
  backgroundBlurStyle?: BlurStyle;
  shadow?: ShadowOptions | ShadowStyle; //文本提示框背板阴影。默认值：ShadowStyle.OUTER_DEFAULT_MD
  showMode?: promptAction.ToastShowMode; //设置弹窗是否显示在应用之上。默认值：ToastShowMode.DEFAULT，默认显示在应用内。
}