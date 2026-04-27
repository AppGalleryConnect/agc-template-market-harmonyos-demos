export interface FoodCalories {
  id: number;
  name: string;
  category: string;
  weight?: number
  calories: number;
}

export interface FoodCategory {
  id: number;
  name: string;
  foodList: Array<FoodCalories>;
}

export interface FoodPlanCaloriesBody {
  id: number;
  name: string;
  weight: number
  calories: number;
}

export interface DietPlanBody {
  menuId: number;
  name: string;
  foodList: FoodPlanCaloriesBody[]
}

export interface FoodPlanCalories {
  id: number;
  name: string;
  weight: number
  calories: number;
}



export interface DietPlans {
  id: number;
  menuId: number;
  name: string;
  desc: string
  totalCalories: number
  foodList: FoodPlanCalories[]
}


export interface ChangeFollowersBody {
  bloggerId: number;
  type: number
}

export interface CustomFoodBody {
  name: string;
  weight: number
  calories: number;
}