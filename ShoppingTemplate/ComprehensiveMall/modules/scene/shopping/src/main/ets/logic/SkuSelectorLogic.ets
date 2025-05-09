import util from '@ohos.util';
import HashMap from '@ohos.util.HashMap';
import HashSet from '@ohos.util.HashSet';

import { promptAction } from '@kit.ArkUI';
import { ProductSelectionInfo, SpecValue } from '@common/customtypes';

import { SpecItemVM } from '../viewmodel/SpecItemVM';

type SpecViewData = [string, SpecItemVM[]][];

interface SpecStatus {
  canSelect: HashSet<string>;
  inStock: HashSet<string>;
}

type SpecAdjacencyMatrix = Record<string, Record<string, SpecStatus>>;

@ObservedV2
export class SkuSelectorLogic {

  @Trace
  public test: boolean = false;

  public readonly BANNER_COMP_ID: string = util.generateRandomUUID(false);

  public readonly SERVICE_INFO_COMP_ID: string = util.generateRandomUUID(false);

  @Trace
  public info: ProductSelectionInfo;

  // 商品规格视图数据
  @Trace
  public specViewData: SpecViewData = [];

  // 顶部图片
  @Trace
  public banner: string = '';

  // 价格备注
  @Trace
  public priceRemark: string = '';

  // 当前所选 sku 编码
  @Trace
  public skuCode: string | null = null;

  // 当前所选 sku 的选择数量
  @Trace
  public count: number = 1;

  @Trace
  public skuStock: number = 0;

  @Trace
  public price: string = '';

  @Trace
  public dashPrice: string = '';

  @Trace
  public priceRange: string = '';

  @Trace
  public isOutOfStock: boolean = false;

  // 当前所选规格 (spec_key to spec_item_id)
  private selectedSpecs: HashMap<string, string> = new HashMap();

  // 邻接矩阵
  private adjacencyMatrix: SpecAdjacencyMatrix = {};

  /**
   * 关闭模态页面时的回调
   */
  public onBackCallback: () => void = () => {};

  /**
   * 点击确定时的回调
   */
  public onAgreeCallback: (skuCode: string, count: number) => void = () => {};

  /**
   * 该方法用于监听页面关闭事件
   */
  public readonly onBack = (): void => {
    this.onBackCallback();
  }

  /**
   * 该方法用于监听按钮点击事件
   */
  public readonly onAgree = (): void => {
    if (this.isOutOfStock) {
      promptAction.showToast({ message: '库存不足' });
      return;
    }
    if (this.skuCode === null) {
      promptAction.showToast({ message: '还有规格没有选择' });
      return;
    }
    this.onAgreeCallback(this.skuCode, this.count);
  }

  public readonly onCountChange = (value: number): void => {
    if (this.isOutOfStock) {
      promptAction.showToast({ message: '库存不足' });
      return;
    }
    if (this.skuCode === null) {
      promptAction.showToast({ message: '还有规格没有选择' });
      return;
    }
    let target: number = this.count + value;
    if (target < 1) {
      promptAction.showToast({ message: '至少选择一件商品' });
    } else if (target > this.skuStock) {
      promptAction.showToast({ message: '数量超出范围' });
    } else {
      this.count = this.count + value;
      if (this.count > 1) {
        this.priceRemark = this.info.totalPriceRemark;
      } else {
        this.priceRemark = this.info.priceRemark;
      }
      for (let item of this.info.skuItems) {
        if (item.skuCode === this.skuCode) {
          this.price = (item.price * this.count).toString();
          this.dashPrice = (item.dashPrice * this.count).toString();
          break;
        }
      }
    }
  }

  /**
   * 该方法用于规格项点击事件
   */
  public readonly onSpecItemClick = (item: SpecItemVM): void => {
    if (!item.isSelectable) {
      return;
    }
    if (item.isSelected) {
      this.selectedSpecs.remove(item.key);
    } else {
      this.selectedSpecs.set(item.key, item.id);
    }
    this.refreshSpecViewData();
  }

  /**
   * 该方法用于初始化一个邻接矩阵
   *
   * 矩阵中存放了规格属性之间的可达关系以及库存信息
   */
  private initializeAdjacencyMatrix = (): void => {
    // 获取全量规格项
    let allSpecValues: SpecValue[] = [...this.info.specOptions.flatMap(specOption => specOption.values)];
    if (this.info.specOptionWithImage) {
      allSpecValues.push(...this.info.specOptionWithImage.values);
    }
    // 根据全量规格项构建邻接矩阵, 默认视为不可达且缺货
    allSpecValues.forEach(specA => {
      if (!this.adjacencyMatrix[specA.id]) {
        this.adjacencyMatrix[specA.id] = {};
      }
      allSpecValues.forEach(specB => {
        this.adjacencyMatrix[specA.id][specB.id] = {
          canSelect: new HashSet(),
          inStock: new HashSet()
        }
      });
    });
    // 根据 SKU 列表, 写入矩阵初始状态
    this.info.skuItems.forEach(sku => {
      const specs = sku.specs;
      const specKeys = Object.keys(specs);
      const inStock = sku.stock > 0;
      specKeys.forEach(keyA => {
        const uuidA: string = specs[keyA];
        specKeys.forEach(keyB => {
          const uuidB: string = specs[keyB];
          this.adjacencyMatrix[uuidA][uuidB].canSelect.add(sku.skuCode);
          if (inStock) {
            this.adjacencyMatrix[uuidA][uuidB].inStock.add(sku.skuCode);
          }
        });
      });
    });
  };

