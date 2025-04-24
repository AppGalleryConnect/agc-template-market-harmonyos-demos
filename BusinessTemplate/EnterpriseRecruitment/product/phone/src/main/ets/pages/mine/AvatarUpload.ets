import { image } from '@kit.ImageKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import Matrix4 from '@ohos.matrix4';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';
import { AvoidArea, getCurrentLocalTime, UserInfo, User } from '@ohos_agcit/common_component';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@ComponentV2
export struct AvatarUpload {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local model: CropModel = new CropModel();

  build() {
    Column() {
      CropView({
        model: this.model,
      })
        .layoutWeight(1)
        .height('100%')
        .width('100%')
    }
  }
}

@ComponentV2
export struct CropView {
  @Param model: CropModel = new CropModel();
  @Local pm: PixelMap | undefined = undefined;
  @Local matrix: object = Matrix4.identity()
    .translate({ x: 0, y: 0 })
    .scale({ x: this.model.scale, y: this.model.scale });
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  /** 临时变量，无需手动赋值 **/
  private tempScale = 1;
  /** 临时变量，无需手动赋值 **/
  private startOffsetX: number = 0;
  /** 临时变量，无需手动赋值 **/
  private startOffsetY: number = 0;

  async openPicker() {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new picker.PhotoSelectOptions();
      // 限制只能选择一张图片
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      // 创建并实例化图片选择器
      const photoViewPicker = new picker.PhotoViewPicker();
      // 选择图片并获取图片URI
      let uris: picker.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions);
      if (!uris || uris.photoUris.length === 0) {
        return;
      }
      // 获取选中图片的第一张URI
      let uri: string = uris.photoUris[0];
      this.model.setImage(uri)
        .setFrameWidth(1000)
        .setFrameRatio(1);
    } catch (e) {
      console.error('openPicker', JSON.stringify(e));
    }
  }

  build() {
    Stack() {
      Image(this.model.src)
        .width('100%')
        .height('100%')
        .alt(this.model.previewSource)
        .objectFit(ImageFit.Contain)
        .transform(this.matrix)
        .onComplete((msg) => {
          if (msg) { // 图片加载成功
            this.model.imageWidth = msg.width;
            this.model.imageHeight = msg.height;
            this.model.componentWidth = msg.componentWidth;
            this.model.componentHeight = msg.componentHeight;
            this.checkImageAdapt();

            if (this.model.imageLoadEventListener !== null && msg.loadingStatus === 1) {
              this.model.imageLoadEventListener.onImageLoaded(msg);
            }
          }
        })
        .onError((error) => {
          if (this.model.imageLoadEventListener !== null) {
            this.model.imageLoadEventListener.onImageLoadError(error);
          }
        })

      Canvas(this.context)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onReady(() => {
          if (this.context === null) {
            return
          }

          let height = this.context.height
          let width = this.context.width
          this.context.fillStyle = this.model.maskColor;
          this.context.fillRect(0, 0, width, height)

          // 计算圆形的中心点和半径
          let centerX = width / 2;
          let centerY = height / 2;
          let minDimension = Math.min(width, height);
          let frameRadiusInVp = (minDimension - px2vp(this.model.frameWidth)) / 2; // 减去边框宽度

          // 把中间的取景框透出来
          this.context.globalCompositeOperation = 'destination-out'
          this.context.fillStyle = 'white'
          let frameWidthInVp = px2vp(this.model.frameWidth);
          let frameHeightInVp = px2vp(this.model.getFrameHeight());
          let x = (width - px2vp(this.model.frameWidth)) / 2;
          let y = (height - px2vp(this.model.getFrameHeight())) / 2;
          // this.context.fillRect(x, y, frameWidthInVp, frameHeightInVp)
          console.info(`width:${width}`)
          console.info(`height:${height}`)
          console.info(`x:${x}`)
          console.info(`y:${y}`)
          console.info(`this.model.frameWidth:${this.model.frameWidth}`)
          console.info(`this.model.getFrameHeight():${this.model.getFrameHeight()}`)
          console.info(`frameWidthInVp:${frameWidthInVp}`)
          console.info(`frameHeightInVp:${frameHeightInVp}`)
          console.info(`frameRadiusInVp:${frameRadiusInVp}`)
          this.context.beginPath();
          this.context.arc(centerX, centerY, px2vp(this.model.frameWidth / 2), 0, 2 * Math.PI);
          this.context.fill();

          // 设置综合操作模式为源覆盖，以便在现有图形上添加新的图形
          this.context.globalCompositeOperation = 'source-over';

          // 设置描边颜色
          this.context.strokeStyle = this.model.strokeColor;


          // 计算圆形的半径，这里我们取正方形边框的较短边的一半作为半径
          let radius = Math.min(frameWidthInVp, frameHeightInVp) / 2;

          // 开始绘制路径
          this.context.beginPath();

          // 使用 arc 方法绘制圆形
          this.context.arc(centerX, centerY, radius, 0, 2 * Math.PI);

          // 关闭路径
          this.context.closePath();

          // 描绘圆形边框
          this.context.lineWidth = 1; // 边框宽度
          this.context.stroke();

        })
        .enabled(false)

      Row() {
        if (this.model.src === '') {
          Button('打开相册')
            .onClick(() => {
              this.openPicker()
            })
            .width(120)
        } else {
          Button('取消')
            .onClick(() => {
              this.openPicker()
            })
            .width(120)
          Button('确定')
            .width(120)
            .onClick(async () => {
              let file: fs.File = null!;
              try {
                this.pm = await this.model.crop(image.PixelMapFormat.RGBA_8888);

                const imagePacker: image.ImagePacker = image.createImagePacker();
                let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };

                let name = 'avatar_' + getCurrentLocalTime().replace(/\D/g, '') + '.png';
                let uri = getContext(this).filesDir + '/' + encodeURIComponent(name);
                file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

                imagePacker.packToFile(this.pm, file.fd, packOpts, (err: BusinessError) => {
                  if (err) {
                    console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
                  } else {
                    console.info('Succeeded in packing the image to file.');
                    imagePacker.release((err: BusinessError) => {
                      if (err) {
                        console.error(`Failed to release the image source instance.code ${err.code},message is ${err.message}`);
                      } else {
                        console.info('Succeeded in releasing the image source instance.');

                        let user = this.userInfo.users.get(this.userInfo.unionID) as User
                        user.avatar = fileUri.getUriFromPath(uri)
                        this.userInfo.avatar = fileUri.getUriFromPath(uri)
                        fs.close(file.fd);
                      }
                    })
                  }
                })
                router.back()
              } catch (e) {
                console.error('upload avatar error', e)
              } finally {
                fs.close(file.fd)
              }
            })
        }
      }
      .offset({ y: 300 })
      .justifyContent(this.model.src === '' ? FlexAlign.Center : FlexAlign.SpaceBetween)
      .width(this.model.src === '' ? '40%' : '80%')
    }
    .clip(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#00000080')
    .priorityGesture(
      TapGesture({ count: 2, fingers: 1 })
        .onAction((event: GestureEvent) => {
          if (!event) {
            return
          }
          if (this.model.zoomEnabled) {
            if (this.model.scale !== 1) {
              this.model.scale = 1;
              this.model.reset();
              this.updateMatrix();
            } else {
              this.zoomTo(2);
            }
          }

          this.checkImageAdapt();
        })
    )
    .gesture(
      GestureGroup(GestureMode.Parallel,
        // 拖动手势
        PanGesture({})
          .onActionStart(() => {
            this.startOffsetX = this.model.offsetX;
            this.startOffsetY = this.model.offsetY;
          })
          .onActionUpdate((event: GestureEvent) => {
            if (event) {
              if (this.model.panEnabled) {
                let distanceX: number = this.startOffsetX + vp2px(event.offsetX) / this.model.scale;
                let distanceY: number = this.startOffsetY + vp2px(event.offsetY) / this.model.scale;
                this.model.offsetX = distanceX;
                this.model.offsetY = distanceY;
                this.updateMatrix()
              }
            }
          })
          .onActionEnd(() => {
            this.checkImageAdapt();
          }),

        // 缩放手势处理
        PinchGesture({ fingers: 2 })
          .onActionStart(() => {
            this.tempScale = this.model.scale
          })
          .onActionUpdate((event) => {
            if (event) {
              if (!this.model.zoomEnabled) {
                return;
              }
              this.zoomTo(this.tempScale * event.scale);
            }
          })
          .onActionEnd(() => {
            this.checkImageAdapt();
          })
      )
    )
  }

  /**
   * 检查手势操作后，图片是否填满取景框，没填满则进行调整
   */
  private checkImageAdapt() {
    let offsetX = this.model.offsetX;
    let offsetY = this.model.offsetY;
    let scale = this.model.scale;

    // 图片适配控件的时候也进行了缩放，计算出这个缩放比例
    let widthScale = this.model.componentWidth / this.model.imageWidth;
    let heightScale = this.model.componentHeight / this.model.imageHeight;
    let adaptScale = Math.min(widthScale, heightScale);

    // 经过两次缩放(适配控件、手势)后，图片的实际显示大小
    let showWidth = this.model.imageWidth * adaptScale * this.model.scale;
    let showHeight = this.model.imageHeight * adaptScale * this.model.scale;
    let imageX = (this.model.componentWidth - showWidth) / 2;
    let imageY = (this.model.componentHeight - showHeight) / 2;

    // 取景框的左上角坐标
    let frameX = (this.model.componentWidth - this.model.frameWidth) / 2;
    let frameY = (this.model.componentHeight - this.model.getFrameHeight()) / 2;

    // 图片左上角坐标
    let showX = imageX + offsetX * scale;
    let showY = imageY + offsetY * scale;

    if (this.model.frameWidth > showWidth || this.model.getFrameHeight() > showHeight) { // 图片缩放后，大小不足以填满取景框
      let xScale = this.model.frameWidth / showWidth;
      let yScale = this.model.getFrameHeight() / showHeight;
      let newScale = Math.max(xScale, yScale);
      this.model.scale = this.model.scale * newScale;
      showX *= newScale;
      showY *= newScale;
    }

    // 调整x轴方向位置，使图像填满取景框
    if (showX > frameX) {
      showX = frameX;
    } else if (showX + showWidth < frameX + this.model.frameWidth) {
      showX = frameX + this.model.frameWidth - showWidth;
    }
    // 调整y轴方向位置，使图像填满取景框
    if (showY > frameY) {
      showY = frameY;
    } else if (showY + showHeight < frameY + this.model.getFrameHeight()) {
      showY = frameY + this.model.getFrameHeight() - showHeight;
    }
    this.model.offsetX = (showX - imageX) / scale;
    this.model.offsetY = (showY - imageY) / scale;
    this.updateMatrix();
  }

  public zoomTo(scale: number): void {
    this.model.scale = scale;
    this.updateMatrix();
  }

  public updateMatrix(): void {
    this.matrix = Matrix4.identity()
      .translate({ x: this.model.offsetX, y: this.model.offsetY })
      .scale({ x: this.model.scale, y: this.model.scale })
  }
}

