import { BaseViewModel } from 'lib_common';
import { SettingGroup, SettingItem, SettingType } from 'module_app_setting';

@ObservedV2
export class SettingNetworkVM extends BaseViewModel {
  @Trace item1: SettingItem = new SettingItem()
    .setType(SettingType.SELECT)
    .setLabel('非WLAN网络流量')
    .setSelectOptions([
      {
        id: 0,
        label: '最佳效果（下载大图）',
      },
      {
        id: 1,
        label: '较省流量（智能下载）',
      },
      {
        id: 2,
        label: '极省流量（不下载图）',
      },
    ])
    .setSelectIndex(this.settingInfo.network.downloadWithoutWlan)
    .setSelectEvent((index: number) => {
      this.settingInfo.network.downloadWithoutWlan = index;
    });
  @Trace item2: SettingItem = new SettingItem()
    .setType(SettingType.SELECT)
    .setLabel('非WLAN网络播放提醒')
    .setSelectOptions([
      {
        id: 0,
        label: '提醒一次',
      },
      {
        id: 1,
        label: '每次提醒',
      },
    ])
    .setSelectIndex(this.settingInfo.network.remindWithoutWlan)
    .setSelectEvent((index: number) => {
      this.settingInfo.network.remindWithoutWlan = index;
    });
  @Trace item3: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('使用移动网络改善内容浏览体验')
    .setSubLabel('如Wi-Fi网络质量差，将使用移动网络改善')
    .setSwitchValue(this.settingInfo.network.optimizeWith4G)
    .setClickEvent((isOn) => {
      this.item3.setSwitchValue(isOn as boolean);
      this.settingInfo.network.optimizeWith4G = isOn as boolean;
    });
  @Trace item4: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('退出视频自动小窗播放')
    .setSubLabel('从直播或者电视详情页面返回或者退到应用后台时生效')
    .setSwitchValue(this.settingInfo.network.enableLivePiP)
    .setClickEvent((isOn) => {
      this.item4.setSwitchValue(isOn as boolean);
      this.settingInfo.network.enableLivePiP = isOn as boolean;
    });
  @Trace item5: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('退出广播自动小窗播放')
    .setSubLabel('从广播切换到其他页面或者退到应用后台时生效')
    .setSwitchValue(this.settingInfo.network.enableAudioSub)
    .setClickEvent((isOn) => {
      this.item5.setSwitchValue(isOn as boolean);
      this.settingInfo.network.enableAudioSub = isOn as boolean;
    });
  @Trace item6: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('视频自动下滑')
    .setSubLabel('视频观看结束将自动下滑至下一个视频')
    .setSwitchValue(this.settingInfo.network.autoPlayNext)
    .setClickEvent((isOn) => {
      this.item6.setSwitchValue(isOn as boolean);
      this.settingInfo.network.autoPlayNext = isOn as boolean;
    });
  @Trace item7: SettingItem = new SettingItem()
    .setType(SettingType.SWITCH)
    .setLabel('推荐频道自动播放视频')
    .setSwitchValue(this.settingInfo.network.autoPlayTabRecommend)
    .setClickEvent((isOn) => {
      this.item7.setSwitchValue(isOn as boolean);
      this.settingInfo.network.autoPlayTabRecommend = isOn as boolean;
    });
  @Trace group1: SettingGroup = new SettingGroup()
    .setTitle('网络设置')
    .setList([
      this.item1,
      this.item2,
      this.item3,
    ]);
  @Trace group2: SettingGroup = new SettingGroup()
    .setTitle('视频播放设置')
    .setList([
      this.item4,
      this.item5,
      this.item6,
      this.item7,
    ]);
}