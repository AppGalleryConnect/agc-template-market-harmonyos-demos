import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, Constant, LazyDataSource } from 'common';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { CustomShareParams } from 'module_base';
import { https } from 'network';
import { FullLoadingComponent, SwiperComponent, TitleBar } from 'uicomponents';
import { mapperCommodityDetail } from '../mapper/Index';
import { CommodityInfo, SpecCategory, SpecOption, SpuInfo } from '../model/CommodityInfo';
import { CommodityDetailVM } from '../viewmodel/CommodityDetailVM';

@Builder
export function CommodityDetailBuilder() {
  CommodityDetail();
}

@ComponentV2
export struct CommodityDetail {
  vm: CommodityDetailVM = CommodityDetailVM.instance;
  @Local isShow: boolean = false;
  @Local isLoading: boolean = true;
  @Local selectedSpu: number = 0;
  @Local selectedSpuTemp: number = 0;
  @Local commodityInfo: CommodityInfo = new CommodityInfo();
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Local instance: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local selectedSpecOptions: Map<string, string> = new Map(); // 存储选中规格的 Map<categoryId, optionId>
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local resources: SourceImageModel[] = [];
  options: ImagePreviewOptions = new ImagePreviewOptions();

  @Builder
  BasicInfoBuilder() {
    Column() {
      Row({ space: 8 }) {
        Text() {
          Span('￥').fontSize($r('sys.float.Body_S')).fontWeight(FontWeight.Medium);
          Span(`${this.commodityInfo.spuInfo[this.selectedSpu]?.spuDiscountPrice}`)
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold);
        }.fontColor($r('sys.color.warning'));

        Text(`￥${this.commodityInfo.spuInfo[this.selectedSpu]?.spuOriginalPrice}`)
          .fontSize(14)
          .decoration({ type: TextDecorationType.LineThrough })
          .fontColor($r('sys.color.font_tertiary'));
      };

      Text(this.commodityInfo.name)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Row() {
        Text() {
          Span('规格：').fontColor($r('sys.color.font_secondary'));
          Span(this.getFriendlySpecString(this.commodityInfo.spuInfo[this.selectedSpu]))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(500);
        }.fontSize(14).height(32).textAlign(TextAlign.Center);

        Image($r('app.media.chevron_right')).size({ height: 14, width: 6 });
      }
      .width(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8, bottom: 8 })
      .onClick(() => {
        this.selectedSpuTemp = this.selectedSpu;
        this.isShow = true;
      })
      .bindSheet($$this.isShow, this.SpecificationBuilder(), {
        height: 465,
        detents: [465, 466],
        showClose: false,
        preferType: SheetType.CENTER,
        backgroundColor: 'rgba(241, 243, 245, 1)',
      });
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding({
      top: 4,
      bottom: 4,
      left: this.breakPointModel.isLargeScreen ? 12 : this.breakPointModel.pagePadding,
      right: this.breakPointModel.isLargeScreen ? 12 : this.breakPointModel.pagePadding,
    })
    .borderRadius(this.breakPointModel.isLargeScreen ? 16 : 0)
    .margin({
      left: this.breakPointModel.isLargeScreen ? this.breakPointModel.pagePadding : 0,
      right: this.breakPointModel.isLargeScreen ? this.breakPointModel.pagePadding : 0,
    })
    .constraintSize({ maxWidth: Constant.FULL_PERCENT })
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  DetailBuilder() {
    Column({ space: 12 }) {
      Text('商品详情')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Start);
      ForEach(this.commodityInfo.detailImages, (item: ResourceStr) => {
        Image(item);
      }, (item: ResourceStr) => item.toString());
    }
    .margin({ top: 8 })
    .padding({ top: 24, left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
    .backgroundColor(this.breakPointModel.isLargeScreen ? $r('sys.color.background_secondary') :
      $r('sys.color.comp_background_primary'));
  }

  /**
   * 检查选项是否被选中
   */
  isOptionSelected(category: SpecCategory, option: SpecOption): boolean {
    return this.selectedSpecOptions.get(category.id) === option.id;
  }

  /**
   * 选择规格选项
   */
  selectOption(category: SpecCategory, option: SpecOption) {
    this.selectedSpecOptions.set(category.id, option.id); // 更新临时选中的 SPU 索引
    const selectedSpuIndex = this.findMatchingSpuIndex();
    if (selectedSpuIndex !== -1) {
      this.selectedSpuTemp = selectedSpuIndex;
    }
  }

  /**
   * 查找匹配的 SPU 索引
   */
  findMatchingSpuIndex(): number {
    for (let i = 0; i < this.commodityInfo.spuInfo.length; i++) {
      const spu = this.commodityInfo.spuInfo[i];
      if (this.spuMatchesSelectedSpecs(spu)) {
        return i;
      }
    }
    return -1;
  }

  /**
   * 检查 SPU 是否匹配选中的规格
   */
  spuMatchesSelectedSpecs(spu: SpuInfo): boolean { // 优先使用 specValues 进行匹配
    if (spu.specValues && spu.specValues.length > 0) {
      for (const category of this.commodityInfo.specCategories) {
        const selectedOptionId = this.selectedSpecOptions.get(category.id);
        const selectedOption = category.options.find(opt => opt.id === selectedOptionId);
        if (!selectedOption) {
          return false;
        } // 在 specValues 中查找匹配的值
        const specValue = spu.specValues.find(sv => sv.name === category.name);
        if (!specValue || specValue.value !== selectedOption.name) {
          return false;
        }
      }
      return true;
    }

    // 降级方案：使用 spuName 进行匹配
    const specNames = spu.spuName.split('/').map(s => s.trim());
    const selectedCategories = this.commodityInfo.specCategories.filter(cat => this.selectedSpecOptions.has(cat.id));

    for (const category of selectedCategories) {
      const selectedOptionId = this.selectedSpecOptions.get(category.id);
      const selectedOption = category.options.find(opt => opt.id === selectedOptionId);
      if (!selectedOption || !specNames.includes(selectedOption.name)) {
        return false;
      }
    }
    return true;
  }

  /**
   * 获取当前选中的规格组合字符串
   */
  getSelectedSpecString(): string {
    const selectedNames: string[] = [];
    for (const category of this.commodityInfo.specCategories) {
      const selectedOptionId = this.selectedSpecOptions.get(category.id);
      const selectedOption = category.options.find(opt => opt.id === selectedOptionId);
      if (selectedOption) {
        selectedNames.push(selectedOption.name);
      }
    }
    return selectedNames.join('/');
  }

  /**
   * 获取友好的规格显示字符串
   * 优先使用 specValues 生成格式如 "53° / 米香型"
   */
  getFriendlySpecString(spu: SpuInfo): string {
    if (spu.specValues && spu.specValues.length > 0) {
      return spu.specValues.map(sv => sv.value).join(' / ');
    } // 降级方案：使用 spuName
    return spu.spuName;
  }

  /**
   * 初始化选中的规格选项
   * 根据 SPU 的 spuName 初始化 selectedSpecOptions
   */
  initSelectedSpecOptions() {
    const currentSpu = this.commodityInfo.spuInfo[this.selectedSpu];
    if (!currentSpu) {
      return;
    }

    const specNames = currentSpu.spuName.split('/').map(s => s.trim());
    for (const category of this.commodityInfo.specCategories) {
      for (const option of category.options) {
        if (specNames.includes(option.name)) {
          this.selectedSpecOptions.set(category.id, option.id);
          break;
        }
      }
    }
  }

  @Builder
  SpecificationBuilder() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .width(40)
            .height(40)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(1000)
            .padding(8)
            .onClick(() => {
              this.isShow = false;
            });

          Text('规格选择')
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold);
        };

        Image($r('app.media.close')).width(40).height(40).margin({ right: 3 }).onClick(() => {
          this.isShow = false;
        });
      }
      .width(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: 8, top: this.breakPointModel.isLargeScreen ? 8 : 0 })
      .margin({ top: this.breakPointModel.isLargeScreen ? 8 : 0 });

      Row({ space: 12 }) {
        Image(this.commodityInfo.banner).size({ width: 56, height: 56 }).borderRadius(8);

        Column({ space: 4 }) {
          Text(this.commodityInfo.name)
            .fontSize($r('sys.float.Body_L'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(FontWeight.Medium);

          Row({ space: 2 }) {
            Text() {
              Span('￥').fontSize($r('sys.float.Body_S'));
              Span(`${this.commodityInfo.spuInfo[this.selectedSpu]?.spuDiscountPrice}`)
                .fontSize($r('sys.float.Body_L'));
            }.fontWeight(FontWeight.Medium).fontColor($r('sys.color.multi_color_08'));

            Text(`￥${this.commodityInfo.spuInfo[this.selectedSpu]?.spuOriginalPrice}`)
              .fontSize(12)
              .decoration({ type: TextDecorationType.LineThrough })
              .fontColor($r('sys.color.font_tertiary'));
          };
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      }
      .width(Constant.FULL_PERCENT)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16)
      .padding(12);

      Column({ space: 12 }) {
        ForEach(this.commodityInfo.specCategories, (category: SpecCategory) => {
          Column() {
            Text(category.name)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ bottom: 8, top: 19 });

            Row({ space: 12 }) {
              ForEach(category.options, (option: SpecOption) => {
                Text(option.name)
                  .fontColor($r('sys.color.font_primary'))
                  .textAlign(TextAlign.Center)
                  .padding({
                    top: 4,
                    bottom: 4,
                    left: 8,
                    right: 8,
                  })
                  .fontSize($r('sys.float.Body_M'))
                  .height(28)
                  .constraintSize({ minWidth: 76 })
                  .backgroundColor(
                    this.isOptionSelected(category, option) ? '#6664BB5C' : $r('sys.color.comp_background_tertiary'))
                  .borderRadius(14)
                  .onClick(() => {
                    this.selectOption(category, option);
                  });
              }, (option: SpecOption) => option.id);
            }.margin({ top: 4 });
          }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
        }, (category: SpecCategory) => category.id);
      }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT).layoutWeight(1);

      Row({ space: 16 }) {
        Button('取消')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_04'))
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.isShow = false;
          });
        Button('确定')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .layoutWeight(1)
          .backgroundColor($r('sys.color.multi_color_04'))
          .onClick(() => {
            this.selectedSpu = this.selectedSpuTemp;
            this.isShow = false;
          });
      }.width(Constant.FULL_PERCENT);
    }.padding({ left: 16, right: 16 }).align(Alignment.Top).margin({ bottom: this.windowBottomHeight });
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        FullLoadingComponent();
      } else {
        Column() {
          Column() {
            if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
              Row() {
                Column() {
                  TitleBar({
                    isShowBack: true, title: '商品详情', clickEvent: () => {
                      this.mainPathStack.pop();
                    },
                  });
                  Row() {
                    SwiperComponent(this.banners, 360, this.options, (index: number) => {
                      this.options
                        .setImageList(this.resources)
                        .setInitIndex(index);
                      ImagePreview.open(this.getUIContext(), this.options);
                    });
                  }.layoutWeight(1);
                }.layoutWeight(1).height('100%').backgroundColor($r('sys.color.comp_background_primary'));

                Scroll() {
                  Column() {
                    this.BasicInfoBuilder();

                    this.DetailBuilder();
                  };
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .layoutWeight(1)
                .height('100%')
                .margin({ top: 8 + 56 + this.windowTopHeight });
              }.layoutWeight(1);
            } else {
              TitleBar({
                isShowBack: true, title: '商品详情', clickEvent: () => {
                  this.mainPathStack.pop();
                },
              });
              Scroll() {
                Column() {
                  // SwiperComponent(this.banners, 360);
                  SwiperComponent(this.banners, 360, this.options, (index: number) => {
                    this.options
                      .setImageList(this.resources)
                      .setInitIndex(index);
                    ImagePreview.open(this.getUIContext(), this.options);
                  });
                  this.BasicInfoBuilder();

                  this.DetailBuilder();
                };
              }.align(Alignment.Top).scrollBar(BarState.Off).layoutWeight(1);
            }
          }.layoutWeight(1);

          Row() {
            Button('立即购买')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_M'))
              .width(Constant.FULL_PERCENT)
              .margin({ left: 2, right: 2 })
              .constraintSize({ maxWidth: Constant.MAX_WIDTH })
              .borderRadius(20)
              .backgroundColor($r('sys.color.multi_color_04'))
              .onClick(() => {
                this.mainPathStack.pushPathByName('CommodityReserve',
                  this.vm.mapPurchaseParam(this.commodityInfo, this.selectedSpu));
              });
          }
          .width(Constant.FULL_PERCENT)
          .height(56)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .justifyContent(FlexAlign.Center)
          .padding({
            top: 8,
            bottom: 8,
            left: this.breakPointModel.pagePadding,
            right: this.breakPointModel.pagePadding,
          });
        }.backgroundColor($r('sys.color.background_secondary')).margin({ bottom: this.windowBottomHeight });
      }
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      https.getCommodityDetail(context.pathInfo.param as number).then(res => {
        this.commodityInfo = mapperCommodityDetail(res.data);
        this.banners.pushArrayData(this.commodityInfo.banners); // 初始化选择的规格
        this.resources = this.banners.dataArray.map((imageUrl) => {
          return new SourceImageModel({ imageUrl });
        });
        this.selectedSpu = this.commodityInfo.basicSpu;
        this.selectedSpuTemp = this.commodityInfo.basicSpu; // 初始化选定规格的 Map
        this.initSelectedSpecOptions();
        this.isLoading = false; // 华为分享
        this.instance.pageName = 'CommodityDetail';
        this.instance.goodId = this.commodityInfo.commodityId;
        this.instance.goodName = this.commodityInfo.name;
      });
    });
  }
}