interface ImageLoadedEvent {
  width: number;
  height: number;
  componentWidth: number;
  componentHeight: number;
  loadingStatus: number;
  contentWidth: number;
  contentHeight: number;
  contentOffsetX: number;
  contentOffsetY: number;
}

export interface ImageLoadEventListener {

  onImageLoaded(msg: ImageLoadedEvent): void;

  onImageLoadError(error: ImageError): void;
}

@ObservedV2
export class CropModel {
  /**
   * 图片uri
   * 类型判断太麻烦了，先只支持string，其他形式的需要先转换成路径
   */
  @Trace
  src: string = '';
  /**
   * 图片预览
   */
  @Trace
  previewSource: string | Resource = '';
  /**
   * 是否可以拖动
   */
  @Trace
  panEnabled: boolean = true;
  /**
   * 是否可以缩放
   */
  @Trace
  zoomEnabled: boolean = true;
  /**
   * 取景框宽度
   */
  @Trace
  frameWidth = 1000;
  /**
   * 取景框宽高比
   */
  @Trace
  frameRatio = 1;
  /**
   * 遮罩颜色
   */
  @Trace
  maskColor: string = '#AA000000';
  /**
   * 取景框边框颜色
   */
  @Trace
  strokeColor: string = '#FFFFFF';
  /**
   * 图片加载监听
   */
  @Trace
  imageLoadEventListener: ImageLoadEventListener | null = null;
  /// 以下变量不要手动赋值 ///
  /**
   * 图片宽度，加载完成之后才会赋值
   */
  @Trace
  imageWidth: number = 0;
  /**
   * 图片高度，加载完成之后才会赋值
   */
  @Trace
  imageHeight: number = 0;
  /**
   * 控件宽度
   */
  @Trace
  componentWidth: number = 0;
  /**
   * 控件高度
   */
  @Trace
  componentHeight: number = 0;
  /**
   * 手势缩放比例
   * 图片经过了两重缩放，一是适配控件的时候进行了缩放，二是手势操作的时候进行了缩放
   */
  @Trace
  scale: number = 1;
  /**
   * x轴方向偏移量
   */
  @Trace
  offsetX: number = 0;
  /**
   * y轴方向偏移量
   */
  @Trace
  offsetY: number = 0;

