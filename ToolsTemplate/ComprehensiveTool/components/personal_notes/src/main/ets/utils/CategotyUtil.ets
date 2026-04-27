import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Category } from '../models/Category';

export function initCategoryList(): Array<Category>{
  let categoryList: Array<Category> = [];
  categoryList.push(new Category('全部笔记', 0, '-1',));
  return categoryList;
}

@ObservedV2
export class CategoryUtil {
  private static _instance: CategoryUtil;

  public static get instance() {
    if (!CategoryUtil._instance) {
      CategoryUtil._instance = new CategoryUtil();
    }
    return CategoryUtil._instance;
  }

  /**
   * 初始化分类数据
   */
  @Trace private categoryList: Array<Category> = initCategoryList();

  @Trace private currentCategory: Category = this.categoryList[0];
  /**
   * 获取所有分类列表
   * @returns 所有分类列表
   */
  getCategoryList(): Array<Category> {
    return this.categoryList;
  }

  /**
   * 获取所有分类列表
   * @returns 所有分类列表
   */
  getCategoryById(id: string): Category | undefined {
    return this.categoryList.find((item) => item.id === id);
  }
  getFirstCategory(): Category {
    return this.categoryList[0];
  }

  getCurrentCategory(): Category {
    return this.currentCategory;
  }

  setCurrentCategory(category: Category) {
    this.currentCategory = category
  }

  /**
   * 增加分类
   * @param category 待新增的分类
   */
  addCategory(category: Category): boolean {
    let sameNameCategory = this.categoryList.find((item) => item.name === category.name);
    if (sameNameCategory) {
      ToastDialog.showToast({
        message: '已存在相同名称的分类，请重新创建 ~',
        duration: 1500,
        toastAlignment: DialogAlignment.Center
      })
      return false;
    }
    this.categoryList.push(category);
    return true;
  }

  /**
   * 删除分类id指定位置的分类
   * @param index 索引位置
   */
  deleteCategoryById(categoryId: string): void {
    let index = this.categoryList.findIndex((item) => item.id === categoryId);
    this.categoryList.splice(index, 1);
  }

  /**
   * 移动分类
   * @param originalCategoryId 源分类Id
   * @param targetCategoryId 目标分类Id
   */
  moveCategory(originalCategoryId: string, targetCategoryId: string){
    if (originalCategoryId === targetCategoryId) {
      return;
    }

    if (originalCategoryId !== '-1') {
      let originalCategory = this.getCategoryById(originalCategoryId);
      if (originalCategory) {
        originalCategory.totalCount--;
      }
    }

    let targetCategory = this.getCategoryById(targetCategoryId);
    if (targetCategory) {
      if (targetCategory.id !== '-1') {
        targetCategory.totalCount++;
      }
    }
  }

}