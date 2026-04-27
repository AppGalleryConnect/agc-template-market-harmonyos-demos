import { CategoryItem, CategoryList, ItemInfo, LayoutType } from 'category_list';
import { HotelListPageVM } from '../viewmodel/HotelListPageVM';

@ComponentV2
export struct LocationDialog {
  @Param @Require currentCity: string
  @Param @Require vm: HotelListPageVM
  @Local themeColor: ResourceColor = '#333333'
  @Local tabList: CategoryItem[] = [{
    id: '1',
    label: '热门',
    subCategoryId: ['1001', '1002'],
  }, {
    id: '2',
    label: '景点',
    subCategoryId: ['2001', '2002', '2003', '2004'],
  }]
  @Local list1: ItemInfo[] = [
    {
      id: '1001',
      title: '南京南站',
    }, {
    id: '1002',
    title: '夫子庙',
  },
    {
      id: '1003',
      title: '南京站',
    },
    {
      id: '1004',
      title: '新街口',
    },
    {
      id: '1005',
      title: '禄口机场',
    },
    {
      id: '1006',
      title: '红山动物园',
    },
    {
      id: '1007',
      title: '总统府',
    },
    {
      id: '1008',
      title: '中山陵',
    },
    {
      id: '1009',
      title: '南京站',
    },
    {
      id: '1010',
      title: '南京北站',
    }
  ]
  @Local list2: ItemInfo[] = [{
    id: '2001',
    title: '玄武湖',
  }, {
    id: '2002',
    title: '栖霞山',
  }];
  @Local recipeCategoryList: ItemInfo[] = []
  @Param contentArr: string[] = []
  @Param selectIntelligentIndex: number = 0
  @Event onSearchClick: (data?: string) => void = () => {

  };
  @Event clear: () => void = () => {
  }

  aboutToAppear(): void {
    if (this.currentCity === '南京市') {
      this.recipeCategoryList = this.list1
    } else if (this.currentCity === '北京市') {
      this.recipeCategoryList = [
        {
          id: '1001',
          title: '北京站',
        }
      ]
    } else if (this.currentCity === '东京') {
      this.recipeCategoryList = [
        {
          id: '1001',
          title: '东京站',
        },
        {
          id: '1002',
          title: '银座商圈',
        },
        {
          id: '1003',
          title: '东京塔',
        },
        {
          id: '1004',
          title: '新宿商圈',
        },
        {
          id: '1005',
          title: '迪士尼乐园',
        },
        {
          id: '1006',
          title: '赤坂商圈',
        },
        {
          id: '1007',
          title: '池袋商圈',
        },
        {
          id: '1008',
          title: '浅草寺',
        }
      ]
    }
  }

  getProductList(tabItem: CategoryItem) {
    switch (tabItem.id) {
      case '1':
        this.recipeCategoryList = this.list1;
        break;
      case '2':
        this.recipeCategoryList = this.list2;
        break;
      default:
        this.recipeCategoryList = [];
        break;
    }
  }

  build() {
    CategoryList({
      categoryTabs: this.tabList,
      productList: this.recipeCategoryList,
      initIndex: this.vm.currentIndex,
      initSubIndex: this.vm.currentSubIndex,
      layoutType: LayoutType.GRID,
      themeColor: this.themeColor,
      tabBarScroller: new Scroller(),
      subBarScroller: new Scroller(),
      scroller: new Scroller(),
      onTabClick: (tabItem: CategoryItem,index: number) => {
        this.vm.currentSubIndex = -1
        this.vm.currentIndex = index
        this.getProductList(tabItem)
      },
      onTabClickItem: (index:number) => {
        this.vm.currentSubIndex = index
      },
      onSearch: (itemDetail?: ItemInfo) => {
        this.onSearchClick(itemDetail?.title)
      },
      clear:() => {
        this.vm.currentSubIndex = -1
        this.clear()
      }
    }).backgroundColor('#FFFFFF').height('60%').borderRadius({ bottomLeft: 24, bottomRight: 24 })

  }
}