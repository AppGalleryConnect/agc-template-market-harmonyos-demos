import { Type } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { BaseViewModel, RouterMap, RouterModule } from 'commonlib';
import { CollageMode } from '../constant/Enum';
import {
  PosterTemplateModel,
  CollageModeInfo,
  FreeCollageModel,
  ImageVM,
  LayoutRegion,
  LayoutTemplateModel,
  PosterRegion,
  XY,
} from '../model/CollageModel';
import { FIXED_LAYOUT_TEMPLATES, FREE_TEMPLATES, POSTER_TEMPLATES } from '../constant/TemplateData';
import { PosterUtil } from '../util/PosterUtil';
import { DESIGN_H, DESIGN_W } from '../constant/Constants';

@ObservedV2
export class CollageVM extends BaseViewModel {
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
  @Trace collageAreaWidth: number = 0;
  @Trace collageAreaHeight: number = 0;
  @Trace postImageWidth: number = 0;
  @Trace postImageHeight: number = 0;
  @Trace postImageOffsetX: number = 0;
  @Trace postImageOffsetY: number = 0;
  collageModeList: CollageModeInfo[] = [
    {
      mode: CollageMode.FIXED,
      name: '固定拼接',
      show: true,
      clickAction: () => {
        this.setMode(CollageMode.FIXED);
        this.selectLayout(this.fixedLayout[this.fixedIndex]);
      },
    },
    {
      mode: CollageMode.POSTER,
      name: '海报模式',
      show: true,
      clickAction: () => {
        this.setMode(CollageMode.POSTER);
        this.selectPoster(this.posterList[this.posterIndex]);
      },
    },
    {
      mode: CollageMode.FREE,
      name: '自由拼接',
      show: false,
      clickAction: () => {
        this.setMode(CollageMode.FREE);
      },
    },
    {
      mode: CollageMode.JOIN,
      name: '拼长图',
      show: false,
      clickAction: () => {
        this.setMode(CollageMode.JOIN);
      },
    },
  ]
  private static _instance: CollageVM;

  public static get instance() {
    if (!CollageVM._instance) {
      CollageVM._instance = new CollageVM();
    }
    return CollageVM._instance;
  }

  public static set instance(_instance: CollageVM) {
    CollageVM._instance = _instance;
  }

  init() {
    // 清空模板和海报
    this.getPictureFromAlbum();
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
    this.setFixedLayoutRegion();
    this.selectPoster(this.posterList[this.posterIndex]);
    this.selectFree(FREE_TEMPLATES[this.freeIndex]);
  }

  setFixedLayoutRegion() {
    const length = this.fixedLayout.length
    if (length) {
      const x = Math.floor(this.collageAreaWidth);
      const y = Math.floor(this.collageAreaHeight);
      for (let i = 0; i < this.fixedLayout.length; i++) {
        const item = this.fixedLayout[i];
        const aveX = Math.floor(x / item.regions.length);
        const aveY = Math.floor(y / item.regions.length);
        item.regions.forEach((region: LayoutRegion, index: number) => {
          const topY = index * aveY;
          const bottomY = (index + 1) * aveY;
          const leftX = index * aveX;
          const rightX = (index + 1) * aveX;
          // 上下拼接
          if (i === 0) {
            region.path = `M 0 ${topY} L ${x} ${topY} L ${x} ${bottomY}  L 0 ${bottomY} Z`;
          } else {
            // 左右拼接
            region.path = `M ${leftX} 0 L ${rightX} 0 L ${rightX} ${y} L ${leftX} ${y} Z`;
          }
        })
      }
      this.selectLayout(this.fixedLayout[this.fixedIndex]);
    }
  }

  getPictureFromAlbum() {
    // 获取页面参数
    let param = RouterModule.getNavParam({ url: RouterMap.COLLAGE_PAGE }) as string[];
    if (param.length > 0) {
      for (let uri of param) {
        this.addImage(uri);
      }
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
    if (this.layout) {
      this.layout.id = template.id
      this.layout.name = template.name
      this.layout.image = template.image
      this.layout.selectedImage = template.selectedImage
      this.layout.count = template.count
      this.layout.width = template.width
      this.layout.height = template.height
    } else {
      this.layout = new LayoutTemplateModel(template);
    }
    this.layout.regions = template.regions.map((item) => {
      const newRegion = new LayoutRegion();
      newRegion.path = item.path
      return newRegion;
    })

    this.polygons = this.layout.regions.map(r => this.parsePathToPolygon(r.path));
  }

  // 选择海报模板
  selectPoster(template: PosterTemplateModel) {
    if (this.poster) {
      this.poster.id = template.id
      this.poster.count = template.count
      this.poster.background = template.background
      this.poster.example = template.example
      this.poster.oriRegions = template.oriRegions
      this.poster.hasProcessed = template.hasProcessed
      this.poster.isVip = template.isVip
    } else {
      this.poster = new PosterTemplateModel(template);
    }

    const scaleX = this.postImageWidth / DESIGN_W;
    const scaleY = this.postImageHeight / DESIGN_H;
    if (this.mode === CollageMode.POSTER) {
      this.processPoster(scaleX, scaleY, this.postImageOffsetX, this.postImageOffsetY);
    }
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
      const regions: PosterRegion[] = [];
      for (let i = 0; i < this.poster.oriRegions.length; i++) {
        let region = this.poster.oriRegions[i];
        const absPts: XY[] = region.coordinates.map(p => PosterUtil.mapPointToDisplay(p, scaleX, scaleY, offX, offY));
        let box: PosterRegion = PosterUtil.bboxOfPoints(absPts);
        this.posterImages[i].x = absPts[0].x;
        this.posterImages[i].y = absPts[0].y;
        this.posterImages[i].width = box.width;
        this.posterImages[i].height = box.height;
        box.path = PosterUtil.localPathFromAbsPoints(absPts);
        regions.push(box);
      }
      this.poster.regions = regions;
      this.polygons = this.poster.regions.map(r => this.parsePathToPolygon(r.path));
    }
  }
}
