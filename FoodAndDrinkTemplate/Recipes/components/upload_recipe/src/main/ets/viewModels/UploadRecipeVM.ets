import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { RecipeIngredient, Step, VideoSizeData } from '../types/Index';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import fileIo from '@ohos.file.fs';
import { dataSharePredicates } from '@kit.ArkData';


const TAG = '[UploadRecipeVM]';

@ObservedV2
export class UploadRecipeVM {
  // 主图
  @Trace mainImg: string = '';
  // 标题
  @Trace title: string = ''
  // 最大长度
  @Trace maxLength: number = 200
  // 当前长度
  @Trace curLength: number = 0
  // 描述
  @Trace description: string = ''
  // 用料
  @Trace ingredients: RecipeIngredient[] = [{ name: '', quantity: '', unit: '' }]
  // 步骤
  @Trace steps: Step[] = [new Step('', '')]
  // 记录当前步骤
  @Trace curStep: number = 1
  @Trace isMovingPhoto: boolean = false;
  @Trace video: string = '';

  public clearData() {
    this.title = ''
    this.curLength = 0
    this.description = ''
    this.mainImg = ''
    this.curStep = 1
    this.ingredients = [{ name: '', quantity: '', unit: '' }]
    this.steps = [new Step('', '')]
  }

  isStepsEmpty(): boolean {
    let isEmpty: boolean = false
    this.steps.forEach((val) => {
      if (!val.description || !val.stepImg) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isIngredientsEmpty(): boolean {
    let isEmpty: boolean = false
    this.ingredients.forEach((val) => {
      if (!val.name || !val.quantity) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isUploadValid(): boolean {
    if (!this.title) {
      promptAction.showToast({ message: '请填写标题！' });
      return false
    }
    if (!this.mainImg) {
      promptAction.showToast({ message: '请上传媒体文件！' });
      return false
    }
    if (!this.description) {
      promptAction.showToast({ message: '请补充描述！' });
      return false
    }
    if (this.isIngredientsEmpty()) {
      promptAction.showToast({ message: '请补充用料名称、数量！' });
      return false
    }
    if (this.isStepsEmpty()) {
      promptAction.showToast({ message: '请完善步骤！' });
      return false
    }

    return true
  }


  // 获取图片,moving photo,视频
  public async selectImage(context: common.UIAbilityContext, type: number): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        if(type && type === 1) {
          photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
        }
        photoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new photoAccessHelper.PhotoViewPicker();
        photoPicker.select(photoSelectOptions).then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          let uris = photoSelectResult.photoUris;
          // 获取uri对应的PhotoAsset资产。
          let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
          predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uris[0]);
          let fetchOption: photoAccessHelper.FetchOptions = {
            fetchColumns: [],
            predicates: predicates
          };
          let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
            await phAccessHelper.getAssets(fetchOption);
          let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
          //判断文件主类型
          let mainType = photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_TYPE);
          //判断文件子类型
          let subType = photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE);
          if(mainType === 1 && subType === 3){
            // moving photo处理
            await this.handleMovingPhoto(context, photoAsset, resolve);
          } else {
            await this.handleRegularMedia(context, photoSelectResult, resolve, reject);
          }
        }).catch((err: BusinessError) => {
          reject(err);
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        reject(err);
      }
    });
  }

  private async handleMovingPhoto(
    context: common.UIAbilityContext,
    photoAsset: photoAccessHelper.PhotoAsset,
    resolve: (value: string) => void
  ): Promise<void> {
    await photoAccessHelper.MediaAssetManager.requestMovingPhoto(
      context,
      photoAsset,
      {
        deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE
      },
      {
        async onDataPrepared(movingPhoto: photoAccessHelper.MovingPhoto) {
          if (!movingPhoto) {
            resolve('');
            return;
          }
          const imageFileUri: string = context.cacheDir + `/${util.generateRandomUUID(false)}.png`;
          const videoFileUri: string = context.cacheDir + `/${util.generateRandomUUID(false)}.mp4`;
          try {
            await movingPhoto.requestContent(imageFileUri, videoFileUri);
            resolve(imageFileUri + '&' + videoFileUri);
          } catch (err) {
            resolve('');
          }
        }
      }
    );
  }

  // 3. 处理普通媒体文件（图片/视频）
  private async handleRegularMedia(
    context: common.UIAbilityContext,
    photoSelectResult: photoAccessHelper.PhotoSelectResult,
    resolve: (value: string) => void,
    reject: (reason?: string) => void
  ): Promise<void> {
    let imgFile: fs.File | null = null;
    try {
      imgFile = fs.openSync(photoSelectResult.photoUris[0]!, fs.OpenMode.READ_ONLY);
      let newPath: string = '';
        if(photoSelectResult.photoUris[0].includes('.mp4')){
          newPath = context.cacheDir + `/${util.generateRandomUUID(false)}.mp4`;
        } else {
          newPath = context.cacheDir + `/${util.generateRandomUUID(false)}.png`;
        }
      fs.copyFileSync(imgFile.fd, newPath);
      resolve('file://' + newPath);
    } catch (err) {
      reject(JSON.stringify(err));
    } finally {
      if (imgFile) {
        fs.closeSync(imgFile);
      }
    }
  }

  /**
   * 获取视频缩略图
   * @param uri
   * @returns
   */
  public async getVideoThumbnail(uri: string): Promise<image.PixelMap | undefined> {
    if (!uri) {
      return undefined;
    }
    try {
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      const fileAlbum:fs.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const avFileDescriptor = { fd: fileAlbum.fd } as media.AVFileDescriptor;
      const videoSize: VideoSizeData = await this.getVideoData(avFileDescriptor);
      if (avImageGenerator) {
        avImageGenerator.fdSrc = avFileDescriptor;
      } else {
        return undefined;
      }
      const pixelMap = await avImageGenerator?.fetchFrameByTime(0,
        media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC, videoSize.photoSize);
      return pixelMap;
    } catch (e) {
      return undefined;
    }
  }

  /**
   * 获取视频信息
   * @param avFileDescriptor
   * @returns
   */
  public async getVideoData(avFileDescriptor: media.AVFileDescriptor): Promise<VideoSizeData> {
    let videoSize: VideoSizeData = new VideoSizeData();
    try {
      let avMetaDataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      avMetaDataExtractor.fdSrc = avFileDescriptor;
      let metadata = await avMetaDataExtractor.fetchMetadata();
      videoSize.photoSize.width = parseInt(metadata.videoWidth as string);
      videoSize.photoSize.height = parseInt(metadata.videoHeight as string);
      if (metadata.duration) {
        videoSize.totalTime = parseInt(metadata.duration);
      }
      await avMetaDataExtractor.release();
      return videoSize;
    } catch (e) {
      return videoSize;
    }
  }

  /**
   * pixelMap写入沙箱
   * @param pixelMap
   * @returns
   */
  public async writePixelMap(uiContext: UIContext, pixelMap?: image.PixelMap): Promise<string> {
    if (!pixelMap) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      const newPath: string = uiContext.getHostContext()?.cacheDir + `/${util.generateRandomUUID(false)}.png`;
      file = fs.openSync(newPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      let imagePacker: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      await imagePacker.packToFile(pixelMap, file.fd, packOpts);
      return 'file://' + newPath;
    } catch (e) {
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        console.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }

  public async showFile(res: string, uiContext: UIContext, type: number): Promise<string> {
    let mainImg = '';
    if(res.includes('&')) {
      mainImg = 'file://' + res.split('&')[0];
      if(type === 0) {
        this.video = 'file://' + res.split('&')[1];
        this.isMovingPhoto = true;
      }
    } else {
      if(type === 0) {
        this.isMovingPhoto = false;
      }
      if(res.includes('.png')){
        mainImg = res;
      } else {
        if(type === 0) {
          this.video = res;
        }
        const thumbnail = await this.getVideoThumbnail(res);
        const surfaceUrl = await this.writePixelMap(uiContext, thumbnail);
        mainImg = surfaceUrl;
      }
    }
    return mainImg;
  }
}