  /////////////////////////////////////////////

  public setImage(src: string, previewSource?: string | Resource): CropModel {
    this.src = src;
    if (!!previewSource) {
      this.previewSource = previewSource;
    }
    return this;
  }

  public setScale(scale: number): CropModel {
    this.scale = scale;
    return this;
  }

  public isPanEnabled(): boolean {
    return this.panEnabled;
  }

  public setPanEnabled(panEnabled: boolean): CropModel {
    this.panEnabled = panEnabled;
    return this;
  }

  public setZoomEnabled(zoomEnabled: boolean): CropModel {
    this.zoomEnabled = zoomEnabled;
    return this;
  }

  public setFrameWidth(frameWidth: number): CropModel {
    this.frameWidth = frameWidth;
    return this;
  }

  public setFrameRatio(frameRatio: number): CropModel {
    this.frameRatio = frameRatio;
    return this;
  }

  public setMaskColor(color: string): CropModel {
    this.maskColor = color;
    return this;
  }

  public setStrokeColor(color: string): CropModel {
    this.strokeColor = color;
    return this;
  }

  public setImageLoadEventListener(listener: ImageLoadEventListener): CropModel {
    this.imageLoadEventListener = listener;
    return this;
  }

  public getScale(): number {
    return this.scale;
  }

