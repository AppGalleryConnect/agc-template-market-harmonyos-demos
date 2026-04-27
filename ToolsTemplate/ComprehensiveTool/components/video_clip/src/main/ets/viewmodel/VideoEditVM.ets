import { image } from '@kit.ImageKit';
import { BusinessError } from '@ohos.base';
import { fileIo, fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import sdk from 'libveditor.so';
import { TrimType } from '../common/Enum';
import {
  AudioInfo,
  DownloadSound,
  DownloadSoundList,
  EditVideo,
  Point,
  SoundByTag,
  TextInfo,
  TImageInfo,
  VideoAsset,
} from '../model/Index';
import { Sticker, StickersByTag } from '../model/Sticker';
import { VideoUtil } from '../util/VideoUtil';
import { MusicResp, SoundResp, StickerResp } from '../network/model/Index';
import { Util } from '../util/Util';
import { VideoManageVM } from './VideoManageVM';

@ObservedV2
export class VideoEditVM {
  private static _instance: VideoEditVM;
  @Trace downloadSoundList: DownloadSoundList =
    PersistenceV2.connect(DownloadSoundList, 'DownloadSoundList', () => new DownloadSoundList())!;
  @Trace textInfo: TextInfo = new TextInfo();
  @Trace editTabIndex: number = 0;
  @Trace textPicker: boolean = false;
  @Trace stickerPicker: boolean = false;
  @Trace musicPicker: boolean = false;
  @Trace soundPicker: boolean = false;
  @Trace selectedStickerList: Sticker[] = [];
  @Trace textTabIndex: number = 0;
  @Trace stickerTabIndex: number = 0;
  @Trace soundTabIndex: number = 0;
  @Trace musicList: AudioInfo[] = [];
  @Trace selectedSoundList: AudioInfo[] = [];
  @Trace soundList: SoundByTag[] = [];
  @Trace stickerList: StickersByTag[] = [];
  @Trace videoThumbNail: image.PixelMap | null = null;
  @Trace videoThumbNailUri: string = '';
  @Trace fileSize: string = '';
  @Trace params: VideoAsset = new VideoAsset();
  @Trace draft: EditVideo = new EditVideo();
  @Trace isShowWordPanel: boolean = false;
  @Trace isFinish: boolean = false;
  @Trace inputText: string = '';
  @Trace isWordFile: boolean = false;
  @Trace wordUri: string = '';
  @Trace images: image.PixelMap[] = [];
  @Trace pixelMaps: image.PixelMap[] = [];
  @Trace timeUs: number[] = [];
  @Trace isVideo: boolean = true;
  @Trace imgUri: string = '';
  @Trace laneHeight: number = 48;
  @Trace duration: number = 0;
  @Trace durationError: number = 0;
  @Trace newDuration: number = 0;
  @Trace curDuration: number = 0;
  @Trace trimIn: number = 0;
  @Trace trimOut: number = 0;
  @Trace isDragMoving: boolean = false;
  @Trace isSeekMoving: boolean = false;
  @Trace exportProgress: number = 0;
  @Trace selectedAudio: AudioInfo = new AudioInfo();
  @Trace keepVideoAudio: boolean = true;
  @Trace stickers: Sticker[] = [];
  @Trace selectedStickerId: string = '';
  @Trace startOffsetX: number = 0;
  @Trace startOffsetY: number = 0;
  @Trace startScale: number = 1;
  @Trace curTrimInValue: number = 0;
  @Trace curTrimOutValue: number = 0;
  @Trace wordFilePaths: string[] = [];
  @Trace isAudio: boolean = false;
  @Trace uri: string = '';
  @Trace isInCut: boolean = false;
  @Trace showExportingBindCover: boolean = false;
  @Trace bgSoundFd: number[] = [];
  uiContext?: UIContext;
  surfaceID: string = '';
  xComponentController = new XComponentController();
  dragLeft: boolean = true;
  dragTrimValue: number = 0;
  seekValue: number = 0;
  dragStartPos: number = 0;
  trimType: TrimType = TrimType.Idle;
  exportInterval: number = 0;
  totalOutputVideoFilePath = '';

  public static get instance() {
    if (!VideoEditVM._instance) {
      VideoEditVM._instance = new VideoEditVM();
    }
    return VideoEditVM._instance;
  }

  setUiContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  load(uiContext: UIContext) {
    UtilLog.info(0xFF00, 'VideoClip', 'XComponent Onload');
    this.fetchFrameByTime(uiContext);
    // XComponent的容器宽度
    UtilLog.info(0xFF00, 'VideoClip',
      `calculate container size, screenWidth: ${this.params.screenWidth}, screenHeight: ${this.params.screenHeight}`);
    let containerWidth = uiContext.vp2px(this.params.screenWidth as number);
    let containerHeight = uiContext.vp2px((this.params.screenHeight as number * 0.65));
    UtilLog.info(0xFF00, 'VideoClip',
      `containerWidth: ${containerWidth}, containerHeight: ${containerHeight}`);
    // 根据容器宽度和视频的宽高比计算高度
    sdk.SetCanvasSize(containerHeight, containerWidth);
    const videoInfo: Array<Point> | undefined = sdk.GetDrawableArea();
    if (videoInfo !== undefined) {
      const videoWidth = videoInfo[1].x - videoInfo[0].x;
      const videoHeight = videoInfo[3].y - videoInfo[0].y;
      this.xComponentController.setXComponentSurfaceRect({
        offsetX: (containerWidth + 1 - videoWidth) / 2,
        offsetY: (containerHeight + 1 - videoHeight) / 2,
        surfaceWidth: videoWidth,
        surfaceHeight: videoHeight,
      });
      this.surfaceID = this.xComponentController.getXComponentSurfaceId();
      sdk.Play();
    }
  }

  // 画出贴纸
  @Monitor('imgUri')
  buildSticker() {
    this.stickers.forEach(sticker => sticker.isSelected = false);
    if (this.imgUri !== '') {
      let imageClass: TImageInfo = sdk.AddImage(this.imgUri, this.isWordFile);

      sdk.MoveImage(imageClass.imageId, (this.uiContext?.vp2px(this.params.screenWidth as number) ?? 0) / 2,
        (this.uiContext?.vp2px(this.params.screenHeight as number * 0.65) ?? 0) / 2);
      let newSticker =
        new Sticker(imageClass.imageId, this.imgUri, this.startOffsetX,
          this.startOffsetY, 1, 0, true, imageClass.width,
          imageClass.height, (this.uiContext?.vp2px(this.params.screenWidth as number) ?? 0) / 2,
          (this.uiContext?.vp2px(this.params.screenHeight as number * 0.65) ?? 0) / 2);

      this.stickers.push(newSticker);
      this.selectedStickerId = newSticker.id;
      this.imgUri = '';
    }
  }

  @Monitor('wordUri')
  buildText() {
    if (this.wordUri !== '') {
      let imageClass: TImageInfo = sdk.AddImage(this.wordUri, this.isWordFile);

      sdk.MoveImage(imageClass.imageId, (this.uiContext?.vp2px(this.params.screenWidth as number) ?? 0) / 2,
        (this.uiContext?.vp2px(this.params.screenHeight as number * 0.65) ?? 0) / 2);

      this.wordUri = '';
      this.isWordFile = false;
    }
  }

  clearPixelMap() {
    if (this.exportInterval) {
      clearInterval(this.exportInterval);
    }
    this.textTabIndex = 0;
    this.soundTabIndex = 0;
    this.stickerTabIndex = 0;
    this.isInCut = false;
    // 重置所有资源
    this.pixelMaps = [];
    this.isWordFile = false;
    this.wordUri = '';
    this.imgUri = '';
    this.isFinish = false;
    this.keepVideoAudio = true;
    this.isAudio = false;
    this.textInfo = new TextInfo();
    // 剪辑时间线重置
    this.trimIn = 0;
    this.trimOut = 0;
    this.wordFilePaths = [];
    this.selectedAudio = new AudioInfo();
    this.curTrimInValue = 0;
    this.curTrimOutValue = 0;
    // 关闭使用的背景音乐的句柄
    this.bgSoundFd.forEach((fd: number) => {
      fs.closeSync(fd);
    });
    sdk.DestroyEditor();
  }

  // 拖拽开始
  dragStart(isLeft: boolean, windowX: number) {
    sdk.Pause();
    this.isDragMoving = true;
    this.dragLeft = isLeft;
    this.dragTrimValue = isLeft ? this.trimIn : this.trimOut;
    this.dragStartPos = windowX;
    this.changeTrimType(isLeft);
    this.curDuration = this.newDuration - this.curTrimInValue - this.curTrimOutValue;
  }

  // 拖拽中
  dragMoving(windowX: number) {
    this.isSeekMoving = true;
    sdk.Pause();
    let deltaX = windowX - this.dragStartPos;
    if (this.dragLeft) {
      let newTrimIn = this.dragTrimValue + this.toTime(deltaX);
      let maxValue = Math.max(0, this.duration - this.trimOut - 30);
      newTrimIn = newTrimIn < 0 ? 0 : (newTrimIn > maxValue ? maxValue : newTrimIn);
      this.trimIn = newTrimIn;
      this.curTrimInValue = (newTrimIn / this.duration) * this.newDuration;
      this.curDuration = this.newDuration - this.curTrimInValue - this.curTrimOutValue;
    } else {
      let newTrimOut = this.dragTrimValue - this.toTime(deltaX);
      let maxValue = Math.max(0, this.duration - this.trimIn - 30);
      newTrimOut = newTrimOut < 0 ? 0 : (newTrimOut > maxValue ? maxValue : newTrimOut);
      this.trimOut = newTrimOut;
      this.curTrimOutValue = (newTrimOut / this.duration) * this.newDuration;
      this.curDuration = this.newDuration - this.curTrimInValue - this.curTrimOutValue;
    }
  }

  // 拖拽结束
  dragEnd() {
    if (this.trimType === TrimType.DragLeftBar) {
      UtilLog.info(0xFF00, 'VideoClip', `clip move DragLeftBar to ${this.seekValue}`);
    } else if (this.trimType === TrimType.DragRightBar) {
      UtilLog.info(0xFF00, 'VideoClip', `clip move DragRightBar to ${this.seekValue}`);
    }
    this.isSeekMoving = false;
    this.isDragMoving = false;
    sdk.SetTrim(this.curTrimInValue, this.curTrimOutValue);
    sdk.PlayFromStart();
    this.curDuration = this.newDuration - this.curTrimInValue - this.curTrimOutValue;
  }

  handleMusicByTag(result: MusicResp[]) {
    if (this.musicList.length) {
      this.musicList.forEach((item: AudioInfo) => {
        let downloadSound: DownloadSound | undefined =
          this.downloadSoundList.list.find((sound: DownloadSound) => sound.name === item.name);
        if (downloadSound) {
          item.isCached = true;
          item.fileUri = downloadSound.fileUri;
        }
      });
    } else {
      result.forEach((item: MusicResp) => {
        let audio = new AudioInfo();
        audio.uri = item.source;
        audio.name = item.name;
        let downloadSound: DownloadSound | undefined =
          this.downloadSoundList.list.find((sound: DownloadSound) => sound.name === audio.name);
        if (downloadSound) {
          audio.isCached = true;
        }
        this.musicList.push(audio);
      });
    }
  }

  handleSoundByTag(result: SoundResp[]) {
    // 先清空音效列表
    if (this.soundList.length) {
      this.soundList.forEach((item: SoundByTag) => {
        item.sounds.forEach((sound: AudioInfo) => {
          let downloadSound: DownloadSound | undefined =
            this.downloadSoundList.list.find((item: DownloadSound) => item.name === sound.name);
          if (downloadSound) {
            sound.isCached = true;
            sound.fileUri = downloadSound.fileUri;
          }
        });
      });
    } else {
      result.forEach(item => {
        let tagSounds = this.soundList.find(sound => sound.tag === item.tag);
        let downloadSound: DownloadSound | undefined =
          this.downloadSoundList.list.find((sound: DownloadSound) => sound.name === item.name);

        if (tagSounds) {
          let audio = new AudioInfo();
          audio.id = item.soundId;
          audio.uri = item.source;
          audio.name = item.name;
          if (downloadSound) {
            audio.isCached = true;
            audio.fileUri = downloadSound.fileUri;
          }
          tagSounds.sounds.push(audio);
        } else {
          let soundsByTag: SoundByTag = new SoundByTag();
          soundsByTag.tag = item.tag;

          let audio = new AudioInfo();
          audio.id = item.soundId;
          audio.uri = item.source;
          audio.name = item.name;
          if (downloadSound) {
            audio.isCached = true;
            audio.fileUri = downloadSound.fileUri;
          }
          soundsByTag.sounds.push(audio);
          this.soundList.push(soundsByTag);
        }
      });
    }

    this.selectedSoundList = this.soundList[0].sounds;
  }

  handleStickerByTag(uiContext: UIContext, result: StickerResp[]) {
    // 先清空贴纸列表
    this.stickerList = [];
    result.forEach(item => {
      let tagStickers = this.stickerList.find(sticker => sticker.tag === item.tag);

      if (tagStickers) {
        let sticker = new Sticker();
        sticker.id = item.stickerId;
        sticker.uri = Util.handleImgUrl(uiContext, item.source);

        tagStickers.stickers.push(sticker);
      } else {
        let stickersByTag: StickersByTag = new StickersByTag();
        stickersByTag.tag = item.tag;

        let sticker = new Sticker();
        sticker.id = item.stickerId;
        sticker.uri = Util.handleImgUrl(uiContext, item.source);

        stickersByTag.stickers.push(sticker);

        this.stickerList.push(stickersByTag);
      }
    });
    // 初始化贴纸
    this.selectedStickerList = this.stickerList[0].stickers;
  }

  // 获取视频时长
  async getDuration(uiContext: UIContext): Promise<number> {
    try {
      this.newDuration = sdk.GetOriginalDuration();
      if (this.newDuration <= 0) {
        uiContext.getPromptAction().showToast({ message: '获取视频时长失败，请重试' });
        UtilLog.error(0xFF00, 'VideoClip', `获取视频时长失败: ${this.newDuration}`);
        this.durationError = 1;
      } else {
        this.durationError = 0;
      }
      return isNaN(this.newDuration) ? 0 : this.newDuration;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      UtilLog.error(0xFF00, 'VideoClip', `获取视频时长失败: ${err.code}, ${err.message}`);
      return 0;
    }
  }


  async getVideoSizeByUri(uri: string, context: Context) {
    try {
      let videoAsset = await Util.getVideoAsset(uri, context);

      if (videoAsset) {
        // 提取文件大小
        const fileSize = videoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
        const duration = videoAsset.get(photoAccessHelper.PhotoKeys.DURATION) as number;
        this.draft.size = VideoUtil.formatFileSize(fileSize);
        this.draft.duration = VideoUtil.formatMillisecondsToHMS(duration);
      }
    } catch (error) {
      UtilLog.error(0xFF00, 'VideoClip', `查询视频大小错误：${error.code}, ${error.message}`);
    }
  }

  // 获取缩略图
  async fetchFrameByTime(uiContext: UIContext) {
    let avImageGenerator: media.AVImageGenerator | null = null;
    try {
      avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = fs.openSync(this.params.videoUri);
      this.newDuration = await this.getDuration(uiContext);
      this.curDuration = this.newDuration - this.curTrimInValue - this.curTrimOutValue;
      UtilLog.info(0xFF00, 'VideoClip', `newDuration: ${this.newDuration}`);
      const interval = this.newDuration / 6;
      for (let j = 0; j < 6; j++) {
        this.timeUs[j] = j * interval;
      }
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_PREVIOUS_SYNC;
      let param: media.PixelMapParams = {
        // 保证清晰度
        width: 144,
        height: 144,
      };
      for (let i = 0; i < this.timeUs.length; i++) {
        this.pixelMaps[i] = await avImageGenerator.fetchFrameByTime(this.timeUs[i], queryOption, param);
        UtilLog.info(0xFF00, 'VideoClip', `缩略图获取中时间, + 十等分时间戳${this.timeUs[i]}`);
      }
      avImageGenerator.release();
    } catch (err) {
      UtilLog.error(0xFF00, 'VideoClip', `FetchFrameByTime errCode is ${err.code}, message is ${err.message}`);
    } finally {
      fs.closeSync(avImageGenerator?.fdSrc?.fd);
    }
  }

  // 切换修剪类型
  changeTrimType(isLeft: boolean) {
    this.trimType = isLeft ? TrimType.DragLeftBar : TrimType.DragRightBar;
  }

  // 转换位置为时间
  toTime(vp: number, roundValue = true): number {
    return roundValue ? Math.round(vp / 1) : vp / 1;
  }

  // 删除指定贴纸
  deleteSticker(id: string) {
    this.stickers = this.stickers.filter(sticker => sticker.id !== id);
    if (this.selectedStickerId === id) {
      sdk.RemoveImage(id);
    }
  }

  // 选择贴纸
  selectStickerById(id: string) {
    this.stickers.forEach(sticker => {
      sticker.isSelected = false;
    });
    let selectedSticker = this.stickers.find(sticker => sticker.id === id);
    if (selectedSticker) {
      selectedSticker.isSelected = true;
      this.selectedStickerId = id;
    }
  }

  async savePixelMapToCache(context: Context, pixelMap: PixelMap) {
    try {
      this.videoThumbNailUri =
        fileUri.getUriFromPath(context.filesDir + `/${Date.now().toString()}.png`);
      let file = await fileIo.open(this.videoThumbNailUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      await imagePackerApi.packToFile(pixelMap, file.fd, packOpts);
      this.draft.previewUri = this.videoThumbNailUri;
      imagePackerApi.release().then(() => {
        fileIo.close(file.fd);
      }).catch((err: BusinessError) => {
        UtilLog.error(`Failed to release the image source instance.code ${err.code},message is ${err.message}`);
      });
    } catch (err) {
      UtilLog.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
    }
  }

  async saveFile(uiContext: UIContext) {
    try {
      let context = uiContext.getHostContext();
      // 选取剪辑后开始时间最近帧为封面
      let filePath = 'file://' + this.totalOutputVideoFilePath;
      this.draft = {
        videoId: Date.now().toString(),
        videoUri: filePath,
        duration: VideoUtil.formatUsToMinSec(this.curDuration),
        previewUri: this.videoThumbNailUri,
        size: this.fileSize,
        mediaUri: '',
        isSelect: false,
      };
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let assetChangeHelper: photoAccessHelper.MediaAssetChangeRequest =
        photoAccessHelper.MediaAssetChangeRequest.createVideoAssetRequest(context, filePath);
      await phAccessHelper.applyChanges(assetChangeHelper);
      let asset: photoAccessHelper.PhotoAsset = assetChangeHelper.getAsset();
      const pixelMap = await asset.getThumbnail();
      await this.savePixelMapToCache(uiContext.getHostContext()!, pixelMap);
      this.draft.mediaUri = asset.uri;
    } catch (error) {
      UtilLog.error(0xFF00, 'VideoClip', `导出失败: ${error}`);
    }
  }

  async downloadAndCacheFile(uiContext: UIContext, item: AudioInfo) {
    let context = uiContext.getHostContext() as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    let dirPath = cacheDir + '/sound';
    fs.mkdir(dirPath).then(() => {
      let filePath = dirPath + '/' + item.name;
      this.downloadFile(uiContext, filePath, item);
    }).catch((err: BusinessError) => {
      let filePath = dirPath + '/' + item.name;
      this.downloadFile(uiContext, filePath, item);
    });
  }

  async applyBgSound(uiContext: UIContext, item: AudioInfo) {
    if (!item.isCached) {
      await this.downloadAndCacheFile(uiContext, item);
    } else {
      // 重新打开
      let fileDescriptor = fs.openSync(item.fileUri);
      item.fd = fileDescriptor.fd;
      UtilLog.info(0xFF00, 'VideoClip', `file fd reopen is ${item.fd}`);
      this.bgSoundFd.push(item.fd);
      sdk.SetBgAudio(item.fileUri, item.fd);
      this.selectedAudio = item;
    }
  }

  downloadFile(uiContext: UIContext, filePath: string, item: AudioInfo) {
    try {
      // 判断是否已下载过文件
      let res = fs.accessSync(filePath);
      if (res) {
        uiContext.getPromptAction().showToast({
          message: '该音频已下载，您可以直接使用',
        });
        this.uri = fileUri.getUriFromPath(filePath);
      } else {
        // 下载文件
        request.downloadFile(uiContext.getHostContext() as common.UIAbilityContext, {
          url: item.uri,
          filePath: filePath,
        }).then((downloadTask: request.DownloadTask) => {
          let progressCallback = (receivedSize: number, totalSize: number) => {
            item.progress = Math.floor((receivedSize / totalSize) * 100);
          };
          downloadTask.on('progress', progressCallback);
          // 开启回调
          downloadTask.on('complete', async () => {
            this.uri = fileUri.getUriFromPath(filePath);
            let downloadSound = new DownloadSound();
            downloadSound.name = item.name;
            downloadSound.fileUri = this.uri;
            this.downloadSoundList.list.push(downloadSound);
            PersistenceV2.save(DownloadSoundList);
            let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
            item.isCached = true;
            item.fileUri = this.uri;
            try {
              let fileDescriptor = fs.openSync(item.fileUri);
              item.fd = fileDescriptor.fd;
              this.bgSoundFd.push(item.fd);
              avMetadataExtractor.fdSrc = fileDescriptor;
            } catch (error) {
              UtilLog.info(0xFF00, 'VideoClip', `open file error : ${error}`);
            }
          });
        }).catch((err: BusinessError) => {
          // 下载请求失败回调，可以弹窗提示失败
          if (err.code === 13900015) {
            UtilLog.info(0xFF00, 'VideoClip', '目录已存在');
          } else {
            UtilLog.error(0xFF00, 'VideoClip', JSON.stringify(err));
          }
        });
      }
    } catch (error) {
      // 下载请求失败回调，可以弹窗提示失败
      let err: BusinessError = error as BusinessError;
      UtilLog.error(0xFF00, 'VideoClip',
        `Invoke downloadTask downloadFile failed====, code is ${err.code}, message is ${err.message}`);
    }
  }

  downloadSticker(filePath: string, sticker: Sticker, uiContext: UIContext) {
    try {
      // 判断是否已下载过文件
      let res = fs.accessSync(filePath);
      if (res) {
        UtilLog.info(0xFF00, 'VideoClip', '该贴纸文件已下载');
        this.imgUri = fileUri.getUriFromPath(filePath);
      } else {
        // 下载文件
        request.downloadFile(uiContext.getHostContext() as common.UIAbilityContext, {
          url: sticker.uri,
          filePath: filePath,
        }).then((downloadTask: request.DownloadTask) => {
          downloadTask.on('complete', async () => {
            this.imgUri = fileUri.getUriFromPath(filePath);
          });
        }).catch((err: BusinessError) => {
          // 下载请求失败回调，可以弹窗提示失败
          if (err.code === 13900015) {
            UtilLog.info(0xFF00, 'VideoClip', '目录已存在');
          } else {
            UtilLog.error(0xFF00, 'VideoClip', JSON.stringify(err));
          }
        });
      }
    } catch (error) {
      // 下载请求失败回调，可以弹窗提示失败
      let err: BusinessError = error as BusinessError;
      UtilLog.error(0xFF00, 'VideoClip',
        `Invoke downloadTask downloadFile failed====, code is ${err.code}, message is ${err.message}`);
    }
  }

  cacheSticker(sticker: Sticker, uiContext: UIContext) {
    let context = uiContext.getHostContext() as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    let dirPath = cacheDir + '/sticker';
    fs.mkdir(dirPath).then(() => {
      let filePath = dirPath + '/' + sticker.id;
      this.downloadSticker(filePath, sticker, uiContext);
    }).catch((err: BusinessError) => {
      UtilLog.info(0xFF00, 'VideoClip', `创建贴纸目录失败：${JSON.stringify(err)}`);
      let filePath = dirPath + '/' + sticker.id;
      this.downloadSticker(filePath, sticker, uiContext);
    });
  }

  async share(uiContext: UIContext) {
    let filePath = this.totalOutputVideoFilePath;
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.mp4', utd.UniformDataType.VIDEO);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: this.draft.videoId,
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      UtilLog.error(0xFF00, 'VideoClip', `ShareController show success`);
    }).catch((error: BusinessError) => {
      UtilLog.error(0xFF00, 'VideoClip',
        `ShareController show error. code: ${error?.code}, message: ${error?.message}`);
    });
  }
}