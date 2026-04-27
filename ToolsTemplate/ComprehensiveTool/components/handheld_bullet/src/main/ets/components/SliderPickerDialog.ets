import { SliderOption } from '../model/Index';

@Builder
export function SliderPickerDialog(option: SliderOption) {
  Column() {
    Column() {
      TextInput({ text: `${option.current}` }).onChange((callback) => {
        option.current = Number(callback);
      }).enabled(false);
      Slider({
        style: SliderStyle.InSet,
        value: option.current,
        min: option.min,
        max: option.max,
        step: option.step,
      }).onChange((value) => {
        option.current = value;
      });
    };

    Row({ space: 12 }) {
      Button('取消').layoutWeight(1).backgroundColor($r('sys.color.comp_background_tertiary')).fontColor($r('sys.color.font_emphasize')).onClick(() => {
        option.closeCallBack();
      });
      Button('确定').layoutWeight(1).onClick(() => {
        option.confirmCallBack();
        option.closeCallBack();
      });
    };
  }.padding(16).height('100%').justifyContent(FlexAlign.SpaceBetween);
}