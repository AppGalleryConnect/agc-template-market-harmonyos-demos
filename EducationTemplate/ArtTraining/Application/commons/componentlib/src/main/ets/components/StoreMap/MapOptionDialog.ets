import { PopViewUtil } from 'commonlib';
import { StoreMapVM } from './StoreMapVM';


@Builder
export function mapOptionsDialog() {
  Column({ space: 8 }) {
    Row() {
      Text('华为地图')
        .fontColor($r('app.color.font_color_link'))
    }
    .onClick(() => {
      StoreMapVM.instance.jumpToMapApp();
    })
    .optionContainerStyle();

    Row() {
      Text('取消')
        .fontColor($r('app.color.font_color_link'));
    }
    .optionContainerStyle()
    .onClick(()=> {
      PopViewUtil.closeDialog();
    })
  }
  .width($r('app.string.width_percent_full'))
  .margin({ bottom: $r('app.string.margin_xl') });
}

@Extend(Row)
function optionContainerStyle() {
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('app.color.system_color_background_white'))
  .borderRadius(99)
  .padding($r('app.string.padding_l'))
  .width('90%');
}