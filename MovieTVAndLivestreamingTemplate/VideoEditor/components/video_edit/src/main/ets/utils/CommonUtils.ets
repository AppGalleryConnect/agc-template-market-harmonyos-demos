import { image } from '@kit.ImageKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import ConstantsUtil from './ConstantsUtil';
import { VideoSizeData } from '../model/VideoSizeData';
import { frameListData } from 'video_common';

//初始化沙盒目录
export function initializeFolder(context: UIContext) {
  let basicVideoDir = context.getHostContext()?.cacheDir + ConstantsUtil.BASIC_VIDEO_URL
  let pipVideoDir = context.getHostContext()?.cacheDir + ConstantsUtil.PIP_VIDEO_URL
  let basicVideoFrameDir = context.getHostContext()?.cacheDir + ConstantsUtil.BASIC_VIDEO_FRAME_URL
  let pipVideoFrameDir = context.getHostContext()?.cacheDir + ConstantsUtil.PIP_VIDEO_FRAME_URL
  let subTitleDir = context.getHostContext()?.cacheDir + ConstantsUtil.VIDEO_SUBTITLE_URL
  let autoCueDir = context.getHostContext()?.cacheDir + ConstantsUtil.VIDEO_AUTOCUE_URL
  let videoCover = context.getHostContext()?.cacheDir + ConstantsUtil.VIDEO_COVER_URL
  if (!fs.accessSync(basicVideoDir)) {
    fs.mkdirSync(basicVideoDir)
  }
  if (!fs.accessSync(pipVideoDir)) {
    fs.mkdirSync(pipVideoDir)
  }
  if (!fs.accessSync(basicVideoFrameDir)) {
    fs.mkdirSync(basicVideoFrameDir)
  }
  if (!fs.accessSync(pipVideoFrameDir)) {
    fs.mkdirSync(pipVideoFrameDir)
  }
  if (!fs.accessSync(subTitleDir)) {
    fs.mkdirSync(subTitleDir)
  }
  if (!fs.accessSync(autoCueDir)) {
    fs.mkdirSync(autoCueDir)
  }
  if (!fs.accessSync(videoCover)) {
    fs.mkdirSync(videoCover)
  }
}

export async function imageGeneratorGetThumbnail(selectUri: string) {

  if (selectUri === '') {
    return;
  }
  // 创建AVImageGenerator对象
  let avImageGenerator: media.AVImageGenerator | null = null;
  let fileAlbum: fs.File| null = null;
  try {
    avImageGenerator = await media.createAVImageGenerator()
    fileAlbum = fs.openSync(selectUri, fs.OpenMode.READ_ONLY)
    let avFileDescriptor: media.AVFileDescriptor = { fd: fileAlbum.fd };
    avImageGenerator.fdSrc = avFileDescriptor;
  } catch (error) {
  } finally {
    // 释放资源
    avImageGenerator?.release()
    fs.closeSync(fileAlbum);
  }

}

//获取相册选取的视频时长
export async function getVideoDuration(selectedVideoUri: string, context: UIContext): Promise<number> {
  let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context.getHostContext());
  let predicates: dataSharePredicates.DataSharePredicates =
    new dataSharePredicates.DataSharePredicates();
  predicates.equalTo('uri', selectedVideoUri);
  let fetchOption: photoAccessHelper.FetchOptions = {
    fetchColumns: [photoAccessHelper.PhotoKeys.WIDTH, photoAccessHelper.PhotoKeys.HEIGHT,
      photoAccessHelper.PhotoKeys.TITLE, photoAccessHelper.PhotoKeys.SIZE,
      photoAccessHelper.PhotoKeys.DURATION],
    predicates: predicates
  };
  let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
    await phAccessHelper.getAssets(fetchOption);
  let asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
  let rawDuration = asset.get(photoAccessHelper.PhotoKeys.DURATION);
  return Number(rawDuration);
}

//格式化时间格式
export function formatTime(milliseconds: number): string {
  let minutes = Math.floor(milliseconds / ConstantsUtil.MINUTES_TO_MILLISECONDS);
  let seconds =
    Math.floor((milliseconds % ConstantsUtil.MINUTES_TO_MILLISECONDS) / ConstantsUtil.SECONDS_TO_MILLISECONDS);
  // 格式化为两位数
  let pad = (num: number) => num.toString().padStart(2, '0');
  return `${pad(minutes)}:${pad(seconds)}`;
}

//获取视频宽高和时长
export async function getVideoData(selectUri: string): Promise<VideoSizeData> {
  let videoSize: VideoSizeData = new VideoSizeData();
  let avMetaDataExtractor: media.AVMetadataExtractor | null = null;
  let fileAlbum: fs.File| null = null;
  try {
    avMetaDataExtractor = await media.createAVMetadataExtractor();
    fileAlbum = fs.openSync(selectUri, fs.OpenMode.READ_ONLY);
    let avFileDescriptor: media.AVFileDescriptor = { fd: fileAlbum.fd };
    avMetaDataExtractor.fdSrc = avFileDescriptor;
    let metadata = await avMetaDataExtractor.fetchMetadata();
    videoSize.rotation = metadata.videoOrientation ?? '0'
    videoSize.photoSize.width = parseInt(metadata.videoWidth as string);
    videoSize.photoSize.height = parseInt(metadata.videoHeight as string);
    if (metadata.duration) {
      videoSize.totalTime = parseInt(metadata.duration);
    }
  } catch (error) {
  } finally {
    avMetaDataExtractor?.release();// 释放资源
    fs.closeSync(fileAlbum);
  }


  return videoSize;
}

