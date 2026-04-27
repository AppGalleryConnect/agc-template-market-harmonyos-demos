import { RoomType } from 'type';

export interface Source {
  source: string;
}

export interface SelectKeys {
  index: number;
  isSelected: boolean;
}

export interface NavigationConfig {
  /*主键ID */
  id: number;

  /*景区名称 */
  image: string;

  /*景区分类名称 */
  title: string;
}

export interface EnhancedSource {
  source: string,
  data: RoomType
}