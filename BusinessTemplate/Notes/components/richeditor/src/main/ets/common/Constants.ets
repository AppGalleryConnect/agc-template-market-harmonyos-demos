export const SNAPSHOT_ID = 'SNAPSHOT_ID'
export const RICH_ID = 'RICH_ID';

// 原色滤镜
export const ORIGIN_COLOR_FILTER: ColorFilter = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0
];

// 菜单等场景：将图标压成纯黑 #000000（保留 Alpha）
export const BLACK_ICON_COLOR_FILTER: ColorFilter = [
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0,
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
export const COLOR_LIST: ResourceColor[] =
  ['#E5000000', '#FF774342', '#FFFFF200', '#FFFF7F27', '#FFED1C24',
    '#FFEF88BE', '#FFA349A4', '#FF00A2E8', '#FF22B14C', '#FF888888'];