//保存图片到相册或者沙盒路径
export async function savePixelMapToAlbum(mContext: UIContext, pixelMapData: frameListData) {
  let pixelMap: image.PixelMap | undefined
  if(pixelMapData.url !== '' && pixelMapData.url.length > 1){
    try {
      const imageSourceApi: image.ImageSource = image.createImageSource(pixelMapData.url);
      let decodingOptions: image.DecodingOptions = {
        editable: true,
      };
      pixelMap = imageSourceApi.createPixelMapSync(decodingOptions);
    }catch (error) {
    }
  }else {
    pixelMap = pixelMapData.mPixelMap
  }
  if (!pixelMap) {
    mContext.getPromptAction().showToast({ message: '图片数据为空，保存失败' });
    return;
  }
  try {
    //创建临时文件路径（用于临时存储编码后的图片）
    const tempDir = mContext.getHostContext()?.cacheDir;
    const tempFilePath = `${tempDir}/temp_cover.jpg`;
    //将PixelMap编码为JPEG文件（保存到临时路径）
    let tempFd: fs.File | null = null;
    try {
      tempFd = fs.openSync(tempFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const imagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      await imagePacker.packToFile(pixelMap, tempFd.fd, packOpts) //把pixelMap转化成文件
    } finally {
      if (tempFd) {
        fs.closeSync(tempFd);
      }
    }
    //预约媒体库 URI
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(mContext.getHostContext());
    const srcFileUri = fileUri.getUriFromPath(tempFilePath);
    let srcFileUris: Array<string> = [
      srcFileUri
    ];
    const photoCreationConfigs: photoAccessHelper.PhotoCreationConfig[] = [{
      fileNameExtension: 'jpg',
      photoType: photoAccessHelper.PhotoType.IMAGE,
      subtype: photoAccessHelper.PhotoSubtype.DEFAULT
    }];
    const desFileUris = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
    //把数据拷进媒体库
    let srcFile: fs.File | undefined;
    let desFile: fs.File | undefined;
    try {
      srcFile = await fs.open(tempFilePath, fs.OpenMode.READ_ONLY);
      desFile = await fs.open(desFileUris[0], fs.OpenMode.WRITE_ONLY);
      await fs.copyFile(srcFile.fd, desFile.fd);
    } finally {
      srcFile && fs.close(srcFile);
      desFile && fs.close(desFile);
    }
    //删除临时文件
    fs.unlinkSync(tempFilePath);
    mContext.getPromptAction().showToast({ message: '图片已保存到相册' });
  } catch (err) {
    //错误处理
    const error = err as BusinessError;
    mContext.getPromptAction().showToast({ message: '保存相册失败，请重试' });
  }
}

//把PixelMap保存成图片存到沙盒路径
export async function saveScreenshot(mContext: UIContext, pixelMap: image.PixelMap | string,
  flag: number, fileName: string): Promise<string> {
  if (typeof pixelMap === 'string') {
    return pixelMap
  }
  const baseDir = mContext.getHostContext()?.cacheDir
  if (fileName === '') {
    fileName = new Date().getTime().toString()
  }

  let targetPath: string = ''
  let tempUrl: string = ''
  switch (flag) {
    case 0: //基本视频帧路径
      tempUrl = ConstantsUtil.BASIC_VIDEO_FRAME_URL
      break;
    case 1: //画中画视频帧路径
      tempUrl = ConstantsUtil.PIP_VIDEO_FRAME_URL
      break;
    case 2: //字幕帧路径
      tempUrl = ConstantsUtil.VIDEO_SUBTITLE_URL
      break;
    case 3: //提词器帧路径
      tempUrl = ConstantsUtil.VIDEO_AUTOCUE_URL
      break;
    case 4: //视频封面
      tempUrl = ConstantsUtil.VIDEO_COVER_URL
      break;
    default:
      tempUrl = ConstantsUtil.BASIC_VIDEO_FRAME_URL
      break;
  }
  let file: fs.File | null = null
  try {
    let imagePackerApi = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/png', quality: 90 }; // 可选择格式和质量
    // 保存文件到沙箱环境
    const imgBuffer: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
    const tempDir = baseDir + tempUrl
    targetPath = tempDir + '/' + fileName + '.png'; // 文件保存路径
    file = await fs.open(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    await fs.write(file.fd, imgBuffer);

  } catch (error) {
    if (fs.accessSync(targetPath)) {
      fs.unlinkSync(targetPath);
    }
  } finally {
    if (!!file) {
      fs.closeSync(file)
    }
    file = null;
  }
  return targetPath
}

/**
 *  判断添加视频的时长和分辨率
 *
 * @param videoData
 * @param flag 0：首页开始创作时添加的视频；其他：视频编辑页面添加的视频
 * @returns
 */
export function judgeVideoLegality(videoData: VideoSizeData, flag: number): boolean{
  // 设置两个视频的时长
  const time = flag === 0 ? 5 * 60 * 1000 : 1 * 60 * 1000
  const videoWidth = videoData.photoSize.width ?? 0
  const videoHeight = videoData.photoSize.height ?? 0
  if(videoData.totalTime > time + 1000){
    return false
  }else if(videoWidth >= 3840 && videoHeight >= 2160){
    return false
  }else {
    return true
  }
}

/**
 * 递归删除指定目录下的所有内容
 * @param folderPath 要删除的目录路径
 */
export async function deleteFolderRecursively(folderPath: string) {
  const fileList = await fs.listFile(folderPath);
  for (const fileInfo of fileList) {
    const fullPath = `${folderPath}/${fileInfo}`;
    const stat = await fs.stat(fullPath);

    if (stat.isFile()) {
      await fs.unlink(fullPath);
    } else if (stat.isDirectory()) {
      await deleteFolderRecursively(fullPath);
      await fs.rmdir(fullPath);
    }
  }
}