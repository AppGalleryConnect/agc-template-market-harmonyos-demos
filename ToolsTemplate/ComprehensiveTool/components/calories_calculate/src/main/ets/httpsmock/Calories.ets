import {
  CustomFoodBody,
  DietPlanBody,
  DietPlans,
  FoodCalories,
  FoodCategory,
  FoodPlanCalories,
} from '../model/Calories';
import { Decimal } from '@kit.ArkTS';

const categories: FoodCategory[] = [
  { id: 1, name: '常用', foodList: [] },
  { id: 2, name: '主食', foodList: [] },
  { id: 3, name: '热门菜品', foodList: [] },
  { id: 4, name: '蔬菜水果', foodList: [] },
  { id: 5, name: '肉蛋奶', foodList: [] },
  { id: 6, name: '豆类坚果', foodList: [] },
  { id: 7, name: '零食饮料', foodList: [] },
  { id: 8, name: '自定义食材', foodList: [] },
];

const foodData: FoodCalories[] = [
  // ==================== 常用 ====================
  {
    id: 1,
    name: '鸡蛋（水煮）',
    category: '常用',
    calories: 143,
  },
  {
    id: 2,
    name: '鸡胸肉（生）',
    category: '常用',
    calories: 133,
  },
  {
    id: 3,
    name: '大米（生）',
    category: '常用',
    calories: 346,
  },
  {
    id: 4,
    name: '牛奶（全脂）',
    category: '常用',
    calories: 65,
  },
  {
    id: 5,
    name: '苹果',
    category: '常用',
    calories: 52,
  },
  {
    id: 6,
    name: '西兰花',
    category: '常用',
    calories: 35,
  },
  {
    id: 7,
    name: '番茄',
    category: '常用',
    calories: 18,
  },
  {
    id: 8,
    name: '燕麦片',
    category: '常用',
    calories: 389,
  },

  // ==================== 主食 ====================
  {
    id: 9,
    name: '白馒头',
    category: '主食',
    calories: 223,
  },
  {
    id: 10,
    name: '全麦面包',
    category: '主食',
    calories: 247,
  },
  {
    id: 11,
    name: '玉米（鲜）',
    category: '主食',
    calories: 112,
  },
  {
    id: 12,
    name: '红薯（蒸）',
    category: '主食',
    calories: 86,
  },
  {
    id: 13,
    name: '意大利面（干）',
    category: '主食',
    calories: 351,
  },
  {
    id: 14,
    name: '荞麦面',
    category: '主食',
    calories: 340,
  },
  {
    id: 15,
    name: '土豆（蒸）',
    category: '主食',
    calories: 76,
  },
  {
    id: 16,
    name: '年糕',
    category: '主食',
    calories: 154,
  },

  // ==================== 热门菜品 ====================
  {
    id: 17,
    name: '宫保鸡丁',
    category: '热门菜品',
    calories: 210,
  },
  {
    id: 18,
    name: '红烧肉',
    category: '热门菜品',
    calories: 470,
  },
  {
    id: 19,
    name: '番茄炒蛋',
    category: '热门菜品',
    calories: 120,
  },
  {
    id: 20,
    name: '鱼香肉丝',
    category: '热门菜品',
    calories: 180,
  },
  {
    id: 21,
    name: '麻婆豆腐',
    category: '热门菜品',
    calories: 150,
  },
  {
    id: 22,
    name: '清蒸鱼',
    category: '热门菜品',
    calories: 130,
  },
  {
    id: 23,
    name: '糖醋排骨',
    category: '热门菜品',
    calories: 290,
  },
  {
    id: 24,
    name: '地三鲜',
    category: '热门菜品',
    calories: 110,
  },

  // ==================== 蔬菜水果 ====================
  {
    id: 25,
    name: '胡萝卜',
    category: '蔬菜水果',
    calories: 41,
  },
  {
    id: 26,
    name: '菠菜',
    category: '蔬菜水果',
    calories: 23,
  },
  {
    id: 27,
    name: '黄瓜',
    category: '蔬菜水果',
    calories: 15,
  },
  {
    id: 28,
    name: '香蕉',
    category: '蔬菜水果',
    calories: 89,
  },
  {
    id: 29,
    name: '橙子',
    category: '蔬菜水果',
    calories: 47,
  },
  {
    id: 30,
    name: '草莓',
    category: '蔬菜水果',
    calories: 32,
  },
  {
    id: 31,
    name: '葡萄',
    category: '蔬菜水果',
    calories: 69,
  },
  {
    id: 32,
    name: '猕猴桃',
    category: '蔬菜水果',
    calories: 61,
  },

  // ==================== 肉蛋奶 ====================
  {
    id: 33,
    name: '瘦牛肉（生）',
    category: '肉蛋奶',
    calories: 143,
  },
  {
    id: 34,
    name: '三文鱼（生）',
    category: '肉蛋奶',
    calories: 208,
  },
  {
    id: 35,
    name: '虾仁',
    category: '肉蛋奶',
    calories: 48,
  },
  {
    id: 36,
    name: '酸奶（无糖）',
    category: '肉蛋奶',
    calories: 57,
  },
  {
    id: 37,
    name: '奶酪（切达）',
    category: '肉蛋奶',
    calories: 402,
  },
  {
    id: 38,
    name: '鹌鹑蛋',
    category: '肉蛋奶',
    calories: 158,
  },
  {
    id: 39,
    name: '培根',
    category: '肉蛋奶',
    calories: 541,
  },
  {
    id: 40,
    name: '希腊酸奶',
    category: '肉蛋奶',
    calories: 97,
  },

  // ==================== 豆类坚果 ====================
  {
    id: 41,
    name: '豆腐',
    category: '豆类坚果',
    calories: 82,
  },
  {
    id: 42,
    name: '黄豆（干）',
    category: '豆类坚果',
    calories: 390,
  },
  {
    id: 43,
    name: '杏仁',
    category: '豆类坚果',
    calories: 578,
  },
  {
    id: 44,
    name: '核桃',
    category: '豆类坚果',
    calories: 654,
  },
  {
    id: 45,
    name: '花生（生）',
    category: '豆类坚果',
    calories: 567,
  },
  {
    id: 46,
    name: '腰果',
    category: '豆类坚果',
    calories: 553,
  },
  {
    id: 47,
    name: '黑豆',
    category: '豆类坚果',
    calories: 341,
  },
  {
    id: 48,
    name: '开心果',
    category: '豆类坚果',
    calories: 562,
  },

  // ==================== 零食饮料 ====================
  {
    id: 49,
    name: '薯片',
    category: '零食饮料',
    calories: 547,
  },
  {
    id: 50,
    name: '黑巧克力（70%）',
    category: '零食饮料',
    calories: 598,
  },
  {
    id: 51,
    name: '可乐',
    category: '零食饮料',
    calories: 43,
  },
  {
    id: 52,
    name: '饼干（苏打）',
    category: '零食饮料',
    calories: 408,
  },
  {
    id: 53,
    name: '奶茶（无糖）',
    category: '零食饮料',
    calories: 25,
  },
  {
    id: 54,
    name: '爆米花（无糖）',
    category: '零食饮料',
    calories: 375,
  },
  {
    id: 55,
    name: '果汁（橙汁）',
    category: '零食饮料',
    calories: 45,
  },
  {
    id: 56,
    name: '冰淇淋',
    category: '零食饮料',
    calories: 207,
  },

  // ==================== 自定义食材 ====================
  {
    id: 57,
    name: '自定义食材1',
    category: '自定义食材',
    calories: 100,
  },
  {
    id: 58,
    name: '自定义食材2',
    category: '自定义食材',
    calories: 200,
  },
  {
    id: 59,
    name: '自定义食材3',
    category: '自定义食材',
    calories: 300,
  },
  {
    id: 60,
    name: '自定义食材4',
    category: '自定义食材',
    calories: 400,
  },
];
const calorieRange: Record<string, string> = {
  '早餐': '建议范围：600-800千卡',
  '午餐': '建议范围：800-1000千卡',
  '晚餐': '建议范围：600-800 千卡',
}
let dietPlanId: number = 0;
let dietPlans: Array<DietPlans> = [];

