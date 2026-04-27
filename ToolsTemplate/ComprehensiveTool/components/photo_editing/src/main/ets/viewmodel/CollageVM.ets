import { Type } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { LayoutTemplateModel } from '../model/LayoutTemplateModel';
import PosterTemplateModel, { PosterRegion, XY } from '../model/PosterTemplateModel';
import FreeCollageModel from '../model/FreeCollageModel';
import { PosterUtil } from '../util/PosterUtil';
import { getInstance } from '../util/RouteModule';
import { FIXED_LAYOUT_TEMPLATES, FREE_TEMPLATES, POSTER_TEMPLATES } from '../constant/TemplateData';
import { ImageVM } from '../model/Index';
import { CollageMode } from '../constant/Enum';

@ObservedV2
export class CollageVM {
  @Trace mode: CollageMode = CollageMode.FIXED;
  @Type(ImageVM)
  @Trace fixedImages: ImageVM[] = [];
  @Type(ImageVM)
  @Trace posterImages: ImageVM[] = [];
  @Type(ImageVM)
  @Trace freeImages: ImageVM[] = [];
  @Trace imagesToJoin: string[] = [];
  @Trace layout?: LayoutTemplateModel;
  @Trace poster?: PosterTemplateModel;
  @Trace free?: FreeCollageModel;
  @Trace polygons: number[][][] = [];
  @Trace joinImagePixelMap: image.PixelMap | undefined = undefined;
  @Trace fixedLayout: LayoutTemplateModel[] = [];
  @Trace posterList: PosterTemplateModel[] = [];
  @Trace fixedIndex: number = 0;
  @Trace posterIndex: number = 0;
  @Trace freeIndex: number = 0;
  private static _instance: CollageVM;

  public static get instance() {
    if (!CollageVM._instance) {
      CollageVM._instance = new CollageVM();
    }
    return CollageVM._instance;
  }

  getMaxTemplateCount(templates: LayoutTemplateModel[] | PosterTemplateModel[]) {
    let max = 0;
    for (let template of templates) {
      max = Math.max(template.count, max);
    }
    return max;
  }

  async init(uiContext: UIContext) {
    // 清空模板和海报
    await this.getPictureFromAlbum(uiContext);
    for (let i = 0; i < FIXED_LAYOUT_TEMPLATES.length; i++) {
      if (FIXED_LAYOUT_TEMPLATES[i].count === this.fixedImages.length) {
        this.fixedLayout.push(FIXED_LAYOUT_TEMPLATES[i]);
      }
    }
    for (let i = 0; i < POSTER_TEMPLATES.length; i++) {
      if (POSTER_TEMPLATES[i].count === this.fixedImages.length) {
        this.posterList.push(POSTER_TEMPLATES[i]);
      }
    }
    this.selectLayout(this.fixedLayout[this.fixedIndex]);
    this.selectPoster(this.posterList[this.posterIndex]);
    this.selectFree(FREE_TEMPLATES[this.freeIndex]);
  }

  clear() {
    this.fixedLayout = [];
    this.posterList = [];
    this.fixedImages = [];
    this.posterImages = [];
    this.freeImages = [];
    this.imagesToJoin = [];
    this.layout = new LayoutTemplateModel();
    this.poster = new PosterTemplateModel();
    this.mode = CollageMode.FIXED;
  }

  async getPictureFromAlbum(uiContext: UIContext) {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    let fixMaxCount = this.getMaxTemplateCount(FIXED_LAYOUT_TEMPLATES);
    let posterMaxCount = this.getMaxTemplateCount(POSTER_TEMPLATES);
    let minCount = Math.max(fixMaxCount, posterMaxCount);
    photoSelectOptions.maxSelectNumber = minCount;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
    if (photoSelectResult.photoUris.length < 2) {
      uiContext.getPromptAction().showToast({
        message: `请选择2-${minCount}张图片`,
        duration: 2000,
      });
      getInstance().pop();
    }
    for (let uri of photoSelectResult.photoUris) {
      this.addImage(uri);
    }
  }

  // 切换模式
  setMode(mode: CollageMode) {
    this.mode = mode;
  }

  // 添加图片
  addImage(src: string) {
    const createImageVM = () => {
      let imgVM = new ImageVM();
      imgVM.id = Date.now().toString();
      imgVM.src = src;
      return imgVM;
    };

    this.fixedImages.push(createImageVM());
    this.posterImages.push(createImageVM());
    this.freeImages.push(createImageVM());
    this.imagesToJoin.push(src);
  }

  // 选择固定拼接模板
  selectLayout(template: LayoutTemplateModel) {
    this.layout = template;
    this.polygons = this.layout.regions.map(r => this.parsePathToPolygon(r.path));
  }

  // 选择海报模板
  selectPoster(template: PosterTemplateModel) {
    this.poster = template;
  }

  selectFree(template: FreeCollageModel) {
    this.free = template;
  }

