import { systemShare } from '@kit.ShareKit';
import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

export function formatFullDate(date: Date): string {
  const pad = (n: number) => n < 10 ? '0' + n : n.toString();

  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
  const day = pad(date.getDate());
  const hours = pad(date.getHours());
  const minutes = pad(date.getMinutes());
  const seconds = pad(date.getSeconds());

  return `${year}-${month}-${day}_${hours}_${minutes}_${seconds}`;
}

export function formatTimestamp(timestamp: number, isSeconds: boolean = false): string {
  // 处理秒级时间戳（转换为毫秒）
  const msTimestamp = isSeconds ? timestamp * 1000 : timestamp;

  // 创建Date对象
  const date = new Date(msTimestamp);

  // 获取各时间部分并补零
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); // 月份从0开始
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');

  // 拼接成目标格式
  return `${year}年${month}月${day}日${hours}:${minutes}`;
}

export function formatBytes(bytes: number, decimals: number = 2): string {
  // 处理0字节的情况
  if (bytes === 0) {
    return '0 B';
  }

  // 定义单位和转换系数
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  // 计算最适合的单位指数
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  // 计算转换后的值并格式化
  const value = parseFloat((bytes / Math.pow(k, i)).toFixed(dm));

  return `${value} ${sizes[i]}`;
}

export function shareData(context: common.UIAbilityContext, path: string) {
  let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.zip', utd.UniformDataType.ZIP_ARCHIVE)
  let uri = fileUri.getUriFromPath(path)
  let data: systemShare.SharedData = new systemShare.SharedData({
    utd: utdTypeId,
    uri: uri,
  })
  let controller: systemShare.ShareController = new systemShare.ShareController(data);
  controller.on('dismiss', () => {
    Logger.info('TestShare Share panel closed');
    // 分享结束，可处理其他业务。
  });
  // 进行分享面板显示
  controller.show(context, {
    previewMode: systemShare.SharePreviewMode.DETAIL,
    selectionMode: systemShare.SelectionMode.SINGLE,
  });
}