  public isZoomEnabled(): boolean {
    return this.zoomEnabled;
  }

  public getImageWidth(): number {
    return this.imageWidth;
  }

  public getImageHeight(): number {
    return this.imageHeight;
  }

  public getFrameHeight() {
    return this.frameWidth / this.frameRatio;
  }

  public reset(): void {
    this.scale = 1;
    this.offsetX = 0;
    this.offsetY = 0;
  }

  public async crop(format: image.PixelMapFormat): Promise<image.PixelMap> {

    if (!this.src || this.src === '') {
      throw new Error('Please set src first');
    }
    if (this.imageWidth === 0 || this.imageHeight === 0) {
      throw new Error('The image is not loaded');
    }

    // 图片适配控件的时候也进行了缩放，计算出这个缩放比例
    let widthScale = this.componentWidth / this.imageWidth;
    let heightScale = this.componentHeight / this.imageHeight;
    let adaptScale = Math.min(widthScale, heightScale);

    // 经过两次缩放(适配控件、手势)后，图片的实际显示大小
    let totalScale = adaptScale * this.scale;
    let showWidth = this.imageWidth * totalScale;
    let showHeight = this.imageHeight * totalScale;
    let imageX = (this.componentWidth - showWidth) / 2;
    let imageY = (this.componentHeight - showHeight) / 2;

    // 取景框的左上角坐标
    let frameX = (this.componentWidth - this.frameWidth) / 2;
    let frameY = (this.componentHeight - this.getFrameHeight()) / 2;

    // 图片左上角坐标
    let showX = imageX + this.offsetX * this.scale;
    let showY = imageY + this.offsetY * this.scale;

    let x = (frameX - showX) / totalScale;
    let y = (frameY - showY) / totalScale;

    let file: fs.File = null!;
    let imageSource: image.ImageSource = null!;
    try {
      file = fs.openSync(this.src, fs.OpenMode.READ_ONLY)
      imageSource = image.createImageSource(file.fd);
    } catch (e) {
      console.error('upload avatar error', e)
    } finally {
      fs.close(file.fd)
    }

    let decodingOptions: image.DecodingOptions = {
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
    }

    // 创建pixelMap
    let pm = await imageSource.createPixelMap(decodingOptions);
    let cp = await this.copyPixelMap(pm);
    pm.release();
    let region: image.Region =
      { x: x, y: y, size: { width: this.frameWidth / totalScale, height: this.getFrameHeight() / totalScale } };
    cp.cropSync(region);
    return cp;
  }

  async copyPixelMap(pm: PixelMap): Promise<PixelMap> {
    const imageInfo: image.ImageInfo = await pm.getImageInfo();
    const buffer: ArrayBuffer = new ArrayBuffer(pm.getPixelBytesNumber());
    await pm.readPixelsToBuffer(buffer);
    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { height: imageInfo.size.height, width: imageInfo.size.width }
    };
    return image.createPixelMap(buffer, opts);
  }
}