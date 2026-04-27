import { PopViewUtil } from 'module_ui_base';
import { FILTER_TYPE_LIST } from '../commons/Constants';
import { ProductFilterOptions } from '../commons/Types';
import { buildProductFilter } from '../views/ProductFilterView';

export class ProductFilter {
  public static show(options: ProductFilterOptions, uiContext: UIContext) {
    PopViewUtil.openSheet(
      wrapBuilder(buildProductFilter),
      {
        title: { title: '筛选' },
        detents: [SheetSize.LARGE, SheetSize.MEDIUM],
        preferType: SheetType.CENTER,
        dragBar: true,
      },
      {
        filterTypeList: options.filterTypeList ?? FILTER_TYPE_LIST,
        initFilter: options?.initFilter ?? [],
        handleConfirm: (res) => {
          options.handleConfirm?.(res);
          ProductFilter.hide();
        },
      } as ProductFilterOptions,
      uiContext,
    );
  }

  public static hide() {
    PopViewUtil.closeSheet();
  }
}