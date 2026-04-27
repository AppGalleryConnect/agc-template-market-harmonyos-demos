/**
 * @usage: 发布帖子/足迹页面，支持添加标题、正文、图片/视频、地点、话题，提供拍照、拍视频、从相册选择等媒体添加方式
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，中间是输入区域（标题、正文、媒体、地点、话题），
 * 底部是发布按钮
 * @constraints: 图片和视频互斥，已有图片不能添加视频，已有视频不能添加图片；视频文件大小不能超过500MB；
 * 发布需要填写标题、正文、地点和媒体
 * @isGen: true
 * @fileType: page
 * @zhName: 发布帖子
 * @domain: 旅游
 * @image: screenshots/person/PublishPost.jpg
 * @subPage: CitySelectPage
 * @component: CommonHeader
 */
import { AppStorageV2, AlertDialog } from '@kit.ArkUI';
import { City } from 'city_select';
import { CommonHeader, GlobalContext, PermissionUtil, RouterMap, TValueType } from 'common';
import { PostInfo, MyPostList } from 'common_travel_guide';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { PublishPageType } from '../constants/PostPageType';

@Builder
export function PublishPostPageBuilder(param: TValueType) {
  PublishPostPage({
    pageParam: param
  });
}

@ComponentV2
export struct PublishPostPage {
  @Param pageParam: TValueType = null
  @Local publishPageType: PublishPageType = this.pageParam as PublishPageType
  @Local data: PostInfo = new PostInfo('', '', '', '')
  @Local postList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
  @Local showMediaSelectSheet: boolean = false
  // 定义UIContext上下文
  private ctx: UIContext = GlobalContext.getUIContext();
  // 定义媒体类型常量
  private readonly MEDIA_TYPE_PHOTO: string = 'photo';
  private readonly MEDIA_TYPE_VIDEO: string = 'video';

  @Computed
  get allowPost(): boolean {
    return Boolean(
      this.data.title &&
      this.data.content &&
      this.data.publishLocation &&
        // 视频和图片二选一
        (this.data.videoUrl || this.data.imgVideoList?.length > 0)
    );
  }

  private pageInfo: OHPageConfig = new OHPageConfig({
    onBackPress: (): boolean => {
      this.confirmExitDialog?.open();
      return true;
    }
  })

