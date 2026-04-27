import { LinkCategory, RecipeBriefInfo, RecipeCategory } from 'category_list';

@ComponentV2
export struct FilterDialog {
  @Param @Require selectedItems: Set<string>
  @Local currentIndex: number = 0
  @Local recipeCategoryList: RecipeCategory[] = [{
    id: '1',
    name: '住宿类型',
    recipeList: [
      { id: '1001', title: '青旅/客栈' } as RecipeBriefInfo,
      { id: '1002', title: '民宿' } as RecipeBriefInfo,
      { id: '1003', title: '公寓' } as RecipeBriefInfo,
      { id: '1004', title: '度假酒店' } as RecipeBriefInfo,
      { id: '1005', title: '别墅' } as RecipeBriefInfo,
      { id: '1006', title: '特色住宿' } as RecipeBriefInfo,
      { id: '1007', title: '主题酒店' } as RecipeBriefInfo,
      { id: '1008', title: '精品酒店' } as RecipeBriefInfo,
    ],
  }, {
    id: '2',
    name: '品牌',
    recipeList: [
      { id: '2001', title: '桔子水晶' } as RecipeBriefInfo,
      { id: '2002', title: '希尔顿' } as RecipeBriefInfo,
      { id: '2003', title: '全季' } as RecipeBriefInfo,
      { id: '2004', title: '如家' } as RecipeBriefInfo,
      { id: '2005', title: '汉庭' } as RecipeBriefInfo,
      { id: '2006', title: '宜必思' } as RecipeBriefInfo
    ],
  },
    {
      id: '3',
      name: '设施',
      recipeList: [
        { id: '3001', title: '免费停车' } as RecipeBriefInfo,
        { id: '3002', title: '接机服务' } as RecipeBriefInfo,
        { id: '3003', title: '洗衣房' } as RecipeBriefInfo,
        { id: '3004', title: '停车场' } as RecipeBriefInfo,
        { id: '3005', title: '室内泳池' } as RecipeBriefInfo,
        { id: '3006', title: '健身房' } as RecipeBriefInfo
      ],
    }]
  @Event searchHotel: (data: Set<string>) => void = () => {

  };

  build() {
    LinkCategory({
      recipeCategoryList: this.recipeCategoryList,
      currentIndex: this.currentIndex,
      selectedItems: this.selectedItems,
      onRecipeClick: (listItem, categoryName) => {
        // 筛选项点击事件 - 支持多选
        const key = `${categoryName}_${listItem.title}`
        const isAllOption = listItem.title === '全部'

        if (this.selectedItems.has(key)) {
          // 已选中，取消选中
          this.selectedItems.delete(key)
        } else {
          // 未选中，添加选中
          if (isAllOption) {
            // 如果点击的是"全部"，清除该分类下的其他所有选项
            const keysToDelete: string[] = []
            this.selectedItems.forEach((selectedKey) => {
              if (selectedKey.startsWith(`${categoryName}_`) && selectedKey !== key) {
                keysToDelete.push(selectedKey)
              }
            })
            keysToDelete.forEach(k => this.selectedItems.delete(k))
          } else {
            // 如果点击的是其他选项，取消该分类下的"全部"选项
            const allKey = `${categoryName}_全部`
            if (this.selectedItems.has(allKey)) {
              this.selectedItems.delete(allKey)
            }
          }

          this.selectedItems.add(key)
        }
      },
      changeCurrentIndex: (index: number) => {
        // 点击分类标签切换index事件
        this.currentIndex = index
      },
      onSearch: () => {
        // 按条件搜索
        this.searchHotel(this.selectedItems)
      },
    }).backgroundColor('#FFFFFF').height('60%').borderRadius({ bottomLeft: 24, bottomRight: 24 })
  }
}