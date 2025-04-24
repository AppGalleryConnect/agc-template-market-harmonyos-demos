export interface TabListItem {
  label: Resource;
  icon: Resource;
  iconChecked: Resource;
  titleBackgroundColor: Resource | Color;
}

export interface TaskItem {
  parentID?: string,
  taskID?: string,
  title?: string,
  taskDesc?: string,
  isFinished?: boolean,
  planTime?: string,
  imgList?: Array<string>
}