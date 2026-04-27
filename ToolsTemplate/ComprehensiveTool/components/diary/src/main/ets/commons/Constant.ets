import { IconTextItem } from './Interface';

export const SNAPSHOT_ID = 'SNAPSHOT_ID'
export const RICH_ID = 'RICH_ID';
export const WEB_ID = 'editor_web';
export const CALLBACK_SCHEME = 're-callback://';
export const STATE_SCHEME = 're-state://';
export const PHOTO_MAX_COUNT = 20;
export const PHOTO_MAX_SIZE = 1; // GB

export const WEEK_MAP = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']

export const TEXT_PICKER_DATA: Record<string, IconTextItem[]> = {
  'weather': [
    { icon: 'sys.symbol.sun_max_fill_1', text: '晴' }, { icon: 'sys.symbol.cloud_sun_fill', text: '多云' },
    { icon: 'sys.symbol.cloud_fill', text: '阴' }, { icon: 'sys.symbol.light_rain', text: '小雨' },
    { icon: 'sys.symbol.moderate_rain', text: '中雨' }, { icon: 'sys.symbol.heavy_rain', text: '大雨' },
    { icon: 'sys.symbol.thunder_storm', text: '雷阵雨' }, { icon: 'sys.symbol.heavysnow', text: '大雪' },
    { icon: 'sys.symbol.sleet', text: '雨夹雪' }, { icon: 'sys.symbol.foggy', text: '雾' },
  ],
  'mood': [
    { icon: 'app.media.ic_kaixin', text: '开心' }, { icon: 'app.media.ic_shangxin', text: '伤心' },
    { icon: 'app.media.ic_xiangku', text: '想哭' }, { icon: 'app.media.ic_xingfen', text: '兴奋' },
    { icon: 'app.media.ic_wuyu', text: '无语' }, { icon: 'app.media.ic_shengbing', text: '生病' },
    { icon: 'app.media.ic_fennu', text: '愤怒' }, { icon: 'app.media.ic_lei', text: '累' },
    { icon: 'app.media.ic_jingxia', text: '惊吓' }, { icon: 'app.media.ic_qidai', text: '期待' },
  ]
}

export const TITLE_MAP = ['写日记', '日记详情', '编辑日记'];

export const PASSWORD_REG = /^[A-Za-z0-9]+$/;

// 原色滤镜
export const ORIGIN_COLOR_FILTER: ColorFilter = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0
];

// 高亮颜色滤镜
export const HIGHLIGHT_COLOR_FILTER: ColorFilter = [
  0, 0, 0, 0, 1,
  0, 0, 0, 0, 0.5,
  0, 0, 0, 0, 0,
  0, 0, 0, 1, 0
];

// 调色盘选项
export const COLOR_LIST: string[] =
  ['#000000', '#774342', '#FFF200', '#FF7F27', '#ED1C24',
    '#EF88BE', '#A349A4', '#00A2E8', '#22B14C', '#888888'];
