import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { camera, cameraPicker as picker } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { sceneMap } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MoreTypeItem } from '../model/MoreTypeItem'
import { ChatInputSendMessageModel } from '../model/ChatInputSendMessageModel';
import { SpeechRecognizer } from '../utils/SpeechRecognizer';
import { AudioRecorder } from '../utils/AudioRecorder';
import { ChatTypeEnum } from 'chat_base';

const DOMAIN: number = 0x0000
const TAG: string = 'ChatInputComponentViewModel'

@ObservedV2
export class ChatInputComponentViewModel {
  // 是否语音模式
  @Trace isVoiceMode: boolean = false
  // 显示模式
  @Trace showMode: InputShowMode = InputShowMode.DEFAULT
  // 编辑内容
  @Trace editContent: string = ''
  // 展示索引
  @Trace currentTabIndex: number = 0
  // 弹出框id
  dialodId: number = -1
  // 定时器id
  timerId: number = 10;
  // 音频路径
  audioPath: string = ''
  // 音频转换文本
  audioText: string = ''
  // 语音录制
  audioRecorder?: AudioRecorder
  // 常按中
  isLongPressing: boolean = false
  // 更多选择类型列表
  moreTypeItems: MoreTypeItem[] = [
    { title: '照片', source: $r('app.media.album_icon') },
    { title: '拍照', source: $r('app.media.take_photo_icon') },
    { title: '位置', source: $r('app.media.position_icon') }
  ]
  // 录音
  speechRecognizer: SpeechRecognizer = new SpeechRecognizer();

  // 初始化引擎，获取权限
  public initEngine(cotnent: string) {
    this.editContent = cotnent
    this.speechRecognizer.intiEngine()
  }

  // 开始识别
  public startSpeechRecognizer(context: common.UIAbilityContext, callback: (size: number, duration: number) => void) {
    this.audioPath = context.cacheDir + `/${Date.now()}.pcm`;
    this.audioText = ''
    this.audioRecorder = new AudioRecorder(callback)
    this.speechRecognizer.start((result) => {
      hilog.info(DOMAIN, TAG, '%{public}s', 'result=' + result.result)
      if (result.isFinal) {
        this.audioText += result.result
        hilog.info(DOMAIN, TAG, '%{public}s', 'isFinal=' + this.audioText)
      }
    });
  }

  // 选择图片
  public selectPhoto(context: Context): Promise<string> {
    return new Promise((resolve, reject) => {
      // 使用photoAccessHelper选择指定的文件
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 过滤选择媒体文件类型为IMAGE_VIDEO_TYPE
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (photoSelectResult.photoUris.length === 0) {
          reject('not selected')
          return
        }
        const selectedUri = photoSelectResult.photoUris[0]
        // 解决中文文件名乱码
        const fileUri = decodeURIComponent(selectedUri)
        let fileName = fileUri.split('/').pop() as string;
        let fileType: string = fileName.split('.')[fileName.split('.').length - 1];
        // 时间戳
        let timestamp: string = Date.now().toString()
        const cacheFile =
          context.cacheDir + '/' + fileName.split(`.${fileType}`)[0] + '_' + timestamp + '.' +
            fileType;
        this.copyFile(selectedUri, cacheFile).then((isSuccess: boolean) => {
          resolve(isSuccess ? cacheFile : selectedUri)
        }).catch(() => {
          reject(selectedUri)
        })
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }

  // 拍照
  async takePhoto(context: Context, filePath: string): Promise<picker.PickerResult> {
    fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);

    let uri = fileUri.getUriFromPath(filePath);
    let pickerProfile: picker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
      saveUri: uri,
      videoDuration: 60
    };

    let result: picker.PickerResult =
      await picker.pick(context, [picker.PickerMediaType.PHOTO, picker.PickerMediaType.VIDEO],
        pickerProfile);
    return result;
  }

  // 获取图片文件信息（尺寸+大小）
  async getImageInfo(filePath: string): Promise<ChatInputSendMessageModel> {
    let imageInfo: image.ImageInfo | undefined;
    // 获取文件大小
    const stat = await fs.stat(filePath);
    try {
      // 解析图片尺寸
      const imageSource = image.createImageSource(filePath);
      imageInfo = await imageSource.getImageInfo();
    } catch (err) {
    }

    const msgModel: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_IMAGE)
    msgModel.width = imageInfo?.size.width ?? 0
    msgModel.height = imageInfo?.size.height ?? 0
    msgModel.size = stat.size
    msgModel.pictureUrl = filePath

