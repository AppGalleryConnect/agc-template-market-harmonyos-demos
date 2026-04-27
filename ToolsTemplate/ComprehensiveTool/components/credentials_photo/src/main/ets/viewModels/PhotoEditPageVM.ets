import { image } from '@kit.ImageKit';
import { RouterMap, getInstance } from '../util/Route';
import { ColorItem, DressItem, SettingItem, EditParms, PhotoContainerController, PhotoTypeItem } from '../model/Index';


@ObservedV2
export class PhotoEditPageVM {
  @Trace photoType: PhotoTypeItem | undefined = undefined;
  @Trace img: image.PixelMap | undefined = undefined;
  @Trace navTitle: string = '';
  @Trace colorIndex: number = 0;
  // 颜色选项
  @Trace colorList: ColorItem[] = [
    {
      label: '纯白色',
      icon: $r('app.media.ic_color1'),
      color: $r('sys.color.icon_on_primary'),
    },
    {
      label: '标准蓝色',
      icon: $r('app.media.ic_color2'),
      color: $r('sys.color.icon_emphasize'),
    },
    {
      label: '红色',
      icon: $r('app.media.ic_color3'),
      color: $r('sys.color.multi_color_08'),
    },
    {
      label: '灰白色',
      icon: $r('app.media.ic_color4'),
      color: $r('sys.color.comp_background_tertiary'),
    },
    {
      label: '浅蓝色',
      icon: $r('app.media.ic_color5'),
      color: $r('sys.color.comp_emphasize_tertiary'),
    },
  ];
  @Trace settingIndex: number = -1;
  @Trace settingList: SettingItem[] = [
    {
      text: '更换背景',
      icon: $r('app.media.ic_edit_background'),
      checked: $r('app.media.ic_edit_background_checked'),
    },
    {
      text: '更换服装',
      icon: $r('app.media.ic_edit_wear'),
      checked: $r('app.media.ic_edit_wear_checked'),
    },
  ];
  @Trace dressIndex: number = 0;
  @Trace dressList: DressItem[] = [
    {
      id: '1',
      icon: $r('app.media.ic_dress0'),
      dress: '',
    },
    {
      id: '2',
      icon: $r('app.media.ic_dress1'),
      dress: $r('app.media.dress1'),
    },
    {
      id: '3',
      icon: $r('app.media.ic_dress2'),
      dress: $r('app.media.dress2'),
    },
    {
      id: '4',
      icon: $r('app.media.ic_dress3'),
      dress: $r('app.media.dress3'),
    },
    {
      id: '5',
      icon: $r('app.media.ic_dress4'),
      dress: $r('app.media.dress4'),
    },
    {
      id: '6',
      icon: $r('app.media.ic_dress5'),
      dress: $r('app.media.dress5'),
    },
  ];
  @Trace controller: PhotoContainerController = new PhotoContainerController();
  @Trace isFitDesign: boolean = true;
  private static _instance: PhotoEditPageVM;

  public static get instance() {
    if (!PhotoEditPageVM._instance) {
      PhotoEditPageVM._instance = new PhotoEditPageVM();
    }
    return PhotoEditPageVM._instance;
  }


  public getRouteParam() {
    const res: EditParms = getInstance().getParamByName(RouterMap.EDIT)[0] as EditParms;
    this.img = res.img;
    this.photoType = {
      label: res.label,
      size: res.size,
    };
    this.navTitle = res.label;
  }


  // 保存
  public toSavePhoto(pixmap: image.PixelMap) {
    if (this.photoType) {
      const params: EditParms = {
        label: this.photoType.label,
        size: this.photoType.size,
        img: pixmap,
      };
      getInstance().replacePathByName(RouterMap.SAVE, params);
    }
  }


  public initData() {
    this.colorIndex = 0;
    this.dressIndex = 0;
    this.settingIndex = -1;
  }
}