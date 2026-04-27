/**
 * Address Data Transfer Object (DTO)
 */
export interface AddressDTO {
  id: string;
  name: string;         // 姓名
  phone: string;        // 手机号
  countryCode: string;  // 国家代码 (例如: CN)
  country: string;      // 国家
  province: string;     // 省
  city: string;         // 市
  district: string;     // 区
  street: string;       // 街道
  detail: string;       // 地址详述 (例如: 楼栋、门牌号等)
  isDefault: boolean;   // 是否为默认地址
  createdAt: number;    // 地址创建时间
  updatedAt: number;    // 地址更新时间
  latitude: number; // 纬度
  longitude: number; // 经度
}
