export interface TabInfo {
  label: ResourceStr;
  activeIcon: Resource;
  defaultIcon: Resource;
  component: WrappedBuilder<[]>;
  safeAreaEdge: SafeAreaEdge[];
  pageBgColor: ResourceStr;
}