  isPointInPolygon(x: number, y: number, polygon: number[][]): boolean {
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      let xi = polygon[i][0], yi = polygon[i][1];
      let xj = polygon[j][0], yj = polygon[j][1];
      let intersect = ((yi > y) !== (yj > y)) &&
        (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) {
        inside = !inside;
      }
    }
    return inside;
  }

  parsePathToPolygon(path: string): number[][] {
    const points: number[][] = [];
    const tokens = path.match(/[MLHVZmlhvz]|-?\d+(\.\d+)?/g) || [];
    let i = 0;
    let currentX = 0, currentY = 0;
    let startX = 0, startY = 0;

    while (i < tokens.length) {
      const token = tokens[i];

      switch (token) {
        case 'M': // MoveTo
          currentX = parseFloat(tokens[++i]);
          currentY = parseFloat(tokens[++i]);
          startX = currentX;
          startY = currentY;
          points.push([currentX, currentY]);
          break;

        case 'L': // LineTo
          currentX = parseFloat(tokens[++i]);
          currentY = parseFloat(tokens[++i]);
          points.push([currentX, currentY]);
          break;

        case 'H': // Horizontal line
          currentX = parseFloat(tokens[++i]);
          points.push([currentX, currentY]);
          break;

        case 'V': // Vertical line
          currentY = parseFloat(tokens[++i]);
          points.push([currentX, currentY]);
          break;

        case 'Z': // Close path
          points.push([startX, startY]);
          break;

        default:
          i++;
          continue;
      }
      i++;
    }

    return points;
  }

  async joinImages(
    images: Array<string> | Array<image.PixelMap>,
    isH: boolean = false,
  ) {
    try {
      if (images.length < 2) {
        return;
      }

      const wideList: number[] = [];
      const heightList: number[] = [];
      const imageSourceList: image.ImageSource[] = [];

      for (let x = 0; x < images.length; x++) {
        let buffer: ArrayBuffer;
        if (typeof images[x] === 'string') {
          const file = fileIo.openSync(String(images[x]), fileIo.OpenMode.READ_ONLY);
          buffer = new ArrayBuffer(fileIo.statSync(file.fd).size);
          fileIo.readSync(file.fd, buffer);
          fileIo.closeSync(file);
        } else {
          const pixelMap = images[x] as image.PixelMap;
          buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
          pixelMap.readPixelsToBuffer(buffer);
        }

        const imageSource = image.createImageSource(buffer);
        const imageInfo = await imageSource.getImageInfo();
        wideList.push(imageInfo.size.width);
        heightList.push(imageInfo.size.height);
        imageSourceList.push(imageSource);
      }

      const totalWidth = isH ? wideList.reduce((a, b) => a + b, 0) : Math.max(...wideList);
      const totalHeight = isH ? Math.max(...heightList) : heightList.reduce((a, b) => a + b, 0);

      const combineOpts: image.InitializationOptions = {
        alphaType: 0,
        editable: true,
        pixelFormat: image.PixelMapFormat.BGRA_8888,
        size: { width: totalWidth, height: totalHeight },
      };

      const combineColor = new ArrayBuffer(totalWidth * totalHeight * 4);
      const newPixelMap = await image.createPixelMap(combineColor, combineOpts);

      let currentX = 0;
      let currentY = 0;

      for (let i = 0; i < images.length; i++) {
        const singleOpts: image.DecodingOptions = {
          editable: true,
          desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
          desiredSize: { width: wideList[i], height: heightList[i] },
        };
        const singlePixelMap = await imageSourceList[i].createPixelMap(singleOpts);
        let singleColor = new ArrayBuffer(wideList[i] * heightList[i] * 4);
        await singlePixelMap.readPixelsToBuffer(singleColor);

        const area: image.PositionArea = {
          pixels: singleColor,
          offset: 0,
          stride: wideList[i] * 4,
          region: {
            size: { width: wideList[i], height: heightList[i] },
            x: isH ? currentX : 0,
            y: isH ? 0 : currentY,
          },
        };
        await newPixelMap.writePixels(area);

        if (isH) {
          currentX += wideList[i];
        } else {
          currentY += heightList[i];
        }
      }

      this.joinImagePixelMap = newPixelMap;
    } catch (err) {
      UtilLog.error(0x0000, 'PHOTO_EDITING', 'joinImages error: ' + JSON.stringify(err));
    }
  }

  processPoster(scaleX: number, scaleY: number, offX: number, offY: number) {
    if (this.poster) {
      if (this.poster.regions.length === 0) {
        for (let i = 0; i < this.poster.oriRegions.length; i++) {
          let region = this.poster.oriRegions[i];
          const absPts: XY[] = region.coordinates.map(p => PosterUtil.mapPointToDisplay(p, scaleX, scaleY, offX, offY));
          let box: PosterRegion = PosterUtil.bboxOfPoints(absPts);
          this.posterImages[i].x = region.coordinates[0].x;
          this.posterImages[i].y = region.coordinates[0].y;
          this.posterImages[i].width = box.width;
          this.posterImages[i].height = box.height;
          box.path = PosterUtil.localPathFromAbsPoints(absPts);
          this.poster.regions.push(box);
        }
      }
      this.polygons = this.poster.regions.map(r => this.parsePathToPolygon(r.path));
    }
  }
}
