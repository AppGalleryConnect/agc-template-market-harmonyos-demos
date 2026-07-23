import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'module_weather_core';
import { VoiceListItem } from '../components/VoiceListItem';
import { VoicePackage } from '../types/Types';
import { BroadCastUtil } from '../utils/BroadcastUtil';

@ComponentV2
export struct VoiceList {
  @Param space: string | number = 7;
  @Local list: VoicePackage[] = [];
  @Local breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get listLanes(): number {
    return this.breakpointModel.isLargeWindow ? 2 : 1;
  }

  @Computed
  get lanesGap(): number {
    return this.breakpointModel.isLargeWindow ? 16 : 0;
  }

  @Computed
  get listSpace(): string | number {
    return this.breakpointModel.isLargeWindow ? 16 : this.space;
  }

  @Computed
  get itemBorderRadius(): number {
    return this.breakpointModel.isSmallWindow ? 0 : 16;
  }

  aboutToAppear(): void {
    BroadCastUtil.getVoiceList().then(res => this.list = res);
  }

  build() {
    if (this.list.length) {
      List({ space: this.listSpace }) {
        ForEach(this.list, (voice: VoicePackage) => {
          VoiceListItem({
            voice: voice,
            cardRadius: this.itemBorderRadius,
            callback: () => {
              BroadCastUtil.getVoiceList().then(res => this.list = res);
            },
          })
        }, (voice: VoicePackage, index) => JSON.stringify(voice) + '_' + index)
      }
      .width('100%')
      .height('100%')
      .lanes(this.listLanes, this.lanesGap)
      .scrollBar(BarState.Off)
    } else {
      Column() {
        Text('暂无语音包')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}
