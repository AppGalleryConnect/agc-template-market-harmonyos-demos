// 内层键：亲属关系路径标识（逗号分隔的动态字符串，无固定枚举）
type RelationPathKey = string;

// 内层值：亲属称谓数组
type KinshipTitle = string[];

// 内层映射：路径标识 → 称谓数组
export type KinshipMap = Record<RelationPathKey, KinshipTitle>;

// 最终完整类型：辈分标识 → 亲属映射
export type KinshipDictionary = Record<string, KinshipMap>;