  /**
   * 生成商品规格视图数据
   */
  private generateSpecViewData = (): void => {
    const view: SpecViewData = [];
    if (this.info.specOptionWithImage) {
      const key: string = this.info.specOptionWithImage.key;
      const specItems: SpecItemVM[] = [];
      this.info.specOptionWithImage.values.forEach(value => {
        const item: SpecItemVM = new SpecItemVM();
        item.key = key;
        item.type = 'image_text';
        item.id = value.id;
        item.text = value.text;
        item.image = value.image;
        specItems.push(item);
      });
      view.push([this.info.specOptionWithImage.key, specItems]);
    }
    this.info.specOptions.forEach(specOption => {
      const specItems: SpecItemVM[] = [];
      specOption.values.forEach(value => {
        const item: SpecItemVM = new SpecItemVM();
        item.key = specOption.key;
        item.id = value.id;
        item.text = value.text;
        specItems.push(item);
      });
      view.push([specOption.key, specItems]);
    });
    this.specViewData = view;
  }

  /**
   * 根据当前已选择的规格项, 刷新商品规格视图数据
   */
  private refreshSpecViewData = (): void => {
    let banner: ResourceStr = this.info.defaultBanner;
    let isOutOfStock: boolean = false;
    this.specViewData.forEach(v => {
      const key: string = v[0];
      const items: SpecItemVM[] = v[1];
      const needRefreshBanner: boolean = this.info.specOptionWithImage?.key === key;
      items.forEach(item => {
        let canSelect: boolean = true;
        let inStock: boolean = true;
        let isSelected: boolean = false;
        let intersectionForSelect: HashSet<string> = this.adjacencyMatrix[item.id][item.id].canSelect;
        let intersectionForStock: HashSet<string> = this.adjacencyMatrix[item.id][item.id].inStock;
        for (let selectKey of this.selectedSpecs.keys()) {
          const uuid: string = this.selectedSpecs.get(selectKey);
          if (selectKey === key) {
            if (uuid === item.id) {
              isSelected = true;
              if (needRefreshBanner) {
                banner = item.image ?? '';
              }
              if (intersectionForStock.isEmpty()) {
                isOutOfStock = true;
              }
            }
            continue;
          }
          const status: SpecStatus = this.adjacencyMatrix[item.id][uuid];
          intersectionForSelect = this.getIntersectionOfSets(intersectionForSelect, status.canSelect);
          intersectionForStock = this.getIntersectionOfSets(intersectionForStock, status.inStock);
        }
        if (intersectionForSelect.isEmpty()) {
          canSelect = false;
        }
        if (intersectionForStock.isEmpty()) {
          inStock = false;
        }
        item.isSelectable = canSelect;
        item.isInStock = inStock;
        item.isSelected = isSelected;
      });
    });
    this.banner = banner;
    this.isOutOfStock = isOutOfStock;
    this.update();
  }

  private update = (): void => {
    // 尝试寻找 sku
    let skuCode: string = '';
    const all: number = this.info.specOptions.length + (this.info.specOptionWithImage === null ? 0 : 1);
    if (this.selectedSpecs.length === all) {
      const uuids: string[] = [];
      for (let uuid of this.selectedSpecs.values()) {
        uuids.push(uuid);
      }
      const intersection: HashSet<string> = this.getIntersectionOfSets(...uuids.flatMap(uuid => {
        return this.adjacencyMatrix[uuid][uuid].canSelect;
      }));
      if (intersection.length === 1) {
        skuCode = intersection.values().next().value;
      }
    }
    this.count = 1;
    if (skuCode === '') {
      this.skuCode = null;
      this.priceRemark = '实付';
      this.price = this.info.basicPrice;
      this.priceRange = this.info.priceRange;
    } else {
      this.skuCode = skuCode;
      this.priceRemark = this.info.priceRemark;
      for (let item of this.info.skuItems) {
        if (item.skuCode === skuCode) {
          this.price = item.price.toString();
          this.skuStock = item.stock;
          this.dashPrice = item.dashPrice.toString();
          break;
        }
      }
    }
  }

  private getIntersectionOfSets(...sets: HashSet<string>[]): HashSet<string> {
    if (sets.length === 0) {
      return new HashSet();
    }
    let intersection: HashSet<string> = this.margeSets(sets[0]);
    for (let i: number = 1; i < sets.length; i++) {
      const updatedIntersection: HashSet<string> = new HashSet();
      for (let item of intersection) {
        if (sets[i].has(item)) {
          updatedIntersection.add(item);
        }
      }
      intersection = updatedIntersection;
    }
    return intersection;
  }

  private margeSets(...sets: HashSet<string>[]): HashSet<string> {
    const mergedSet: HashSet<string> = new HashSet();
    for (let set of sets) {
      for (let item of set) {
        mergedSet.add(item);
      }
    }
    return mergedSet;
  }

  constructor(info: ProductSelectionInfo) {
    this.info = info;
    this.initializeAdjacencyMatrix();
    this.generateSpecViewData();
    this.refreshSpecViewData();
  }
}