export const getFoodCategory = (): Array<FoodCategory> => {
  for (const category of categories) {
    category.foodList = foodData.filter((item => item.category.includes(category.name)));
  }
  return categories;
};

export const addDietPlans = (data: DietPlanBody) => {
  if (data.menuId && !data.foodList.length) {
    dietPlans = dietPlans.filter(item => item.menuId !== data.menuId)
    return
  }
  let totalCalories = 0
  let plans: FoodPlanCalories[] = []
  data.foodList.forEach((item, index) => {
    let calories = item.calories
    let foodOri = foodData.find(food => food.id === item.id)
    let weight = foodOri?.weight ?? 100
    if (item.weight !== weight) {
      weight = item.weight
      calories = new Decimal(item.calories).div(weight).mul(item.weight).toNumber()
    }
    let food: FoodPlanCalories = {
      id: index,
      name: item.name,
      weight: item.weight,
      calories: calories,
    }
    plans.push(food)
    totalCalories = Number((totalCalories + calories).toFixed(2))
  })

  let plan = dietPlans.find(item => item.menuId === data.menuId)
  if (plan?.id) {
    const dietPlan: DietPlans = {
      id: plan.id,
      menuId: data.menuId,
      name: data.name,
      desc: calorieRange[data.name],
      totalCalories: totalCalories,
      foodList: plans,
    };
    dietPlans.forEach((item, index) => {
      if (plan?.id === item.id) {
        dietPlans[index] = dietPlan
      }
    })
  } else {
    dietPlanId++
    const dietPlan: DietPlans = {
      id: dietPlanId,
      menuId: data.menuId,
      name: data.name,
      desc: calorieRange[data.name],
      totalCalories: totalCalories,
      foodList: plans,
    };
    dietPlans.push(dietPlan);
  }
};

export const queryDietPlans = (): Array<DietPlans> => {
  return dietPlans;
};

export const queryDietPlan = (menuId: number): DietPlans | undefined => {
  return dietPlans.find(item => item.menuId === menuId);
};

export const searchFoodByName = (name: string): Array<FoodCalories> => {
  return foodData.filter(item => item.name.includes(name));
};

export const addCustomFood = (data: CustomFoodBody): void => {
  let food: FoodCalories = {
    id: foodData.length + 1,
    name: data.name,
    category: '自定义食材',
    weight: data.weight,
    calories: data.calories,
  }
  foodData.push(food)
};