    return msgModel
  }

  // 获取视频文件信息（尺寸+大小+时长）
  async getVideoInfo(context: UIContext, filePath: string): Promise<ChatInputSendMessageModel | undefined> {
    // 1. 获取文件大小
    const stat = await fs.stat(filePath);

    // 截图首帧封面
    let snapshotPath: string = ''
    let fileId: number | fs.File | undefined;
    let fileInfo: number | fs.File | undefined;
    let metadata: media.AVMetadata | undefined
    try {
      // 创建 AVMetadataExtractor 实例
      let avMetadataExtractor = await media.createAVMetadataExtractor();
      fileInfo = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      avMetadataExtractor.fdSrc = { fd: fileInfo.fd }; // 文件描述符
      // 提取元数据
      metadata = await avMetadataExtractor.fetchMetadata();

      let duration = metadata.duration ?? 0;
      if (duration > 60 * 10 * 1000) {
        context.getPromptAction().showToast({ message: '视频时长超过十分钟，无法发送' });
        return undefined;
      }

      const videoWidth: number = parseInt(metadata.videoWidth as string);
      const videoHeight: number = parseInt(metadata.videoHeight as string);

      // 获取首帧
      const avFileDescriptor: media.AVFileDescriptor = { fd: fileInfo.fd };
      const avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = avFileDescriptor;
      const params: media.PixelMapParams = { width: videoWidth, height: videoHeight };
      const pixelMap = await avImageGenerator.fetchFrameByTime(
        0,
        media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC,
        params
      );
      avImageGenerator.release();

      // 存储
      const imagePacker = image.createImagePacker();
      const imageBuffer = await imagePacker.packToData(pixelMap, {
        format: 'image/png',
        quality: 100
      });
      let desPath: string = filePath.split('.')[0] + '_snapshot.png'
      const mode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
      fileId = fs.openSync(desPath, mode).fd;
      fs.truncateSync(fileId);
      fs.writeSync(fileId, imageBuffer);
      snapshotPath = desPath
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s', `Error: ${(error as BusinessError).message}`);
    } finally {
      fs.close(fileInfo)
      fs.close(fileId);
    }
    // 获取时长（单位：毫秒）和尺寸
    const msgModel: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_VIDEO)
    msgModel.width = parseInt(metadata?.videoWidth as string);
    msgModel.height = parseInt(metadata?.videoHeight as string)
    msgModel.duration = parseInt(metadata?.duration as string)
    msgModel.mimeType = metadata?.mimeType ?? 'mp4'
    msgModel.size = stat.size
    msgModel.videoUrl = filePath
    msgModel.snapshotPath = snapshotPath

    return msgModel
  }

  // 获取地理位置信息
  getLocationInfo(result: sceneMap.LocationChoosingResult) {
    const msgModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_LOCATION)
    msgModel.locationName = result.name ?? result.address;
    msgModel.locationDesc = result.address;
    msgModel.locationLongitude = result.location.longitude;
    msgModel.locationLatitude = result.location.latitude;
    return msgModel;
  }

  // 复制文件到本地
  private copyFile(srcPath: string, dstPath: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let srcFile: fs.File | null = null;
      let dstFile: fs.File | null = null;
      try {
        srcFile = fs.openSync(srcPath);
        dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        // 读取文件的第一个字节
        const buffer = new ArrayBuffer(1); // 申请1字节缓冲区
        const readLen = fs.readSync(srcFile.fd, buffer); // 读取首字节
        // 读取长度为0即文件为空
        if (readLen === 0) {
          resolve(false)
          return;
        }
        fs.copyFileSync(srcFile.fd, dstFile.fd);
        resolve(true)
      } catch (e) {
        reject(e);
      } finally {
        if (srcFile) {
          fs.closeSync(srcFile);
        }
        if (dstFile) {
          fs.closeSync(dstFile);
        }
      }
    })
  }

  // 获取文件类型
  public getFileType(filePath: string): ChatTypeEnum {
    let msgType: ChatTypeEnum = ChatTypeEnum.CHAT_TYPE_NONE;
    const tmpList: string[] = filePath.split('.')
    const fileType: string = tmpList[tmpList.length - 1];
    switch (fileType.toLowerCase()) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
      case 'ico':
      case 'psd':
      case 'ai':
      case 'eps':
      case 'raw':
      case 'tif':
      case 'tiff':
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp': {
        msgType = ChatTypeEnum.CHAT_TYPE_IMAGE
      }
        break
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'flv':
      case 'wmv':
      case 'webm': {
        msgType = ChatTypeEnum.CHAT_TYPE_VIDEO
      }
        break
      default:
        break;
    }
    return msgType;
  }

  // 删除文字最后一位，需要考虑表情
  deleteTextLastOne() {
    const length: number = this.editContent.length
    if (length === 0) {
      return
    }

    let deleteCount: number = 1
    if (length > 1) {
      const c = this.editContent.charAt(length - 2);
      // 判断是否为代理对（Emoji）
      if (c >= '\uD800' && c <= '\uDBFF') {
        deleteCount = 2
      }
    }

    this.editContent = this.editContent.substring(0, length - deleteCount)
  }
}

/**
 * 消息类型
 */
export enum InputShowMode {
  /**
   * 默认
   */
  DEFAULT = 0,
  /**
   * 表情
   */
  EMOJI = 1,
  /**
   * 文件
   */
  FILE = 2,
}


