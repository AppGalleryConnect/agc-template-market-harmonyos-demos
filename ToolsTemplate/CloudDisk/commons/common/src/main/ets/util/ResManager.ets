/**
 * @fileType: common
 * @zhName: 资源管理工具类
 */
export function getString(resKey: string, ...params: Array<number | string>): Resource {
  return $r(resKey, ...params);
}

export function getMedia(resKey: string, ...params: Array<number | string>): Resource {
  return $r(resKey, ...params);
}

export function getColor(resKey: string): Resource {
  return $r(resKey);
}