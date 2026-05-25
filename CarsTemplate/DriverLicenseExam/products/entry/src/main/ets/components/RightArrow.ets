@Builder
export function rightArrow (){
  // 自动适配主题：在深色模式使用更亮的图标，浅色模式使用当前系统颜色
  fontColor($r('app.color.icon_secondary'))
    .opacity(0.5)
    .fontSize('24vp');
  SymbolGlyph($r('sys.symbol.chevron_right'));
}
