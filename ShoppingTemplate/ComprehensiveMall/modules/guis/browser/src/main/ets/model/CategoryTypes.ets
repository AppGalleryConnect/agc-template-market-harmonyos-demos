import { Category } from './Category';
import { CategoryIndicatorDot } from './CategoryIndicatorDot';

export interface CategoryBrowserRenderUnit {
  id: string;
  content: Category[][];
  dot: CategoryIndicatorDot;
}

export type CategoryBrowserViewData = CategoryBrowserRenderUnit[];
