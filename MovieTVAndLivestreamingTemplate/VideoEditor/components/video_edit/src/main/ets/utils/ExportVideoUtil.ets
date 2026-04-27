import { fileIo, fileUri } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { exportVideo, ResolutionAspect } from 'video_common';
import { CODEC_TABLE, RESOLUTION_TABLE } from './ConstantsUtil';
import { WorkListViewModel, WorkViewModel } from 'video_common';

// 毫秒转为 ffmpeg 兼容的 HH:MM:SS 字符串
export function msToHms(ms: number): string {
  const totalSeconds = Math.max(0, Math.floor(ms / 1000));
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
}

// 将 ‘MM:SS’ 或 'HH:MM:SS' 时间格式转换为毫秒
export function mmSsToMs(text: string): number {
  const str = (text ?? '').trim();
  if (!str) {
    return 0;
  }

  const parts = str.split(':').map(p => p.trim());
  let hours = 0;
  let minutes = 0;
  let seconds = 0;

  if (parts.length === 2) {
    minutes = parseInt(parts[0], 10);
    seconds = Math.floor(parseFloat(parts[1]));
  } else if (parts.length === 3) {
    hours = parseInt(parts[0], 10);
    minutes = parseInt(parts[1], 10);
    seconds = Math.floor(parseFloat(parts[2]));
  } else {
    return 0;
  }

  if ([hours, minutes, seconds].some(v => isNaN(v) || v < 0)) {
    return 0;
  }

  const totalMs = ((hours * 60 + minutes) * 60 + seconds) * 1000;
  return totalMs;
}

// 获取视频文件大小
export function getFileSizeStr(path: string): string {
  try {
    const stat = fs.statSync(path);
    const sizeBytes = stat.size ?? 0;
    const sizeMB = sizeBytes / (1024 * 1024);
    return `${sizeMB.toFixed(1)}MB`;
  } catch (_) {
    return '';
  }
}

// 统一将任意异常转为 Error，以满足 ArkTS 抛出限制
export function normalizeError(err: Error | string | number | boolean | null | undefined): Error {
  if (err instanceof Error) {
    return err;
  }
  if (err === null || err === undefined) {
    return new Error('Unknown error');
  }
  if (typeof err === 'string') {
    return new Error(err);
  }
  return new Error(String(err));
}

// 获取title
export function buildTodayIndex(workList: WorkListViewModel, createDate: string): number {
  try {
    const existingList = workList.lists;
    let count = 0;
    for (let i = 0; i < existingList.length; i++) {
      const it = existingList[i];
      if (it && it.createDate === createDate) {
        count = count + 1;
      }
    }
    return count;
  } catch (_) {
    return 0;
  }
}

// 读取元数据信息
export async function getMetadataInfo(outputPath: string): Promise<ResolutionAspect> {
  let width = 0, height = 0, duration = 0, hasAudio = '';
  let f: fileIo.File | undefined = undefined;
  try {
    f = fileIo.openSync(outputPath, fileIo.OpenMode.READ_ONLY);
    const avfd: media.AVFileDescriptor = { fd: f.fd };
    const extractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
    extractor.fdSrc = avfd;
    const md = await extractor.fetchMetadata();
    width = md.videoWidth ? parseInt(md.videoWidth as string) : 0;
    height = md.videoHeight ? parseInt(md.videoHeight as string) : 0;
    duration = md.duration ? parseInt(md.duration as string) : 0;
    hasAudio = md.hasAudio ? md.hasAudio : '';
    extractor.release();
  } catch (_) {
  } finally {
    if (f) {
      fs.closeSync(f);
    }
  }
  const aspect = width > 0 && height > 0 ? (width / height) : 0;
  return {
    width,
    height,
    aspect,
    duration,
    hasAudio
  };
}

// 复制源视频到沙箱输入路径
export async function fsCopy(src: string, destPath: string): Promise<void> {
  let from = src.startsWith('file://') ? src : fileUri.getUriFromPath(src)
  let to = destPath.startsWith('file://') ? destPath : fileUri.getUriFromPath(destPath)
  await fs.copy(from, to).then(() => {
  }).catch((err: BusinessError) => {
  })
}