  // 从相册里面选择照片/视频
  async pickMediaFromAlbum(): Promise<void> {
    try {
      // 根据当前已有媒体类型限制可选择的媒体类型
      let allowedMediaType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      if (this.data.imgVideoList.length > 0) {
        // 已有图片，只能选择图片
        allowedMediaType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      } else if (this.data.videoUrl) {
        // 已有视频，只能选择视频
        allowedMediaType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
      }

      // 创建PhotoViewPicker实例，用于获取媒体类型信息
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const options: photoAccessHelper.PhotoSelectOptions = {
        isEditSupported: true,
        isOriginalSupported: true,
        completeButtonText: photoAccessHelper.CompleteButtonText.TEXT_DONE,
        MIMEType: allowedMediaType,
        maxSelectNumber: 1,
        isPreviewForSingleSelectionSupported: true
      }

      // 选择媒体文件
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options)
      if (result.photoUris && result.photoUris.length > 0) {
        const abilityCtx: common.UIAbilityContext = this.ctx.getHostContext() as common.UIAbilityContext
        let url: string = result.photoUris[0]
        let file: fs.File | null = null
        let arrayBuffer: ArrayBuffer
        try {
          file = fs.openSync(url, fs.OpenMode.READ_ONLY)
          let stat = fs.statSync(file.fd);

          // 判断文件大小：如果是视频且大于500MB，则提示并返回
          const extension = url.substring(url.lastIndexOf('.')).toLowerCase()
          const isVideo = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv'].includes(extension)

          // 将字节转换为MB
          const fileSizeMB = stat.size / (1024 * 1024)
          if (isVideo && fileSizeMB > 500) {
            this.ctx.getPromptAction().showToast({
              message: '视频文件大小不能超过500MB'
            })
            return
          }

          arrayBuffer = new ArrayBuffer(stat.size);
          fs.readSync(file.fd, arrayBuffer);
          // 根据文件扩展名判断媒体类型
          const isImage = ['.jpg', '.jpeg', '.png', '.gif'].includes(extension)
          const mimeType = isImage ? 'image/png' : 'video/mp4'

          // 根据MIME类型确定文件扩展名
          const fileExtension = mimeType.startsWith('image/') ? '.png' : '.mp4'
          const newPath: string = abilityCtx.cacheDir + '/' + util.generateRandomUUID(false) + fileExtension
          fs.copyFileSync(file.fd, newPath)
          url = 'file://' + newPath

          // 根据媒体类型添加到对应的属性
          if (mimeType.startsWith('image/')) {
            // 将图片添加到data.imgVideoList
            this.data.imgVideoList.unshift(url)
            this.data.coverImg = url
          } else {
            // 获取视频封面
            const pixelMap = await this.imageGeneratorGetThumbnail(url);
            // 保存到沙箱目录
            if (pixelMap && typeof pixelMap !== 'string') {
              // 视频封面设置到data.coverImg
              this.data.coverImg = await this.saveScreenshot(this.ctx, pixelMap);
            }
            // 视频路径设置到data.videoUrl
            this.data.videoUrl = url
          }
        } catch (e) {
          this.ctx.getPromptAction().showToast({ message: '选择照片/视频失败' })
        } finally {
          if (file) {
            fs.closeSync(file)
          }
        }
      }
    } catch (e) {
      this.ctx.getPromptAction().showToast({ message: '选择失败' })
    }
  }

  // 拉起相机拍照/拍视频
  async takeMediaByCamera(mediaType: string): Promise<void> {
    try {
      // 检查媒体类型互斥
      if (mediaType === this.MEDIA_TYPE_PHOTO && this.data.videoUrl) {
        this.ctx.getPromptAction().showToast({ message: '已有视频，不能再拍照' })
        return
      }
      if (mediaType === this.MEDIA_TYPE_VIDEO && this.data.imgVideoList.length > 0) {
        this.ctx.getPromptAction().showToast({ message: '已有图片，不能再拍视频' })
        return
      }

      const granted = await PermissionUtil.checkPermissions('ohos.permission.CAMERA')
      if (!granted) {
        this.ctx.getPromptAction().showToast({ message: '请授权拉起相机' })
        return
      }

      // 使用CameraPicker直接调用相机拍照或拍视频
      const abilityCtx: common.UIAbilityContext = this.ctx.getHostContext() as common.UIAbilityContext
      const timestamp = new Date().getTime();
      const fileExtension = mediaType === this.MEDIA_TYPE_PHOTO ? '.jpg' : '.mp4';
      const fileName = `post_${timestamp}${fileExtension}`;
      const filePath = abilityCtx.filesDir + '/' + fileName

      // 创建临时文件
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE)
      const uri = fileUri.getUriFromPath(filePath)

      // 配置相机选择器
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK, // 使用后置摄像头
        saveUri: uri
      }

      // 根据媒体类型选择对应的PickerMediaType
      const pickerMediaType = mediaType === this.MEDIA_TYPE_PHOTO
        ? cameraPicker.PickerMediaType.PHOTO
        : cameraPicker.PickerMediaType.VIDEO;

      // 调用相机拍照或拍视频
      const result: cameraPicker.PickerResult = await cameraPicker.pick(
        getContext(),
        [pickerMediaType],
        pickerProfile
      )

      if (result.resultCode === 0 && result.mediaType === pickerMediaType) {
        let url: string = result.resultUri
        let file: fs.File | null = null
        let arrayBuffer: ArrayBuffer

        try {
          file = fs.openSync(url, fs.OpenMode.READ_ONLY)
          const stat = fs.statSync(file.fd)

          // 判断文件大小：如果是视频且大于500MB，则提示并返回
          const extension = url.substring(url.lastIndexOf('.')).toLowerCase()
          const isVideo = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv'].includes(extension)

          // 将字节转换为MB
          const fileSizeMB = stat.size / (1024 * 1024)
          if (isVideo && fileSizeMB > 500) {
            this.ctx.getPromptAction().showToast({
              message: '视频文件大小不能超过500MB'
            })
            return
          }

          arrayBuffer = new ArrayBuffer(stat.size)
          fs.readSync(file.fd, arrayBuffer)

          // 根据媒体类型添加到对应的属性
          if (mediaType === this.MEDIA_TYPE_PHOTO) {
            // 图片添加到data.imgVideoList
            this.data.imgVideoList.unshift(url)
            this.data.coverImg = url
          } else {
            // 获取视频封面
            const pixelMap = await this.imageGeneratorGetThumbnail(url);
            // 保存到沙箱目录
            if (pixelMap && typeof pixelMap !== 'string') {
              // 视频封面设置到data.coverImg
              this.data.coverImg = await this.saveScreenshot(this.ctx, pixelMap);
            }
            // 视频路径设置到data.videoUrl
            this.data.videoUrl = url
          }
        } catch (e) {
          this.ctx.getPromptAction().showToast({ message: '调用相机失败' })
        } finally {
          if (file) {
            fs.closeSync(file)
          }
        }
      }
    } catch (e) {
      this.ctx.getPromptAction().showToast({ message: '调用相机失败' })
    }
  }

  // 获取视频封面图
  async imageGeneratorGetThumbnail(videoPath: string): Promise<image.PixelMap | string> {
    let avImageGenerator: media.AVImageGenerator | undefined;
    let fileDescriptorForGenerator: number | undefined;
    let fileDescriptorForExtractor: number | undefined;
    let avMetadataExtractor: media.AVMetadataExtractor | undefined
    this.data.coverImg = ''

    try {
      // 为不同组件创建独立的文件描述符，避免资源冲突
      const fileForGenerator = fs.openSync(videoPath, fs.OpenMode.READ_ONLY);
      fileDescriptorForGenerator = fileForGenerator.fd;

      const fileForExtractor = fs.openSync(videoPath, fs.OpenMode.READ_ONLY);
      fileDescriptorForExtractor = fileForExtractor.fd;

      // 创建AVImageGenerator实例
      avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = { fd: fileDescriptorForGenerator };

      // 获取视频元数据
      avMetadataExtractor = await media.createAVMetadataExtractor();
      avMetadataExtractor.fdSrc = { fd: fileDescriptorForExtractor };
      let videoMetaData = await avMetadataExtractor.fetchMetadata();

      // 计算合适的缩略图尺寸，避免大视频导致内存不足
      let videoWidth = videoMetaData.videoWidth;
      let videoHeight = videoMetaData.videoHeight;
      let width = Number(videoWidth);
      let height = Number(videoHeight);

      const timeUs = 0
      const queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      const param: media.PixelMapParams = {
        width: width,
        height: height
      };

      const pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);
      return pixelMap;
    } catch (error) {
      return ''
    } finally {
      // 释放AVImageGenerator
      if (avImageGenerator) {
        await avImageGenerator.release();
      }

      // 释放AVMetadataExtractor
      if (avMetadataExtractor) {
        await avMetadataExtractor.release();
      }

      // 关闭文件描述符
      if (fileDescriptorForGenerator !== undefined) {
        fs.closeSync(fileDescriptorForGenerator);
      }

      if (fileDescriptorForExtractor !== undefined) {
        fs.closeSync(fileDescriptorForExtractor);
      }
    }
  }

  // 把PixelMap保存成图片存到沙盒路径
  async saveScreenshot(mContext: UIContext, pixelMap: image.PixelMap | string): Promise<string> {
    if (typeof pixelMap === 'string') {
      return pixelMap
    }

    const abilityCtx = mContext.getHostContext() as common.UIAbilityContext;
    if (!abilityCtx) {
      pixelMap.release(); // 释放资源
      return '';
    }

    const baseDir = abilityCtx.cacheDir;
    if (!baseDir) {
      pixelMap.release(); // 释放资源
      return '';
    }

    let fileName = new Date().getTime().toString()
    let targetPath: string = ''
    let file: fs.File | null = null;
    try {
      let imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 90 }; // 可选择格式和质量
      // 保存文件到沙箱环境
      const imgBuffer: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      const tempDir = baseDir
      targetPath = tempDir + '/' + fileName + '.png'; // 文件保存路径
      file = await fs.open(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      await fs.write(file.fd, imgBuffer);
      await fs.close(file.fd);
    } catch (error) {
      if (fs.accessSync(targetPath)) {
        fs.unlinkSync(targetPath);
      }
    }finally {
      fs.close(file).catch(() => {
      })
    }
    return `file://${targetPath}`
  }

  // 发布帖子的方法
  private publishPost() {
    // 设置发布时间
    const now = new Date();
    this.data.publishTime = now.toLocaleDateString('sv-SE');

    // 调用添加方法
    try {
      this.postList.add(this.data);
      this.ctx.getPromptAction().showToast({ message: '发布成功' });
      // 发布成功后直接返回，不显示退出确认弹窗
      phoneRouterControl.popPage();
    } catch {
      this.ctx.getPromptAction().showToast({ message: '发布失败' });
    }
  }

  // 退出确认弹窗
  private confirmExitDialog: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '确定放弃发布吗？',
      content: '放弃后编辑的帖子不在保留',
      primaryButton: {
        value: '取消',
        fontColor: $r('sys.color.font_tertiary'),
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        fontColor: $r('sys.color.black'),
        action: () => {
          // 确认退出，执行页面返回操作
          phoneRouterControl.popPage();
          return true
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 32,
    width: 328,
  })

  // 媒体选择半模态窗
  @Builder
  mediaSelectBuilder() {
    Column() {
      Button('拍照')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.font_on_primary'))
        .enabled(this.data.videoUrl === '')
        .onClick(async () => {
          this.showMediaSelectSheet = false
          await this.takeMediaByCamera(this.MEDIA_TYPE_PHOTO);
        })
      Button('拍视频')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.font_on_primary'))
        .enabled(this.data.imgVideoList.length === 0)
        .onClick(async () => {
          this.showMediaSelectSheet = false
          await this.takeMediaByCamera(this.MEDIA_TYPE_VIDEO);
        })
      Button('从手机相册选择')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.font_on_primary'))
        .onClick(async () => {
          this.showMediaSelectSheet = false
          await this.pickMediaFromAlbum();
        })
      Button('取消')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_tertiary'))
        .backgroundColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          this.showMediaSelectSheet = false
        })
    }
    .width('100%')
    .padding({
      left: 0,
      right: 0,
      top: 8,
      bottom: 18
    })
    .backgroundColor($r('sys.color.font_on_primary'))
  }

  get mediaSelectSheetOptions() {
    return {
      height: SheetSize.FIT_CONTENT,
      showClose: false,
      preferType: SheetType.BOTTOM,
      backgroundColor: ($r('sys.color.background_primary')),
      onWillDisappear: () => {
        this.showMediaSelectSheet = false
      },
    } as SheetOptions
  }

  @Builder
  inputContent() {
    Column() {
      TextInput({ text: this.data.title, placeholder: '填写标题会有更多赞哦～' })
        .width('100%')
        .height(46)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .barState(BarState.Off)
        .onChange((value: string) => this.data.title = value)
        .borderRadius(0)
        .padding(0)
        .backgroundColor(Color.Transparent)
        .border({
          width: { bottom: 1 },
          color: { bottom: '#0F000000' }
        })
      TextArea({ text: this.data.content, placeholder: '美好的一天，写点什么吧...' })
        .width('100%')
        .height(132)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .padding({ right: 12, top: 15, left: 0 })
        .maxLength(1500)
        .showCounter(true)
        .barState(BarState.Off)
        .onChange((value: string) => this.data.content = value)
        .backgroundColor(Color.Transparent)
      this.mediaRow()
      this.locationRow()
      if (this.publishPageType === PublishPageType.POST) {
        this.topicRow()
      }

    }
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding({ left: 12, bottom: 10, right: 12 })
  }

  @Builder
  mediaRow() {
    Scroll() {
      Row({ space: 10 }) {
        if (this.data.imgVideoList.length < 9 && this.data.videoUrl === '') {
          Column() {
            Image($r('app.media.ic_camera'))
              .width(32)
              .height(32)
              .margin({ bottom: 4 })
            Text('图片/视频')
              .fontColor('#9E9E9E')
              .fontSize(10)
          }
          .width(78)
          .height(78)
          .backgroundColor('#F8F8F8')
          .align(Alignment.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(12)
          .onClick(() => {
            this.showMediaSelectSheet = true
          })
          .bindSheet(this.showMediaSelectSheet, this.mediaSelectBuilder(), this.mediaSelectSheetOptions)
        }

        if (this.data.videoUrl) {
          Image(this.data.coverImg)
            .width(78)
            .height(78)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)

          // 删除按钮
          Image($r('app.media.ic_delete'))
            .width(20)
            .height(20)
            .position({ right: 4, top: 4 })
            .onClick(() => {
              this.data.coverImg = '';
              this.data.videoUrl = '';
            })

          // 视频tag
          Text('视频')
            .fontSize(12)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.font_tertiary'))
            .padding({
              top: 2,
              bottom: 2,
              left: 4,
              right: 4
            })
            .borderRadius(12)
            .position({ left: 4, top: 4 })
        } else {
          ForEach(this.data.imgVideoList, (item: string, index: number) => {
            Stack() {
              Image(item)
                .width(78)
                .height(78)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)

              // 删除按钮
              Image($r('app.media.ic_delete'))
                .width(20)
                .height(20)
                .position({ right: 4, top: 4 })
                .onClick(() => {
                  this.data.imgVideoList.splice(index, 1);
                })
            }
          }, (item: string) => JSON.stringify(item))
        }
      }
    }
    .padding({ top: 10, bottom: 10 })
    .width('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .align(Alignment.Start)
  }

  @Builder
  locationRow() {
    Row() {
      Row({ space: 4 }) {
        Image($r('app.media.ic_locate'))
          .width(16)
          .height(16)
        Text('添加地点')
          .fontColor('#000')
          .fontSize(14)
        Text(this.data.publishLocation ? this.data.publishLocation : '(选择对应地点吧)')
          .fontColor(this.data.publishLocation ? '#000' : 'rgba(0, 0, 0, 0.30)')
          .fontSize(14)
      }

      Image($r('app.media.ic_right_arrow'))
        .width(20)
        .height(20)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ right: 12 })
    .height(46)
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CITY_SELECT_PAGE,
        onPop: (popInfo: PopInfo) => {
          let result = popInfo?.result as City;
          this.data.publishLocation = result.name
        },
        param: this.data.publishLocation
      })
    })
  }

  @Builder
  topicRow() {
    Row({ space: 16 }) {
      Row({ space: 4 }) {
        Image($r('app.media.ic_well'))
          .width(16)
          .height(16)
        Text('参与话题')
          .fontColor('#000')
          .fontSize(14)
      }

      TextInput({ text: this.data.postTopic, placeholder: '请输入话题' })
        .layoutWeight(1)
        .padding(0)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .onChange((value) => {
          this.data.postTopic = value
        })
    }
    .width('100%')
    .padding({ right: 12 })
    .height(46)
  }

  @Builder
  postButton() {
    Button('发布')
      .width('100%')
      .height(42)
      .backgroundColor('#FEE231')
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(500)
      .enabled(this.allowPost)
      .margin({ bottom: 12 })
      .borderRadius(25)
      .onClick(() => {
        this.publishPost()
      })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.publishPageType,
        onReturnClick: () => {
          this.confirmExitDialog?.open()
        },
      })
        .margin({ bottom: 12 })
      this.inputContent()
      Blank()
      this.postButton()
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
      pageConfig: this.pageInfo
    })
  }
}
