import { MusicResp, SoundResp, StickerResp } from '../model/Index';

export const mockStickerList: StickerResp[] = [
  {
    stickerId: 'hot_1',
    tag: '热门',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/bc_ic_hot_1.png?token=4a8d15ae-72eb-4345-af4c-7fad7c5100ba',
  },
  {
    stickerId: 'hot_2',
    tag: '热门',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/bc_ic_hot_2.png?token=dc1b2892-c081-4472-bd36-7349b64aaaa9',
  },
  {
    stickerId: 'new_1',
    tag: '最新',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/bc_ic_new_1.png?token=7de5c501-dcc4-4254-bd0f-7b556a27a52e',
  },
  {
    stickerId: 'new_2',
    tag: '最新',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/bc_ic_new_2.png?token=f5a776a0-af2b-4a89-89e3-55938bed3b49',
  },
];

export const mockMusicList: MusicResp[] = [
  {
    musicId: 0,
    name: 'Dream It Possible',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/scenic-i0v1l/phone%2FDelacey%20-%20Dream%20It%20Possible.flac?token=0252b0cb-b617-4708-86dc-5b0d052529ab',
  },
  {
    musicId: 1,
    name: '梦想成真',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/scenic-i0v1l/phone%2FDelacey%20-%20Dream%20It%20Possible.flac?token=0252b0cb-b617-4708-86dc-5b0d052529ab',
  },
];

export const mockSoundList: SoundResp[] = [
  {
    soundId: 0,
    tag: '最新',
    name: '任务完成',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/dida.m4a?token=0bb0de7b-89a9-4514-ba55-75e7528a3ee5',
  },
  {
    soundId: 2,
    tag: '热门',
    name: '仙尘音效',
    source: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/tool1-jplab/dingdong.m4a?token=c043fa52-3266-4815-80f6-e004da1bdf20',
  }
];