import { RecipeBriefInfo, RecipeCategory, RecipeDetail, UploadRecipeBody } from '../../types/Recipe';

const categoryList: Array<RecipeCategory> = [
  { id: 1, name: '热门菜肴', recipeList: [] },
  { id: 2, name: '家常菜', recipeList: [] },
  { id: 3, name: '下饭菜', recipeList: [] },
  { id: 4, name: '快手菜', recipeList: [] },
  { id: 5, name: '减脂餐', recipeList: [] },
  { id: 6, name: '肉类', recipeList: [] },
  { id: 7, name: '海鲜', recipeList: [] },
  { id: 8, name: '蔬菜', recipeList: [] },
  { id: 9, name: '豆制品', recipeList: [] },
]

const recipList: Array<RecipeDetail> = [
  {
    id: 1,
    title: '西红柿牛腩',
    description: '牛肉软烂，汤汁浓郁，酸甜可口。',
    category: '肉类、家常菜、下饭菜、热门菜肴',
    cookingTime: 90,
    difficulty: '中等',
    author: '炖菜高手',
    authorAvatar: 'avatar2',
    ingredients: [
      {
        name: '牛腩',
        quantity: '500',
        unit: '克',
      },
      {
        name: '西红柿',
        quantity: '3',
        unit: '个',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '八角',
        quantity: '2',
        unit: '个',
      },
      {
        name: '桂皮',
        quantity: '1小块',
        unit: '',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '牛腩切块，焯水捞出洗净。',
      },
      {
        stepNumber: 2,
        description: '西红柿切块，葱姜蒜切末。',
      },
      {
        stepNumber: 3,
        description: '锅中倒油，放入葱姜蒜、八角、桂皮炒香。',
      },
      {
        stepNumber: 4,
        description: '加入牛腩块翻炒，加入料酒、生抽继续翻炒。',
      },
      {
        stepNumber: 5,
        description: '加入适量清水，没过牛腩，大火煮开后转小火焖煮1小时。',
      },
      {
        stepNumber: 6,
        description: '加入西红柿块，继续焖煮30分钟，加入盐调味。',
      },
    ],
    thumbnail: 'thumbnail12',
    views: 1250,
    likes: 850,
  },
  {
    id: 2,
    title: '可乐鸡翅',
    description: '色泽红亮，甜香可口的家常美食。',
    category: '肉类、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 30,
    difficulty: '简单',
    author: '美食新手',
    authorAvatar: 'avatar1',
    ingredients: [
      {
        name: '鸡翅',
        quantity: '500',
        unit: '克',
      },
      {
        name: '可乐',
        quantity: '1',
        unit: '罐',
      },
      {
        name: '生抽',
        quantity: '1',
        unit: '汤匙',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '鸡翅洗净，在鸡翅上划几刀。',
      },
      {
        stepNumber: 2,
        description: '锅中倒水，放入鸡翅，加入料酒，焯水捞出。',
      },
      {
        stepNumber: 3,
        description: '锅中倒油，放入鸡翅，煎至两面金黄。',
      },
      {
        stepNumber: 4,
        description:
        '倒入可乐，没过鸡翅，加入生抽，大火煮开后转小火焖煮20分钟。',
      },
      {
        stepNumber: 5,
        description: '大火收汁。',
      },
    ],
    thumbnail: 'thumbnail13',
    views: 900,
    likes: 600,
  },
  {
    id: 3,
    title: '宫保鸡丁',
    description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。',
    category: '肉类、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 30,
    difficulty: '中等',
    author: '美食小厨',
    authorAvatar: 'avatar4',
    ingredients: [
      {
        name: '鸡胸肉',
        quantity: '250',
        unit: '克',
      },
      {
        name: '花生米',
        quantity: '50',
        unit: '克',
      },
      {
        name: '胡萝卜',
        quantity: '1',
        unit: '根',
      },
      {
        name: '黄瓜',
        quantity: '1',
        unit: '根',
      },
      {
        name: '干辣椒',
        quantity: '5',
        unit: '个',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '料酒',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '醋',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '糖',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '淀粉',
        quantity: '1',
        unit: '汤匙',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '将鸡胸肉洗净切丁，加入料酒、生抽、淀粉，抓匀腌制15分钟。',
      },
      {
        stepNumber: 2,
        description: '胡萝卜、黄瓜切丁，葱姜蒜切末，干辣椒切段备用。',
      },
      {
        stepNumber: 3,
        description: '调一碗料汁，将生抽、醋、糖、盐和适量清水混合均匀。',
      },
      {
        stepNumber: 4,
        description: '锅中倒油，油热后放入腌制好的鸡丁滑炒至变色盛出。',
      },
      {
        stepNumber: 5,
        description: '锅中留少许底油，放入葱姜蒜末、干辣椒段炒香。',
      },
      {
        stepNumber: 6,
        description: '加入胡萝卜丁翻炒至断生。',
      },
      {
        stepNumber: 7,
        description: '放入黄瓜丁继续翻炒。',
      },
      {
        stepNumber: 8,
        description: '倒入炒好的鸡丁，翻炒均匀。',
      },
      {
        stepNumber: 9,
        description: '倒入调好的料汁，翻炒至汤汁浓稠。',
      },
      {
        stepNumber: 10,
        description: '最后加入花生米，翻炒几下即可出锅。',
      },
    ],
    thumbnail: 'thumbnail1',
    views: 1200,
    likes: 800,
  },
  {
    id: 4,
    title: '鱼香肉丝',
    description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。',
    category: '肉类、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 25,
    difficulty: '中等',
    author: '川菜大厨',
    authorAvatar: 'avatar5',
    ingredients: [
      {
        name: '猪里脊肉',
        quantity: '200',
        unit: '克',
      },
      {
        name: '木耳',
        quantity: '50',
        unit: '克',
      },
      {
        name: '胡萝卜',
        quantity: '1',
        unit: '根',
      },
      {
        name: '青椒',
        quantity: '1',
        unit: '个',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '泡椒',
        quantity: '10',
        unit: '个',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '醋',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '糖',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '淀粉',
        quantity: '1',
        unit: '汤匙',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '猪里脊肉切丝，用生抽、淀粉腌制15分钟。',
      },
      {
        stepNumber: 2,
        description: '木耳泡发切丝，胡萝卜、青椒切丝，葱姜蒜切末。',
      },
      {
        stepNumber: 3,
        description: '调一碗料汁，将生抽、醋、糖、盐和适量清水混合。',
      },
      {
        stepNumber: 4,
        description: '锅中倒油，油热后放入腌制好的肉丝滑炒至变色盛出。',
      },
      {
        stepNumber: 5,
        description: '锅中留底油，放入葱姜蒜末、泡椒炒香。',
      },
      {
        stepNumber: 6,
        description: '加入木耳丝、胡萝卜丝、青椒丝翻炒。',
      },
      {
        stepNumber: 7,
        description: '倒入炒好的肉丝，翻炒均匀。',
      },
      {
        stepNumber: 8,
        description: '倒入调好的料汁，翻炒至汤汁浓稠。',
      },
    ],
    thumbnail: 'thumbnail3',
    views: 1000,
    likes: 700,
  },
  {
    id: 5,
    title: '糖醋排骨',
    description: '色泽红亮，口味酸甜的经典家常菜。',
    category: '肉类、家常菜、下饭菜、热门菜肴',
    cookingTime: 40,
    difficulty: '中等',
    author: '家常美食家',
    authorAvatar: 'avatar6',
    ingredients: [
      {
        name: '排骨',
        quantity: '500',
        unit: '克',
      },
      {
        name: '冰糖',
        quantity: '30',
        unit: '克',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '醋',
        quantity: '3',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '排骨焯水，捞出洗净。',
      },
      {
        stepNumber: 2,
        description: '锅中放少许油，放入冰糖，小火炒出糖色。',
      },
      {
        stepNumber: 3,
        description: '放入排骨翻炒，使其均匀裹上糖色。',
      },
      {
        stepNumber: 4,
        description: '加入葱姜蒜、料酒、生抽翻炒。',
      },
      {
        stepNumber: 5,
        description: '加入适量清水，没过排骨，大火煮开后转小火焖煮30分钟。',
      },
      {
        stepNumber: 6,
        description: '加入醋、盐，大火收汁。',
      },
    ],
    thumbnail: 'thumbnail5',
    views: 1100,
    likes: 750,
  },
  {
    id: 6,
    title: '红烧肉',
    description: '肥而不腻、色泽红亮的经典热门菜肴。',
    category: '肉类、家常菜、下饭菜、热门菜肴',
    cookingTime: 60,
    difficulty: '中等',
    author: '美食达人',
    authorAvatar: 'avatar7',
    ingredients: [
      {
        name: '五花肉',
        quantity: '500',
        unit: '克',
      },
      {
        name: '冰糖',
        quantity: '20',
        unit: '克',
      },
      {
        name: '生抽',
        quantity: '3',
        unit: '汤匙',
      },
      {
        name: '老抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '八角',
        quantity: '2',
        unit: '个',
      },
      {
        name: '桂皮',
        quantity: '1小块',
        unit: '',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '五花肉切块，焯水捞出洗净。',
      },
      {
        stepNumber: 2,
        description: '锅中放少许油，放入冰糖，小火炒出糖色。',
      },
      {
        stepNumber: 3,
        description: '放入五花肉块翻炒，使其均匀裹上糖色。',
      },
      {
        stepNumber: 4,
        description: '加入葱姜蒜、八角、桂皮、料酒、生抽、老抽翻炒。',
      },
      {
        stepNumber: 5,
        description:
        '加入适量清水，没过五花肉，大火煮开后转小火焖煮40 - 50分钟。',
      },
      {
        stepNumber: 6,
        description: '大火收汁。',
      },
    ],
    thumbnail: 'thumbnail6',
    views: 1300,
    likes: 850,
  },
  {
    id: 7,
    title: '回锅肉',
    description: '经典川菜，肉片肥而不腻，香辣可口。',
    category: '肉类、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 30,
    difficulty: '中等',
    author: '川菜行家',
    authorAvatar: 'avatar8',
    ingredients: [
      {
        name: '五花肉',
        quantity: '300',
        unit: '克',
      },
      {
        name: '青椒',
        quantity: '1',
        unit: '个',
      },
      {
        name: '红椒',
        quantity: '1',
        unit: '个',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '豆瓣酱',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '生抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '1',
        unit: '汤匙',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '五花肉冷水下锅，加入葱姜、料酒，煮熟捞出切片。',
      },
      {
        stepNumber: 2,
        description: '青椒、红椒切块，葱姜蒜切末。',
      },
      {
        stepNumber: 3,
        description: '锅中放少许油，放入五花肉片煸炒出油。',
      },
      {
        stepNumber: 4,
        description: '放入葱姜蒜末、豆瓣酱炒香。',
      },
      {
        stepNumber: 5,
        description: '加入生抽翻炒均匀。',
      },
      {
        stepNumber: 6,
        description: '加入青椒、红椒块翻炒至断生。',
      },
    ],
    thumbnail: 'thumbnail9',
    views: 1050,
    likes: 750,
  },
  {
    id: 8,
    title: '清蒸鱼',
    description: '清淡鲜美，保留鱼的原汁原味，营养丰富。',
    category: '海鲜、家常菜、减脂餐、热门菜肴',
    cookingTime: 20,
    difficulty: '简单',
    author: '海鲜大厨',
    authorAvatar: 'avatar9',
    ingredients: [
      {
        name: '鲈鱼',
        quantity: '1',
        unit: '条',
      },
      {
        name: '葱',
        quantity: '2',
        unit: '根',
      },
      {
        name: '姜',
        quantity: '1',
        unit: '块',
      },
      {
        name: '蒸鱼豉油',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '将鱼处理干净，在鱼身上划几刀，用盐腌制 5 分钟。',
      },
      {
        stepNumber: 2,
        description: '葱切丝，姜一半切丝，一半切片，将姜片放入鱼肚和划刀处。',
      },
      {
        stepNumber: 3,
        description: '锅中加水烧开，将鱼放入蒸锅中，大火蒸 10 - 12 分钟。',
      },
      {
        stepNumber: 4,
        description: '取出蒸好的鱼，倒掉盘中多余的汁水，放上葱丝和姜丝。',
      },
      {
        stepNumber: 5,
        description: '淋上蒸鱼豉油，再浇上热油即可。',
      },
    ],
    thumbnail: 'thumbnail7',
    views: 900,
    likes: 700,
  },
  {
    id: 9,
    title: '油焖大虾',
    description: '色泽红亮，虾肉鲜嫩，味道浓郁。',
    category: '海鲜、家常菜、下饭菜、热门菜肴',
    cookingTime: 15,
    difficulty: '中等',
    author: '美食爱好者',
    authorAvatar: 'avatar10',
    ingredients: [
      {
        name: '大虾',
        quantity: '500',
        unit: '克',
      },
      {
        name: '葱',
        quantity: '1',
        unit: '根',
      },
      {
        name: '姜',
        quantity: '1',
        unit: '块',
      },
      {
        name: '蒜',
        quantity: '2',
        unit: '瓣',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '老抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '白糖',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '将大虾洗净，挑去虾线，在虾背上划一刀。',
      },
      {
        stepNumber: 2,
        description: '葱、姜、蒜切末备用。',
      },
      {
        stepNumber: 3,
        description: '锅中倒油，油热后放入大虾煎至两面变红，盛出备用。',
      },
      {
        stepNumber: 4,
        description: '锅中留少许底油，放入葱、姜、蒜末炒香。',
      },
      {
        stepNumber: 5,
        description: '加入生抽、老抽、白糖、料酒和适量清水，煮开后放入大虾。',
      },
      {
        stepNumber: 6,
        description: '小火焖煮 3 - 5 分钟，至汤汁浓稠，根据口味加盐调味。',
      },
    ],
    thumbnail: 'thumbnail10',
    views: 1000,
    likes: 800,
  },
  {
    id: 10,
    title: '辣炒花蛤',
    description: '香辣可口，是一道下酒好菜。',
    category: '海鲜、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 10,
    difficulty: '简单',
    author: '美食新手',
    authorAvatar: 'avatar1',
    ingredients: [
      {
        name: '花蛤',
        quantity: '500',
        unit: '克',
      },
      {
        name: '葱',
        quantity: '1',
        unit: '根',
      },
      {
        name: '姜',
        quantity: '1',
        unit: '块',
      },
      {
        name: '蒜',
        quantity: '2',
        unit: '瓣',
      },
      {
        name: '干辣椒',
        quantity: '3',
        unit: '个',
      },
      {
        name: '花椒',
        quantity: '适量',
        unit: '',
      },
      {
        name: '生抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '料酒',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '将花蛤放入清水中，滴几滴香油，让花蛤吐尽泥沙，然后洗净。',
      },
      {
        stepNumber: 2,
        description: '葱、姜、蒜切末，干辣椒切段。',
      },
      {
        stepNumber: 3,
        description: '锅中加水烧开，放入花蛤焯水至开口，捞出沥干水分。',
      },
      {
        stepNumber: 4,
        description: '锅中倒油，油热后放入花椒、干辣椒炒香，捞出花椒和干辣椒。',
      },
      {
        stepNumber: 5,
        description: '放入葱、姜、蒜末炒香，加入花蛤翻炒。',
      },
      {
        stepNumber: 6,
        description: '加入生抽、料酒翻炒均匀，根据口味加盐调味。',
      },
    ],
    thumbnail: 'thumbnail21',
    views: 850,
    likes: 650,
  },
  {
    id: 11,
    title: '蒜蓉粉丝蒸扇贝',
    description: '粉丝吸收了扇贝的鲜味和蒜蓉的香味，口感丰富。',
    category: '海鲜、家常菜、减脂餐、热门菜肴',
    cookingTime: 15,
    difficulty: '中等',
    author: '美食博主',
    authorAvatar: 'avatar2',
    ingredients: [
      {
        name: '扇贝',
        quantity: '6',
        unit: '个',
      },
      {
        name: '粉丝',
        quantity: '50',
        unit: '克',
      },
      {
        name: '蒜',
        quantity: '3',
        unit: '瓣',
      },
      {
        name: '葱',
        quantity: '1',
        unit: '根',
      },
      {
        name: '生抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '蚝油',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '将扇贝洗净，撬开贝壳，取出贝肉，洗净贝壳和贝肉。',
      },
      {
        stepNumber: 2,
        description: '粉丝用温水泡软，沥干水分，铺在贝壳上。',
      },
      {
        stepNumber: 3,
        description: '蒜切末，葱切丝备用。',
      },
      {
        stepNumber: 4,
        description:
        '锅中倒油，油热后放入蒜末炒香，加入生抽、蚝油、盐调味，制成蒜蓉酱。',
      },
      {
        stepNumber: 5,
        description: '将贝肉放在粉丝上，淋上蒜蓉酱。',
      },
      {
        stepNumber: 6,
        description: '锅中加水烧开，将扇贝放入蒸锅中，大火蒸 8 - 10 分钟。',
      },
      {
        stepNumber: 7,
        description: '取出蒸好的扇贝，撒上葱丝，浇上热油即可。',
      },
    ],
    thumbnail: 'thumbnail22',
    views: 950,
    likes: 750,
  },
  {
    id: 12,
    title: '海鲜豆腐煲',
    description: '豆腐嫩滑，海鲜鲜美，营养丰富。',
    category: '海鲜、豆制品、家常菜、下饭菜、热门菜肴',
    cookingTime: 25,
    difficulty: '中等',
    author: '烹饪达人',
    authorAvatar: 'avatar3',
    ingredients: [
      {
        name: '豆腐',
        quantity: '1',
        unit: '块',
      },
      {
        name: '鲜虾',
        quantity: '100',
        unit: '克',
      },
      {
        name: '鱿鱼',
        quantity: '100',
        unit: '克',
      },
      {
        name: '蛤蜊',
        quantity: '100',
        unit: '克',
      },
      {
        name: '葱',
        quantity: '1',
        unit: '根',
      },
      {
        name: '姜',
        quantity: '1',
        unit: '块',
      },
      {
        name: '蒜',
        quantity: '2',
        unit: '瓣',
      },
      {
        name: '生抽',
        quantity: '2',
        unit: '汤匙',
      },
      {
        name: '蚝油',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '豆腐切块，鲜虾去头去壳挑虾线，鱿鱼洗净切花刀，蛤蜊吐沙洗净。',
      },
      {
        stepNumber: 2,
        description: '葱、姜、蒜切末备用。',
      },
      {
        stepNumber: 3,
        description: '锅中倒油，油热后放入豆腐块煎至两面金黄，盛出备用。',
      },
      {
        stepNumber: 4,
        description: '锅中再倒少许油，放入葱、姜、蒜末炒香。',
      },
      {
        stepNumber: 5,
        description: '加入鲜虾、鱿鱼翻炒至变色，再加入蛤蜊翻炒至开口。',
      },
      {
        stepNumber: 6,
        description: '加入生抽、蚝油和适量清水，煮开后放入煎好的豆腐块。',
      },
      {
        stepNumber: 7,
        description: '小火焖煮 10 - 15 分钟，至汤汁浓稠，根据口味加盐调味。',
      },
    ],
    thumbnail: 'thumbnail23',
    views: 920,
    likes: 720,
  },
  {
    id: 13,
    title: '清炒西兰花',
    description: '一道清爽可口的素菜，西兰花营养丰富。',
    category: '蔬菜、家常菜、快手菜、减脂餐、热门菜肴',
    cookingTime: 15,
    difficulty: '简单',
    author: '美食爱好者',
    authorAvatar: 'avatar4',
    ingredients: [
      { name: '西兰花', quantity: '1', unit: '颗' },
      { name: '蒜', quantity: '3', unit: '瓣' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '10', unit: '毫升' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '西兰花切成小朵，用淡盐水浸泡 15 分钟左右，然后洗净备用。',
      },
      { stepNumber: 2, description: '蒜切末备用。' },
      {
        stepNumber: 3,
        description:
        '锅中烧开水，加入少许盐和几滴食用油，放入西兰花焯水 1 - 2 分钟，至西兰花变色后捞出，沥干水分。',
      },
      {
        stepNumber: 4,
        description: '锅中倒入适量食用油，油热后放入蒜末爆香。',
      },
      {
        stepNumber: 5,
        description:
        '加入西兰花翻炒均匀，加入适量盐和生抽调味，继续翻炒片刻即可出锅。',
      },
    ],
    thumbnail: 'thumbnail24',
    views: 500,
    likes: 200,
  },
  {
    id: 14,
    title: '醋溜白菜',
    description: '酸甜可口，开胃下饭的醋溜白菜。',
    category: '蔬菜、家常菜、快手菜、减脂餐、热门菜肴',
    cookingTime: 12,
    difficulty: '简单',
    author: '美食达人',
    authorAvatar: 'avatar5',
    ingredients: [
      { name: '白菜帮', quantity: '200', unit: '克' },
      { name: '白菜叶', quantity: '100', unit: '克' },
      { name: '干辣椒', quantity: '3', unit: '个' },
      { name: '蒜', quantity: '2', unit: '瓣' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '白糖', quantity: '15', unit: '克' },
      { name: '香醋', quantity: '20', unit: '毫升' },
      { name: '生抽', quantity: '10', unit: '毫升' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '将白菜帮和白菜叶分开，白菜帮用刀斜切成片，白菜叶撕成小块，分别洗净沥干水分。',
      },
      { stepNumber: 2, description: '蒜切末，干辣椒剪成段备用。' },
      {
        stepNumber: 3,
        description:
        '调碗汁：在碗中加入盐、白糖、香醋、生抽搅拌均匀，制成碗汁备用。',
      },
      {
        stepNumber: 4,
        description: '锅中倒入适量食用油，油热后放入蒜末和干辣椒段爆香。',
      },
      {
        stepNumber: 5,
        description:
        '先放入白菜帮翻炒至稍软，再放入白菜叶继续翻炒至白菜叶变软。',
      },
      {
        stepNumber: 6,
        description:
        '倒入调好的碗汁，快速翻炒均匀，使白菜均匀裹上料汁即可出锅。',
      },
    ],
    thumbnail: 'thumbnail25',
    views: 450,
    likes: 180,
  },
  {
    id: 15,
    title: '地三鲜',
    description: '经典的东北素菜，鲜香下饭。',
    category: '蔬菜、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 25,
    difficulty: '中等',
    author: '大厨老张',
    authorAvatar: 'avatar6',
    ingredients: [
      { name: '茄子', quantity: '200', unit: '克' },
      { name: '土豆', quantity: '200', unit: '克' },
      { name: '青椒', quantity: '1', unit: '个' },
      { name: '葱', quantity: '1', unit: '段' },
      { name: '姜', quantity: '1', unit: '块' },
      { name: '蒜', quantity: '3', unit: '瓣' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '15', unit: '毫升' },
      { name: '蚝油', quantity: '10', unit: '毫升' },
      { name: '白糖', quantity: '5', unit: '克' },
      { name: '淀粉', quantity: '10', unit: '克' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '茄子洗净切滚刀块，放入盐水中浸泡 10 分钟，防止氧化变黑，然后捞出沥干水分。土豆去皮切滚刀块，放入清水中浸泡，去除表面淀粉，捞出沥干。青椒洗净切块，葱、姜、蒜切末备用。',
      },
      {
        stepNumber: 2,
        description:
        '调碗汁：在碗中加入盐、生抽、蚝油、白糖、淀粉和适量清水，搅拌均匀制成碗汁。',
      },
      {
        stepNumber: 3,
        description:
        '锅中倒入适量食用油，油热后放入土豆块炸至表面金黄，捞出沥油。再将茄子块放入油锅中炸至变软，捞出沥油。',
      },
      { stepNumber: 4, description: '锅中留少许底油，放入葱、姜、蒜末爆香。' },
      { stepNumber: 5, description: '加入青椒块翻炒至断生。' },
      { stepNumber: 6, description: '放入炸好的土豆块和茄子块，翻炒均匀。' },
      {
        stepNumber: 7,
        description:
        '倒入调好的碗汁，翻炒至汤汁浓稠，均匀包裹在食材上即可出锅。',
      },
    ],
    thumbnail: 'thumbnail8',
    views: 600,
    likes: 250,
  },
  {
    id: 16,
    title: '蒜蓉生菜',
    description: '简单易做的蒜蓉生菜，清爽解腻。',
    category: '菜、家常菜、快手菜、减脂餐、热门菜肴',
    cookingTime: 10,
    difficulty: '简单',
    author: '厨房小白',
    authorAvatar: 'avatar7',
    ingredients: [
      { name: '生菜', quantity: '2', unit: '颗' },
      { name: '蒜', quantity: '5', unit: '瓣' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '10', unit: '毫升' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      { stepNumber: 1, description: '生菜洗净，切成段备用。蒜切末备用。' },
      {
        stepNumber: 2,
        description:
        '锅中烧开水，加入少许盐和几滴食用油，放入生菜焯水 1 分钟左右，至生菜变软后捞出，沥干水分，放入盘中。',
      },
      {
        stepNumber: 3,
        description: '锅中倒入适量食用油，油热后放入蒜末爆香。',
      },
      {
        stepNumber: 4,
        description: '加入盐和生抽调味，搅拌均匀，制成蒜蓉汁。',
      },
      { stepNumber: 5, description: '将蒜蓉汁浇在生菜上即可。' },
    ],
    thumbnail: 'thumbnail27',
    views: 400,
    likes: 150,
  },
  {
    id: 17,
    title: '西红柿炒鸡蛋',
    description: '家喻户晓的家常菜，营养丰富。',
    category: '蔬菜、家常菜、快手菜、下饭菜、热门菜肴',
    cookingTime: 12,
    difficulty: '简单',
    author: '家庭主妇',
    authorAvatar: 'avatar8',
    ingredients: [
      { name: '西红柿', quantity: '2', unit: '个' },
      { name: '鸡蛋', quantity: '2 - 3', unit: '个' },
      { name: '葱', quantity: '1', unit: '段' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '白糖', quantity: '5', unit: '克' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '西红柿洗净，在顶部划十字刀，用开水烫一下，去皮后切成小块备用。葱切末备用。',
      },
      {
        stepNumber: 2,
        description: '鸡蛋打入碗中，加入少许盐，搅拌均匀备用。',
      },
      {
        stepNumber: 3,
        description:
        '锅中倒入适量食用油，油热后倒入鸡蛋液，待鸡蛋液凝固，用铲子快速翻炒，炒成小块状，盛出备用。',
      },
      {
        stepNumber: 4,
        description: '锅中再倒入少许食用油，油热后放入葱末爆香。',
      },
      {
        stepNumber: 5,
        description: '加入西红柿块翻炒，炒出汁后加入适量盐和白糖调味。',
      },
      {
        stepNumber: 6,
        description:
        '放入炒好的鸡蛋块，翻炒均匀，使鸡蛋块均匀裹上西红柿汁即可出锅。',
      },
    ],
    thumbnail: 'thumbnail2',
    views: 700,
    likes: 300,
  },
  {
    id: 18,
    title: '炒青菜',
    description: '简单清爽的家常菜，保留青菜的营养。',
    category: '蔬菜、家常菜、快手菜、减脂餐、热门菜肴',
    cookingTime: 10,
    difficulty: '简单',
    author: '美食新手',
    authorAvatar: 'avatar1',
    ingredients: [
      {
        name: '青菜',
        quantity: '300',
        unit: '克',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '食用油',
        quantity: '适量',
        unit: '',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '青菜洗净切段，葱姜蒜切末。',
      },
      {
        stepNumber: 2,
        description: '锅中倒油，放入葱姜蒜末炒香。',
      },
      {
        stepNumber: 3,
        description: '加入青菜段翻炒至断生。',
      },
      {
        stepNumber: 4,
        description: '加入盐，翻炒均匀即可出锅。',
      },
    ],
    thumbnail: 'thumbnail11',
    views: 700,
    likes: 500,
  },
  {
    id: 19,
    title: '麻婆豆腐',
    description: '麻辣鲜香的经典川菜，豆腐嫩滑。',
    category: '豆制品、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 20,
    difficulty: '中等',
    author: '川菜大师',
    authorAvatar: 'avatar4',
    ingredients: [
      {
        name: '豆腐',
        quantity: '1',
        unit: '块',
      },
      {
        name: '肉末',
        quantity: '100',
        unit: '克',
      },
      {
        name: '花椒粉',
        quantity: '适量',
        unit: '',
      },
      {
        name: '辣椒粉',
        quantity: '适量',
        unit: '',
      },
      {
        name: '葱姜蒜',
        quantity: '适量',
        unit: '',
      },
      {
        name: '生抽',
        quantity: '1',
        unit: '汤匙',
      },
      {
        name: '盐',
        quantity: '适量',
        unit: '',
      },
      {
        name: '淀粉',
        quantity: '1',
        unit: '汤匙',
      },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '豆腐切块，焯水备用。',
      },
      {
        stepNumber: 2,
        description: '葱姜蒜切末。',
      },
      {
        stepNumber: 3,
        description: '锅中倒油，放入肉末煸炒至变色。',
      },
      {
        stepNumber: 4,
        description: '加入葱姜蒜末、辣椒粉、花椒粉炒香。',
      },
      {
        stepNumber: 5,
        description: '加入生抽、适量清水，煮开。',
      },
      {
        stepNumber: 6,
        description: '放入豆腐块，小火煮5分钟。',
      },
      {
        stepNumber: 7,
        description: '用淀粉加水勾芡，汤汁浓稠后即可出锅。',
      },
    ],
    thumbnail: 'thumbnail4',
    views: 900,
    likes: 600,
  },
  {
    id: 20,
    title: '家常豆腐',
    description: '简单又美味的家常菜，豆腐外酥里嫩。',
    category: '豆制品、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 25,
    difficulty: '中等',
    author: '家庭煮妇',
    authorAvatar: 'avatar5',
    ingredients: [
      { name: '豆腐', quantity: '1', unit: '块' },
      { name: '青椒', quantity: '1', unit: '个' },
      { name: '红椒', quantity: '1', unit: '个' },
      { name: '木耳', quantity: '适量', unit: '' },
      { name: '蒜', quantity: '3', unit: '瓣' },
      { name: '姜', quantity: '1', unit: '块' },
      { name: '葱', quantity: '1', unit: '段' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '15', unit: '毫升' },
      { name: '蚝油', quantity: '10', unit: '毫升' },
      { name: '白糖', quantity: '5', unit: '克' },
      { name: '淀粉', quantity: '10', unit: '克' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      { stepNumber: 1, description: '豆腐切成薄片，用厨房纸巾吸干表面水分。' },
      {
        stepNumber: 2,
        description:
        '青椒、红椒洗净切块，木耳泡发后撕成小朵，蒜、姜切末，葱切段备用。',
      },
      {
        stepNumber: 3,
        description:
        '锅中倒入适量食用油，油热后放入豆腐片，煎至两面金黄，盛出备用。',
      },
      { stepNumber: 4, description: '锅中留少许底油，放入蒜末、姜末爆香。' },
      { stepNumber: 5, description: '加入青椒块、红椒块和木耳翻炒至断生。' },
      {
        stepNumber: 6,
        description: '加入生抽、蚝油、白糖、盐调味，翻炒均匀。',
      },
      { stepNumber: 7, description: '放入煎好的豆腐片，轻轻翻炒均匀。' },
      { stepNumber: 8, description: '用水淀粉勾芡，撒上葱段即可出锅。' },
    ],
    thumbnail: 'thumbnail17',
    views: 750,
    likes: 320,
  },
  {
    id: 21,
    title: '鲫鱼豆腐汤',
    description: '营养丰富的汤品，鱼汤奶白，豆腐入味。',
    category: '肉类、豆制品、家常菜、减脂餐、热门菜肴',
    cookingTime: 40,
    difficulty: '中等',
    author: '养生达人',
    authorAvatar: 'avatar6',
    ingredients: [
      { name: '鲫鱼', quantity: '1', unit: '条' },
      { name: '豆腐', quantity: '1', unit: '块' },
      { name: '姜片', quantity: '3', unit: '片' },
      { name: '葱段', quantity: '2', unit: '段' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '料酒', quantity: '10', unit: '毫升' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '鲫鱼处理干净，在鱼身上划几刀，用料酒和盐腌制 15 分钟。',
      },
      { stepNumber: 2, description: '豆腐切成小块备用。' },
      {
        stepNumber: 3,
        description: '锅中倒入适量食用油，油热后放入鲫鱼，煎至两面金黄。',
      },
      { stepNumber: 4, description: '加入姜片和葱段炒香。' },
      {
        stepNumber: 5,
        description:
        '加入足量的清水，大火烧开后转小火炖煮 20 分钟左右，至鱼汤变奶白色。',
      },
      {
        stepNumber: 6,
        description: '放入豆腐块，继续炖煮 10 分钟，让豆腐入味。',
      },
      { stepNumber: 7, description: '根据个人口味加入适量盐调味，即可出锅。' },
    ],
    thumbnail: 'thumbnail18',
    views: 600,
    likes: 280,
  },
  {
    id: 22,
    title: '凉拌豆腐',
    description: '清爽可口的凉拌菜，适合夏天食用。',
    category: '豆制品、家常菜、快手菜、减脂餐、热门菜肴',
    cookingTime: 10,
    difficulty: '简单',
    author: '美食博主',
    authorAvatar: 'avatar7',
    ingredients: [
      { name: '豆腐', quantity: '1', unit: '块' },
      { name: '香菜', quantity: '适量', unit: '' },
      { name: '蒜', quantity: '3', unit: '瓣' },
      { name: '生抽', quantity: '15', unit: '毫升' },
      { name: '醋', quantity: '10', unit: '毫升' },
      { name: '香油', quantity: '5', unit: '毫升' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '白糖', quantity: '5', unit: '克' },
      { name: '辣椒油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '豆腐放入开水中焯水 2 分钟，捞出沥干水分，切成小块放入碗中。',
      },
      { stepNumber: 2, description: '蒜切末，香菜洗净切段备用。' },
      {
        stepNumber: 3,
        description:
        '在碗中加入生抽、醋、香油、盐、白糖、辣椒油和蒜末，搅拌均匀制成调味汁。',
      },
      {
        stepNumber: 4,
        description: '将调味汁浇在豆腐上，撒上香菜段，搅拌均匀即可。',
      },
    ],
    thumbnail: 'thumbnail16',
    views: 500,
    likes: 220,
  },
  {
    id: 23,
    title: '千页豆腐炒肉片',
    description: '千页豆腐口感Q弹，和肉片一起炒很下饭。',
    category: '豆制品、肉类、家常菜、下饭菜、快手菜、热门菜肴',
    cookingTime: 20,
    difficulty: '中等',
    author: '资深厨师',
    authorAvatar: 'avatar8',
    ingredients: [
      { name: '千页豆腐', quantity: '200', unit: '克' },
      { name: '猪肉片', quantity: '100', unit: '克' },
      { name: '青椒', quantity: '1', unit: '个' },
      { name: '红椒', quantity: '1', unit: '个' },
      { name: '蒜', quantity: '3', unit: '瓣' },
      { name: '姜', quantity: '1', unit: '块' },
      { name: '葱', quantity: '1', unit: '段' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '15', unit: '毫升' },
      { name: '料酒', quantity: '10', unit: '毫升' },
      { name: '淀粉', quantity: '10', unit: '克' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description:
        '千页豆腐切成薄片，青椒、红椒洗净切块，蒜、姜切末，葱切段备用。',
      },
      {
        stepNumber: 2,
        description: '猪肉片加入生抽、料酒、淀粉腌制 15 分钟。',
      },
      {
        stepNumber: 3,
        description:
        '锅中倒入适量食用油，油热后放入腌制好的肉片煸炒至变色，盛出备用。',
      },
      { stepNumber: 4, description: '锅中留少许底油，放入蒜末、姜末爆香。' },
      { stepNumber: 5, description: '加入千页豆腐片翻炒至微微金黄。' },
      { stepNumber: 6, description: '加入青椒块、红椒块翻炒至断生。' },
      { stepNumber: 7, description: '放入炒好的肉片，加入盐调味，翻炒均匀。' },
      { stepNumber: 8, description: '撒上葱段即可出锅。' },
    ],
    thumbnail: 'thumbnail17',
    views: 650,
    likes: 260,
  },
  {
    id: 24,
    title: '豆腐丸子汤',
    description: '鲜美的豆腐丸子汤，丸子嫩滑，汤鲜味美。',
    category: '豆制品、家常菜、减脂餐、热门菜肴',
    cookingTime: 30,
    difficulty: '中等',
    author: '美食爱好者',
    authorAvatar: 'avatar9',
    ingredients: [
      { name: '豆腐', quantity: '1', unit: '块' },
      { name: '猪肉末', quantity: '100', unit: '克' },
      { name: '鸡蛋', quantity: '1', unit: '个' },
      { name: '淀粉', quantity: '20', unit: '克' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '10', unit: '毫升' },
      { name: '葱姜末', quantity: '适量', unit: '' },
      { name: '香菜', quantity: '适量', unit: '' },
      { name: '香油', quantity: '5', unit: '毫升' },
      { name: '胡椒粉', quantity: '适量', unit: '' },
    ],
    steps: [
      { stepNumber: 1, description: '豆腐用勺子压成泥状，放入碗中。' },
      {
        stepNumber: 2,
        description:
        '在豆腐泥中加入猪肉末、鸡蛋、淀粉、盐、生抽、葱姜末，搅拌均匀。',
      },
      { stepNumber: 3, description: '用手将混合物搓成大小均匀的丸子备用。' },
      {
        stepNumber: 4,
        description: '锅中加入适量清水，水开后放入丸子，煮至丸子浮起。',
      },
      { stepNumber: 5, description: '根据个人口味加入适量盐、胡椒粉调味。' },
      { stepNumber: 6, description: '撒上香菜段，滴入几滴香油即可出锅。' },
    ],
    thumbnail: 'thumbnail14',
    views: 550,
    likes: 240,
  },
  {
    id: 25,
    title: '香煎豆腐饼',
    description: '外酥里嫩的豆腐饼，可作为早餐或小吃。',
    category: '豆制品、家常菜、快手菜、热门菜肴',
    cookingTime: 20,
    difficulty: '中等',
    author: '宝妈',
    authorAvatar: 'avatar10',
    ingredients: [
      { name: '豆腐', quantity: '1', unit: '块' },
      { name: '胡萝卜', quantity: '半根', unit: '' },
      { name: '香菇', quantity: '3', unit: '朵' },
      { name: '鸡蛋', quantity: '1', unit: '个' },
      { name: '面粉', quantity: '30', unit: '克' },
      { name: '盐', quantity: '适量', unit: '' },
      { name: '生抽', quantity: '5', unit: '毫升' },
      { name: '葱姜末', quantity: '适量', unit: '' },
      { name: '食用油', quantity: '适量', unit: '' },
    ],
    steps: [
      {
        stepNumber: 1,
        description: '豆腐用勺子压成泥状，胡萝卜、香菇洗净切成小丁备用。',
      },
      {
        stepNumber: 2,
        description:
        '在豆腐泥中加入胡萝卜丁、香菇丁、鸡蛋、面粉、盐、生抽、葱姜末，搅拌均匀成面糊。',
      },
      {
        stepNumber: 3,
        description:
        '锅中倒入适量食用油，油热后用勺子舀一勺面糊放入锅中，摊成饼状。',
      },
      { stepNumber: 4, description: '小火煎至两面金黄，熟透即可出锅。' },
    ],
    thumbnail: 'thumbnail19',
    views: 520,
    likes: 230,
  },
];


export const getRecipeList = (): Array<RecipeDetail> => {
  return recipList;
}

export const getRecipeBriefInfoList = (): Array<RecipeBriefInfo> => {
  return recipList.map((item => {
    const recipeInfo: RecipeBriefInfo = {
      id: item.id,
      title: item.title,
      description: item.description,
      category: item.category,
      cookingTime: item.cookingTime,
      difficulty: item.difficulty,
      author: item.author,
      authorAvatar: item.authorAvatar,
      thumbnail: item.thumbnail,
      views: item.views,
      likes: item.likes,
    }
    return recipeInfo
  }))
}

export const getRecipeDetailById = (id: number): RecipeDetail | undefined => {
  return recipList.find((item => item.id === id))
}

export const getRecipeBriefInfoListByIds = (ids: Array<number>): Array<RecipeBriefInfo> => {
  const list = getRecipeBriefInfoList();
  const result: Array<RecipeBriefInfo> = []
  for (const id of ids) {
    const record = list.find(item => item.id === id);
    if (record) {
      result.push(record);
    }
  }
  return result;
}

export const getRecipeHotKeys = (): Array<string> => {
  return recipList.filter((item => item.category.includes('热门菜肴'))).map((item => item.title)).slice(0, 10);
}

export const getRecipeCategory = (): Array<RecipeCategory> => {
  for (const category of categoryList) {
    category.recipeList = recipList.filter((item => item.category.includes(category.name)));
  }
  return categoryList;
}

export const uploadRecipe = (data: UploadRecipeBody): number => {
  const recipe: RecipeDetail = {
    id: recipList.length + 1,
    title: data.title,
    description: data.description,
    category: '家常菜',
    cookingTime: 20,
    difficulty: '中等',
    author: '美食新手',
    authorAvatar: 'avatar1',
    thumbnail: 'thumbnail',
    views: 0,
    likes: 0,
    ingredients: data.ingredients,
    steps: data.steps,
  }
  recipList.push(recipe);
  return recipe.id;
}