// 保存封面图片
export async function PixelMapToImage(pixmap: image.PixelMap | undefined, coverImgFilePath: string): Promise<string> {
  let imgPacker = image.createImagePacker();
  let packOptions: image.PackingOption = { format: 'image/png', quality: 90 };
  // 定义输出路径
  try {
    const DATA = await imgPacker.packToData(pixmap, packOptions); // pixmap 为待保存的 PixelMap 对象
    let file = fs.openSync(coverImgFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    try {
      fs.writeSync(file.fd, DATA);
    } catch (e) {
    } finally {
      fs.closeSync(file.fd);
    }
    imgPacker.release();

  } catch (error) {
  }
  return coverImgFilePath;
}


// 导出成功写入作品数据
export async function successSaveWork(
  outputPath: string,
  detail: exportVideo,
  videoThumbnail: string,
  bitCodec: string
): Promise<void> {
  try {
    const workList = PersistenceV2.connect(WorkListViewModel, 'WorkList', () => new WorkListViewModel())!;
    const newWork = new WorkViewModel();
    const resInfo = await getMetadataInfo(outputPath);
    const aspect = resInfo.aspect;
    const resolutionRatio = `${resInfo.width}*${resInfo.height}` || '';
    const duration = resInfo.duration;
    const fileSizeStr = getFileSizeStr(outputPath);
    const now = new Date();
    const createTimestamp = now.getTime();
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const createTime = `${pad2(now.getHours())}:${pad2(now.getMinutes())}`;
    const createDate = `${now.getFullYear()}年${pad2(now.getMonth() + 1)}月${pad2(now.getDate())}日`;
    const dayStr = pad2(now.getDate());
    const monthStr = pad2(now.getMonth() + 1);
    const titleIndex = buildTodayIndex(workList, createDate) + 1;

    newWork.id = createTimestamp.toString();
    newWork.title = `${monthStr}${dayStr}-${titleIndex}`;
    newWork.status = 'finish';
    newWork.duration = msToHms(duration);
    newWork.thumbnail = videoThumbnail;
    newWork.createTime = createTime;
    newWork.createDate = createDate;
    newWork.createTimestamp = createTimestamp;
    newWork.fileSize = fileSizeStr || '0MB';
    newWork.fileFormat = detail.videoFormat;
    newWork.videoCodeFormat = bitCodec || '';
    newWork.audioCodeFormat = 'aac' || '';
    newWork.resolutionRatio = resolutionRatio;
    newWork.videoUrl = fileUri.getUriFromPath(outputPath);
    newWork.aspectRatio = aspect ? aspect.toFixed(4) : '';
    newWork.routerParams = JSON.stringify(detail);
    workList.addList(newWork);
    PersistenceV2.save('WorkList');
  } catch (_) {
    // 写入失败不影响导出流程
  }
}

//导出失败写入作品数据
export async function failSaveWork(detail: exportVideo, coverImgFilePath: string): Promise<void> {
  try {
    // 获取视频编码格式
    let codecArray: string[] = CODEC_TABLE.get(detail.videoFormat) as string[];
    const bitCodec = codecArray[0];
    // 视频分辨率
    let resolutionArray: string[] = RESOLUTION_TABLE.get(detail.videoResolution) as string[];
    const bitResolution = resolutionArray;
    // 获取视频封面图片
    const thumbnail = detail.keyFrame
    const videoThumbnail = fileUri.getUriFromPath(thumbnail);

    const workList = PersistenceV2.connect(WorkListViewModel, 'WorkList', () => new WorkListViewModel())!;
    const newWork = new WorkViewModel();
    const width = bitResolution[0] ? parseInt(bitResolution[0] as string) : 0;
    const height = bitResolution[1] ? parseInt(bitResolution[1] as string) : 0;
    const resolutionRatio = `${width}*${height}`;
    const aspect = width > 0 && height > 0 ? (width / height) : 0;
    const duration = detail.totalDuration;
    const now = new Date();
    const createTimestamp = now.getTime();
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    const createTime = `${pad2(now.getHours())}:${pad2(now.getMinutes())}`;
    const createDate = `${now.getFullYear()}年${pad2(now.getMonth() + 1)}月${pad2(now.getDate())}`;
    const dayStr = pad2(now.getDate());
    const monthStr = pad2(now.getMonth() + 1);
    const titleIndex = buildTodayIndex(workList, createDate) + 1;

    newWork.id = createTimestamp.toString();
    newWork.title = `${monthStr}${dayStr}-${titleIndex}`;
    newWork.status = 'unFinish';
    newWork.duration = msToHms(duration);
    newWork.thumbnail = videoThumbnail;
    newWork.createTime = createTime;
    newWork.createDate = createDate;
    newWork.createTimestamp = createTimestamp;
    newWork.fileSize = '';
    newWork.fileFormat = detail.videoFormat;
    newWork.videoCodeFormat = bitCodec || '';
    newWork.audioCodeFormat = 'aac' || '';
    newWork.resolutionRatio = resolutionRatio;
    newWork.videoUrl = '';
    newWork.aspectRatio = aspect ? aspect.toFixed(4) : '';
    newWork.routerParams = JSON.stringify(detail);
    workList.addList(newWork);
    PersistenceV2.save('WorkList');
  } catch (_) {
  }
}


