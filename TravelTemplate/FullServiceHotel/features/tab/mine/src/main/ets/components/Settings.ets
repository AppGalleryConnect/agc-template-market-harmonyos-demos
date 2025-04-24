import { SettingItem } from '../types';
import { MinePageVM } from '../viewModels/MinePageVM';

@ComponentV2
export struct Settings {
  vm: MinePageVM = MinePageVM.instance;
  @Local settingList: SettingItem[][] = [];

  aboutToAppear(): void {
    this.settingList = this.vm.getSettingGroupList();
  }

  build() {
    Column() {
      List({ space: '16vp' }) {
        ForEach(this.settingList, (group: SettingItem[]) => {
          ListItemGroup() {
            ForEach(group, (item: SettingItem, index: number) => {
              ListItem() {
                this.settingListItemBuilder(item);
              };
            }, (item: SettingItem) => JSON.stringify(item));
          }
          .backgroundColor($r('app.color.font_color_level1_invert'))
          .borderRadius($r('app.string.border_radius_16'))
          .padding({
            left: $r('app.string.padding_s'),
            right: $r('app.string.padding_s'),
          })
          .divider({
            strokeWidth: 1,
            color: $r('app.color.system_color_grey_level1'),
          });
        }, (item: SettingItem[]) => JSON.stringify(item));
      };
    }
    .width('100%')
    .margin({
      top: $r('app.string.margin_m'),
      bottom: $r('app.string.margin_m'),
    });
  }

  @Builder
  settingListItemBuilder(item: SettingItem) {
    Flex({
      alignItems: ItemAlign.Center,
    }) {
      Image(item.icon)
        .width(20)
        .margin({ left: $r('app.string.margin_s'), right: $r('app.string.margin_s') });
      Text(item.label)
        .flexGrow(1)
        .fontSize($r('app.string.font_size_28'));
      Image($r('app.media.ic_right_arrow')).width(16);
    }
    .margin({
      top: $r('app.string.margin_m'),
      bottom: $r('app.string.margin_m'),
    })
    .onClick(() => {
      this.vm.jumpToNext(item);
    });
  }
}