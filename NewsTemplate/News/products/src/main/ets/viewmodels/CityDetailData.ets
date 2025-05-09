// Defining city type classes.
export class CityType {
  public name: string;
  public city: string[];

  constructor(name: string, city: string[]) {
    this.name = name;
    this.city = city;
  }
}

// Defines the keyword city class.
export class CityGroup {
  public name: string;
  public city: string[];

  constructor(name: string, city: string[]) {
    this.name = name;
    this.city = city;
  }
}

// City list data.
export const CITY_DATA = [
  new CityType('A', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_A').id)),
  new CityType('B', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_B').id)),
  new CityType('C', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_C').id)),
  new CityType('D', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_D').id)),
  new CityType('E', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_E').id)),
  new CityType('F', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_F').id)),
  new CityType('G', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_G').id)),
  new CityType('H', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_H').id)),
  new CityType('J', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_J').id)),
  new CityType('K', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_K').id)),
  new CityType('L', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_L').id)),
  new CityType('M', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_M').id)),
  new CityType('N', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_N').id)),
  new CityType('P', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_P').id)),
  new CityType('Q', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Q').id)),
  new CityType('R', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_R').id)),
  new CityType('S', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_S').id)),
  new CityType('T', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_T').id)),
  new CityType('W', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_W').id)),
  new CityType('X', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_X').id)),
  new CityType('Y', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Y').id)),
  new CityType('Z', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Z').id))
];

// Search for keywords and related city data.
export const ALL_CITY2 = [
  new CityGroup('a', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_A').id)),
  new CityGroup('an', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_an').id)),
  new CityGroup('b', getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.city_data_B').id)),
];

// Data of popular cities in China.
export const HOT_CITY = getContext(this).resourceManager.getStringArrayValueSync($r('app.strarray.hot_city').id);

// AlphabetIndexer Alphabetical index bar data.
export const TAB_VALUE =
  ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'];